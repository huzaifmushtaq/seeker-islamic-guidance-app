import 'dart:convert';

import 'package:http/http.dart' as http;

class MetalPrices {
  final Map<String, double> goldPricesByPurity;
  final Map<String, double> silverPricesByPurity;
  final DateTime updatedAt;
  final String currency;
  final String source;

  const MetalPrices({
    required this.goldPricesByPurity,
    required this.silverPricesByPurity,
    required this.updatedAt,
    required this.currency,
    required this.source,
  });

  double get goldPerGram => goldPricesByPurity['24K'] ?? 0;
  double get silverPerGram => silverPricesByPurity['999'] ?? 0;

  double goldPrice(String purity) =>
      goldPricesByPurity[purity] ?? goldPerGram * _goldFactor(purity);

  double silverPrice(String purity) =>
      silverPricesByPurity[purity] ?? silverPerGram * _silverFactor(purity);

  static double _goldFactor(String purity) {
    final value = double.tryParse(purity.replaceAll('K', '')) ?? 24;
    return value / 24;
  }

  static double _silverFactor(String purity) {
    final value = double.tryParse(purity) ?? 999;
    return value / 999;
  }
}

/// India-first metal pricing for the Zakat calculator.
///
/// INR uses Snapdata's public India bullion snapshots, which republish the
/// IBJA benchmark. This gives Seeker separate 24K, 22K and 18K gold rates and
/// silver in INR/kg. Other currencies use goldprice.dev's public karat and
/// metal conversion endpoints.
class MetalPriceService {
  static const String _indiaGoldUrl =
      'https://snapdata.dev/api/v1/gold/in/latest.json';
  static const String _indiaSilverUrl =
      'https://snapdata.dev/api/v1/silver/in/latest.json';
  static const String _caratUrl =
      'https://api.goldprice.dev/v1/carat';
  static const String _convertUrl =
      'https://api.goldprice.dev/v1/convert';

  Future<MetalPrices> fetch({required String currency}) async {
    final normalized = currency.toUpperCase();
    if (normalized == 'INR') return _fetchIndia();
    return _fetchInternational(normalized);
  }

  Future<MetalPrices> _fetchIndia() async {
    final responses = await Future.wait([
      _get(_indiaGoldUrl),
      _get(_indiaSilverUrl),
    ]);

    final goldDecoded = _decodeMap(responses[0], 'India gold');
    final silverDecoded = _decodeMap(responses[1], 'India silver');

    final gold = <String, double>{};
    final observations = goldDecoded['observations'];
    if (observations is List) {
      for (final item in observations) {
        if (item is! Map) continue;
        final instrument = item['instrument']?.toString().toUpperCase() ?? '';
        final value = _toDouble(item['value']);
        if (value == null || value <= 0) continue;
        if (instrument.contains('24K')) gold['24K'] = value;
        if (instrument.contains('22K')) gold['22K'] = value;
        if (instrument.contains('18K')) gold['18K'] = value;
      }
    }

    if (gold['24K'] == null || gold['22K'] == null || gold['18K'] == null) {
      throw Exception('India gold feed did not contain usable 24K, 22K and 18K prices.');
    }

    final silverObservations = silverDecoded['observations'];
    double? silverPerGram;
    if (silverObservations is List) {
      for (final item in silverObservations) {
        if (item is! Map) continue;
        final value = _toDouble(item['value']);
        if (value != null && value > 0) {
          // Snapdata quotes Indian silver in INR/kg.
          silverPerGram = value / 1000;
          break;
        }
      }
    }

    if (silverPerGram == null || silverPerGram <= 0) {
      throw Exception('India silver feed did not contain a usable INR/kg price.');
    }

    final timestamp = _parseDate(goldDecoded['generated_at']) ??
        _parseDate(silverDecoded['generated_at']) ??
        DateTime.now();

    return MetalPrices(
      goldPricesByPurity: gold,
      silverPricesByPurity: {
        '999': silverPerGram,
        '925': silverPerGram * 0.925 / 0.999,
        '900': silverPerGram * 0.900 / 0.999,
        '800': silverPerGram * 0.800 / 0.999,
      },
      updatedAt: timestamp,
      currency: 'INR',
      source: 'IBJA India benchmark via Snapdata',
    );
  }

  Future<MetalPrices> _fetchInternational(String currency) async {
    final goldResponse = await _get('$_caratUrl?currency=$currency');
    final gold = _decodeMap(goldResponse, 'Gold price');

    final silverResponse = await _get(
      '$_convertUrl?from=XAG&to=$currency&amount=1&unit=gram',
    );
    final silver = _decodeMap(silverResponse, 'Silver price');

    final goldMap = <String, double>{};
    for (final purity in const ['24K', '22K', '21K', '20K', '18K', '16K', '14K', '10K']) {
      final key = 'price_gram_${purity.toLowerCase()}';
      final value = _toDouble(gold[key]);
      if (value != null && value > 0) goldMap[purity] = value;
    }

    final silverPerGram = _toDouble(silver['result']);
    if (goldMap['24K'] == null || silverPerGram == null || silverPerGram <= 0) {
      throw Exception('International metal feed did not contain usable prices.');
    }

    return MetalPrices(
      goldPricesByPurity: goldMap,
      silverPricesByPurity: {
        '999': silverPerGram,
        '925': silverPerGram * 0.925 / 0.999,
        '900': silverPerGram * 0.900 / 0.999,
        '800': silverPerGram * 0.800 / 0.999,
      },
      updatedAt: _parseDate(gold['timestamp']) ??
          _parseDate(silver['timestamp']) ??
          DateTime.now(),
      currency: currency,
      source: 'goldprice.dev',
    );
  }

  Future<http.Response> _get(String url) => http
      .get(Uri.parse(url), headers: const {'Accept': 'application/json'})
      .timeout(const Duration(seconds: 15));

  Map<String, dynamic> _decodeMap(http.Response response, String label) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('$label request failed (HTTP ${response.statusCode}).');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('$label service returned invalid JSON.');
    }
    return decoded;
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  DateTime? _parseDate(dynamic value) {
    if (value is! String) return null;
    return DateTime.tryParse(value)?.toLocal();
  }
}
