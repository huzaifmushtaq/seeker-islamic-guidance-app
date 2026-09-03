import 'dart:convert';

import 'package:http/http.dart' as http;

class MetalPrices {
  final double goldPerGram;
  final double silverPerGram;
  final DateTime updatedAt;
  final String currency;
  final String source;

  const MetalPrices({
    required this.goldPerGram,
    required this.silverPerGram,
    required this.updatedAt,
    required this.currency,
    required this.source,
  });
}

/// Fetches indicative spot-market prices for gold (XAU) and silver (XAG).
///
/// The API returns prices per troy ounce. Seeker converts them to grams using
/// the international troy-ounce definition (31.1034768 g).
class MetalPriceService {
  static const String _baseUrl = 'https://api.gold-api.com/price';
  static const double gramsPerTroyOunce = 31.1034768;
  static const String sourceName = 'Gold API';

  Future<MetalPrices> fetch({required String currency}) async {
    final normalized = currency.toUpperCase();

    final responses = await Future.wait([
      http.get(Uri.parse('$_baseUrl/XAU/$normalized')).timeout(const Duration(seconds: 12)),
      http.get(Uri.parse('$_baseUrl/XAG/$normalized')).timeout(const Duration(seconds: 12)),
    ]);

    final gold = _parsePrice(responses[0], 'XAU');
    final silver = _parsePrice(responses[1], 'XAG');

    final goldTimestamp = _parseTimestamp(responses[0]);
    final silverTimestamp = _parseTimestamp(responses[1]);
    final updatedAt = goldTimestamp.isBefore(silverTimestamp)
        ? goldTimestamp
        : silverTimestamp;

    return MetalPrices(
      goldPerGram: gold / gramsPerTroyOunce,
      silverPerGram: silver / gramsPerTroyOunce,
      updatedAt: updatedAt,
      currency: normalized,
      source: sourceName,
    );
  }

  double _parsePrice(http.Response response, String metal) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('$metal price request failed (${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid $metal price response.');
    }

    final candidates = <dynamic>[
      decoded['price'],
      decoded['rate'],
      decoded['value'],
      (decoded['rate'] is Map) ? decoded['rate']['price'] : null,
    ];

    for (final candidate in candidates) {
      final value = candidate is num
          ? candidate.toDouble()
          : double.tryParse(candidate?.toString() ?? '');
      if (value != null && value > 0) return value;
    }

    throw Exception('No usable $metal price was returned.');
  }

  DateTime _parseTimestamp(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      final raw = decoded is Map<String, dynamic> ? decoded['timestamp'] : null;
      if (raw is num) {
        return DateTime.fromMillisecondsSinceEpoch(
          raw.toInt() * 1000,
          isUtc: true,
        ).toLocal();
      }
      final date = decoded is Map<String, dynamic> ? decoded['datetime'] : null;
      if (date is String) return DateTime.parse(date).toLocal();
    } catch (_) {
      // Fall through to the current time if the provider omits a timestamp.
    }
    return DateTime.now();
  }
}
