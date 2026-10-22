// M4 Beranda (FR-LBS-01, FR-LBS-02). Lokasi perangkat dan lokasi terakhir.
import 'dart:convert';

import 'package:geolocator/geolocator.dart';

import '../../../core/database/daos/settings_dao.dart';

class GeoPoint {
  const GeoPoint({required this.lat, required this.lon, this.isDefault = false});

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  /// Jakarta, dipakai bila lokasi belum pernah didapat.
  static const defaultPoint = GeoPoint(lat: -6.2088, lon: 106.8456, isDefault: true);

  final double lat;
  final double lon;
  final bool isDefault;

  /// Dibulatkan dua desimal (sekitar 1 km) agar cache dipakai ulang di sekitar lokasi.
  String get locationKey => '${lat.toStringAsFixed(2)},${lon.toStringAsFixed(2)}';

  Map<String, dynamic> toJson() => {'lat': lat, 'lon': lon};

  @override
  String toString() => '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
}

enum LocationIssue { serviceOff, denied, deniedForever, failed }

class LocationException implements Exception {
  const LocationException(this.issue, this.message);

  final LocationIssue issue;
  final String message;

  @override
  String toString() => 'LocationException(${issue.name}): $message';
}

abstract interface class LocationService {
  Future<GeoPoint> current();
}

class GeolocatorLocationService implements LocationService {
  @override
  Future<GeoPoint> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(
        LocationIssue.serviceOff,
        'Layanan lokasi perangkat mati.',
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        LocationIssue.deniedForever,
        'Izin lokasi ditolak permanen. Aktifkan dari pengaturan perangkat.',
      );
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      throw const LocationException(LocationIssue.denied, 'Izin lokasi ditolak.');
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return GeoPoint(lat: position.latitude, lon: position.longitude);
    } on Exception catch (e) {
      throw LocationException(LocationIssue.failed, 'Gagal mendapatkan lokasi: $e');
    }
  }
}

/// Menyimpan lokasi terakhir agar jadwal tetap bisa dihitung saat izin ditolak
/// atau perangkat offline.
class LocationStore {
  LocationStore(this._settings);

  final SettingsDao _settings;

  static const _key = 'last_location';

  Future<GeoPoint?> load() async {
    final raw = await _settings.get(_key);
    if (raw == null) return null;
    try {
      return GeoPoint.fromJson((jsonDecode(raw) as Map).cast<String, dynamic>());
    } on Object {
      return null;
    }
  }

  Future<void> save(GeoPoint point) =>
      _settings.set(_key, jsonEncode(point.toJson()));
}
