// M6 Masjid Terdekat (FR-LBS-09..14)
import '../../../core/utils/geo_utils.dart';

class Mosque {
  const Mosque({
    required this.osmId,
    required this.name,
    required this.lat,
    required this.lon,
    this.address,
    this.distanceM,
    this.isFavorite = false,
  });

  /// Respons /mosques/nearby. Nama kunci dibaca longgar karena kontrak server
  /// dapat memakai lng atau lon, serta jarak dalam meter atau kilometer.
  factory Mosque.fromJson(Map<String, dynamic> j) {
    double? num_(Object? v) => v is num ? v.toDouble() : double.tryParse('$v');
    final lat = num_(j['lat'] ?? j['latitude']);
    final lon = num_(j['lon'] ?? j['lng'] ?? j['longitude']);
    if (lat == null || lon == null) {
      throw const FormatException('koordinat masjid tidak ada');
    }
    final meters = num_(j['distance_m']) ??
        (num_(j['distance_km']) == null ? null : num_(j['distance_km'])! * 1000);
    final name = (j['name'] ?? '').toString().trim();
    return Mosque(
      osmId: (j['osm_id'] ?? j['id']).toString(),
      name: name.isEmpty ? 'Masjid tanpa nama' : name,
      lat: lat,
      lon: lon,
      address: j['address']?.toString(),
      distanceM: meters,
    );
  }

  final String osmId;
  final String name;
  final double lat;
  final double lon;
  final String? address;
  final double? distanceM;
  final bool isFavorite;

  Mosque copyWith({double? distanceM, bool? isFavorite}) => Mosque(
        osmId: osmId,
        name: name,
        lat: lat,
        lon: lon,
        address: address,
        distanceM: distanceM ?? this.distanceM,
        isFavorite: isFavorite ?? this.isFavorite,
      );

  /// Jarak dihitung ulang dari posisi pengguna agar konsisten saat data cache
  /// dipakai dari lokasi yang berbeda.
  Mosque withDistanceFrom(double userLat, double userLon) => copyWith(
        distanceM: GeoUtils.distanceMeters(userLat, userLon, lat, lon),
      );

  String get distanceLabel {
    final d = distanceM;
    if (d == null) return '';
    return d < 1000 ? '${d.round()} m' : '${(d / 1000).toStringAsFixed(1)} km';
  }

  Map<String, dynamic> toJson() => {
        'osm_id': osmId,
        'name': name,
        'lat': lat,
        'lon': lon,
        if (address != null) 'address': address,
      };
}

enum MosqueSort { distance, name }

/// Hasil pencarian: [fromCache] true bila server tidak terjangkau.
class MosqueResult {
  const MosqueResult({required this.items, this.fromCache = false, this.cachedAt});

  final List<Mosque> items;
  final bool fromCache;
  final DateTime? cachedAt;
}

abstract final class MosqueFilter {
  /// Radius pilihan (km), FR-LBS-11.
  static const List<double> radii = [1, 2, 5, 10];

  static List<Mosque> apply(
    List<Mosque> all, {
    required double radiusKm,
    String query = '',
    MosqueSort sort = MosqueSort.distance,
  }) {
    final q = query.trim().toLowerCase();
    final out = all.where((m) {
      final d = m.distanceM;
      if (d != null && d > radiusKm * 1000) return false;
      if (q.isEmpty) return true;
      return m.name.toLowerCase().contains(q) ||
          (m.address ?? '').toLowerCase().contains(q);
    }).toList();
    out.sort((a, b) {
      if (sort == MosqueSort.name) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      return (a.distanceM ?? double.infinity).compareTo(b.distanceM ?? double.infinity);
    });
    return out;
  }
}
