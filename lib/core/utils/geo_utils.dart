// Fondasi lintas fitur. Perhitungan geografi (M6, M7, M15).
import 'dart:math' as math;

abstract final class GeoUtils {
  static const double earthRadiusMeters = 6371000;

  static double _rad(double deg) => deg * math.pi / 180;
  static double _deg(double rad) => rad * 180 / math.pi;

  static double distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.pow(math.sin(dLon / 2), 2);
    return 2 * earthRadiusMeters * math.asin(math.sqrt(a.toDouble()));
  }

  static double bearingDegrees(double lat1, double lon1, double lat2, double lon2) {
    final dLon = _rad(lon2 - lon1);
    final y = math.sin(dLon) * math.cos(_rad(lat2));
    final x = math.cos(_rad(lat1)) * math.sin(_rad(lat2)) -
        math.sin(_rad(lat1)) * math.cos(_rad(lat2)) * math.cos(dLon);
    return normalizeDegrees(_deg(math.atan2(y, x)));
  }

  static double normalizeDegrees(double degrees) {
    final m = degrees % 360;
    return m < 0 ? m + 360 : m;
  }

  static double angleDifference(double target, double current) {
    var d = normalizeDegrees(target - current);
    if (d > 180) d -= 360;
    return d;
  }

  static const _compass = [
    'Utara', 'Timur Laut', 'Timur', 'Tenggara',
    'Selatan', 'Barat Daya', 'Barat', 'Barat Laut',
  ];

  static String compassName(double bearing) {
    final index = ((normalizeDegrees(bearing) + 22.5) ~/ 45) % 8;
    return _compass[index];
  }
}
