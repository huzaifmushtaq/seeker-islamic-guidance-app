import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart' as loc;

class LocationService {
  final loc.Location _location = loc.Location();
  
  Future<Position> getCurrentLocation() async {
  // 1. Check app permission
  var permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      throw Exception("Location permission denied.");
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception("Location permission permanently denied.");
  }

  // 2. Check if GPS is ON
  bool serviceEnabled = await _location.serviceEnabled();

  if (!serviceEnabled) {
    serviceEnabled = await _location.requestService();

    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }
  }

  // 3. Finally get coordinates
  return await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
    ),
  );
}

  Future<String> getCityName(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        return placemarks.first.locality ??
            placemarks.first.subAdministrativeArea ??
            "Unknown";
      }

      return "Location";
    } catch (e) {
      return "Unknown";
    }
  }

  Future<bool> isLocationConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("location_configured") ?? false;
  }

  Future<void> setLocationConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("location_configured", true);
  }

  Future<bool> hasAskedLocationPermission() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool("asked_location_permission") ?? false;
}

Future<void> setAskedLocationPermission() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool("asked_location_permission", true);
}

  Future<void> saveLocation({
    required double latitude,
    required double longitude,
    required String city,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble("latitude", latitude);
    await prefs.setDouble("longitude", longitude);
    await prefs.setString("city", city);
  }

  Future<double?> getSavedLatitude() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble("latitude");
  }

  Future<double?> getSavedLongitude() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble("longitude");
  }

  Future<String?> getSavedCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("city");
  }

  Position? getSavedPosition({
    required double? latitude,
    required double? longitude,
  }) {
    if (latitude == null || longitude == null) {
      return null;
    }

    return Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }
}
