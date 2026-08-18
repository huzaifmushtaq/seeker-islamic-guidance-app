import 'dart:math' as math;

class QiblaService {
  // Kaaba coordinates
  static const double kaabaLatitude = 21.422487;
  static const double kaabaLongitude = 39.826206;

  /// Returns the Qibla bearing from the user's location.
  ///
  /// Bearing is measured clockwise from true north:
  /// 0°   = North
  /// 90°  = East
  /// 180° = South
  /// 270° = West
  static double calculateQiblaBearing({
    required double latitude,
    required double longitude,
  }) {
    final userLat =
        _toRadians(latitude);

    final userLon =
        _toRadians(longitude);

    final kaabaLat =
        _toRadians(kaabaLatitude);

    final kaabaLon =
        _toRadians(kaabaLongitude);

    final deltaLon =
        kaabaLon - userLon;

    final y =
        math.sin(deltaLon);

    final x =
        math.cos(userLat) *
                math.sin(kaabaLat) -
            math.sin(userLat) *
                math.cos(kaabaLat) *
                math.cos(deltaLon);

    final bearing =
        math.atan2(y, x);

    final degrees =
        _toDegrees(bearing);

    return (degrees + 360) % 360;
  }

  static double _toRadians(
    double degrees,
  ) {
    return degrees *
        math.pi /
        180;
  }

  static double _toDegrees(
    double radians,
  ) {
    return radians *
        180 /
        math.pi;
  }
}