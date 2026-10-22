// M16 Notifikasi (FR-NTF-08, opsional). Dicek saat aplikasi dibuka, tanpa
// layanan latar belakang, sehingga tidak menguras baterai.
import '../../../core/config/app_config.dart';
import '../../../core/utils/geo_utils.dart';
import '../../mosque/models/mosque.dart';

class GeofenceService {
  GeofenceService({
    this.radiusMeters = AppConfig.geofenceRadiusMeters,
    this.cooldown = const Duration(hours: 6),
  });

  final double radiusMeters;
  final Duration cooldown;
  final Map<String, DateTime> _lastNotified = {};

  /// Masjid favorit terdekat dalam radius yang belum diberi notifikasi dalam
  /// masa [cooldown]. Menandai masjid itu sebagai sudah diberi tahu.
  Mosque? check({
    required double lat,
    required double lon,
    required List<Mosque> favorites,
    required DateTime now,
  }) {
    Mosque? best;
    var bestDistance = double.infinity;
    for (final m in favorites) {
      final d = GeoUtils.distanceMeters(lat, lon, m.lat, m.lon);
      if (d > radiusMeters || d >= bestDistance) continue;
      final last = _lastNotified[m.osmId];
      if (last != null && now.difference(last) < cooldown) continue;
      best = m;
      bestDistance = d;
    }
    if (best != null) _lastNotified[best.osmId] = now;
    return best;
  }
}
