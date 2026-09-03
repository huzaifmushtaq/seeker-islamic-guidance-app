import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

class NearbyMosque {
  final String placeId;
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final String? mapsUri;

  const NearbyMosque({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    required this.mapsUri,
  });

  String get distanceLabel {
    if (distanceMeters < 1000) return '${distanceMeters.round()} m away';
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km away';
  }
}

class GooglePlacesMosqueService {
  static const _nearbyEndpoint =
      'https://places.googleapis.com/v1/places:searchNearby';
  static const _textEndpoint =
      'https://places.googleapis.com/v1/places:searchText';

  /// Finds the closest mosque within [radiusMeters].
  ///
  /// First uses Google's official `mosque` place type with DISTANCE ranking.
  /// If that returns nothing, a text search for "mosque" is used as a
  /// fallback because Google notes that some places can remain uncategorized.
  /// The final candidates are always sorted locally by coordinates.
  Future<NearbyMosque?> findNearestMosque({
    required double latitude,
    required double longitude,
    required String apiKey,
    double radiusMeters = 10000,
  }) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw const GooglePlacesConfigurationException(
        'Google Places API key is not configured.',
      );
    }

    final radius = radiusMeters.clamp(1, 50000).toDouble();

    final typed = await _searchNearbyTyped(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      apiKey: key,
    );

    if (typed.isNotEmpty) {
      typed.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
      return typed.first;
    }

    // Fallback catches places whose Google listing is not currently typed as
    // `mosque` but whose name/address/search content identifies it as one.
    final text = await _searchText(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      apiKey: key,
      query: 'mosque',
    );

    if (text.isNotEmpty) {
      text.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
      return text.first;
    }

    return null;
  }

  Future<List<NearbyMosque>> _searchNearbyTyped({
    required double latitude,
    required double longitude,
    required double radius,
    required String apiKey,
  }) async {
    final response = await http
        .post(
          Uri.parse(_nearbyEndpoint),
          headers: _headers(apiKey),
          body: jsonEncode({
            'includedTypes': ['mosque'],
            'maxResultCount': 20,
            'rankPreference': 'DISTANCE',
            'locationRestriction': {
              'circle': {
                'center': {
                  'latitude': latitude,
                  'longitude': longitude,
                },
                'radius': radius,
              },
            },
            'languageCode': 'en',
            'regionCode': 'IN',
          }),
        )
        .timeout(const Duration(seconds: 12));

    return _parseResponse(
      response,
      latitude,
      longitude,
    );
  }

  Future<List<NearbyMosque>> _searchText({
    required double latitude,
    required double longitude,
    required double radius,
    required String apiKey,
    required String query,
  }) async {
    final response = await http
        .post(
          Uri.parse(_textEndpoint),
          headers: _headers(apiKey),
          body: jsonEncode({
            'textQuery': query,
            'maxResultCount': 20,
            'rankPreference': 'DISTANCE',
            'locationBias': {
              'circle': {
                'center': {
                  'latitude': latitude,
                  'longitude': longitude,
                },
                'radius': radius,
              },
            },
            'languageCode': 'en',
            'regionCode': 'IN',
          }),
        )
        .timeout(const Duration(seconds: 12));

    return _parseResponse(
      response,
      latitude,
      longitude,
    );
  }

  Map<String, String> _headers(String apiKey) => {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask':
            'places.id,places.displayName,places.formattedAddress,places.location,places.googleMapsUri',
      };

  List<NearbyMosque> _parseResponse(
    http.Response response,
    double userLatitude,
    double userLongitude,
  ) {
    if (response.statusCode != 200) {
      String message = 'Google Places request failed.';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['error'] is Map) {
          final error = Map<String, dynamic>.from(body['error'] as Map);
          message = error['message']?.toString() ?? message;
        }
      } catch (_) {}

      throw GooglePlacesException(
        'Google Places returned ${response.statusCode}: $message',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const GooglePlacesException('Invalid Google Places response.');
    }

    final places = decoded['places'];
    if (places is! List) return const [];

    final results = <NearbyMosque>[];
    final seen = <String>{};

    for (final item in places) {
      if (item is! Map) continue;

      final placeId = item['id']?.toString();
      final displayName = item['displayName'];
      final location = item['location'];

      if (placeId == null || !seen.add(placeId)) continue;
      if (displayName is! Map || location is! Map) continue;

      final name = displayName['text']?.toString().trim();
      final lat = _number(location['latitude']);
      final lng = _number(location['longitude']);

      if (name == null || name.isEmpty || lat == null || lng == null) {
        continue;
      }

      results.add(
        NearbyMosque(
          placeId: placeId,
          name: name,
          address: _stringOrNull(item['formattedAddress']),
          latitude: lat,
          longitude: lng,
          distanceMeters: _distanceMeters(
            userLatitude,
            userLongitude,
            lat,
            lng,
          ),
          mapsUri: _stringOrNull(item['googleMapsUri']),
        ),
      );
    }

    return results;
  }

  double? _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  String? _stringOrNull(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  double _distanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0;
    final p1 = lat1 * math.pi / 180.0;
    final p2 = lat2 * math.pi / 180.0;
    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLon = (lon2 - lon1) * math.pi / 180.0;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(p1) *
            math.cos(p2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    return earthRadius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }
}

class GooglePlacesException implements Exception {
  final String message;
  const GooglePlacesException(this.message);

  @override
  String toString() => message;
}

class GooglePlacesConfigurationException implements Exception {
  final String message;
  const GooglePlacesConfigurationException(this.message);

  @override
  String toString() => message;
}
