// M4 Beranda (FR-LBS-01). Lokasi perangkat dan lokasi terakhir.
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/database/daos/settings_dao.dart';

class GeoPoint {
  const GeoPoint({
    required this.lat,
    required this.lon,
    this.city = 'Lokasi saya',
    this.isDefault = false,
  });

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      city: json['city'] is String ? json['city'] as String : 'Lokasi saya',
    );
  }

  /// Jakarta, dipakai bila lokasi belum pernah didapat.
  static const defaultPoint = GeoPoint(
    lat: -6.2088,
    lon: 106.8456,
    city: 'Jakarta',
    isDefault: true,
  );

  final double lat;
  final double lon;
  final String city;
  final bool isDefault;

  /// Dibulatkan dua desimal (sekitar 1 km) agar cache dipakai ulang di sekitar lokasi.
  String get locationKey =>
      '${lat.toStringAsFixed(2)},${lon.toStringAsFixed(2)}';

  Map<String, dynamic> toJson() => {'lat': lat, 'lon': lon, 'city': city};

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
  final Geocoding _geocoding = Geocoding();

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
      throw const LocationException(
        LocationIssue.denied,
        'Izin lokasi ditolak.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final city = await _cityName(position.latitude, position.longitude);
      return GeoPoint(
        lat: position.latitude,
        lon: position.longitude,
        city: city,
      );
    } on LocationException {
      rethrow;
    } on Exception catch (error) {
      throw LocationException(
        LocationIssue.failed,
        'Gagal mendapatkan lokasi: $error',
      );
    }
  }

  Future<String> _cityName(double latitude, double longitude) async {
    try {
      final placemarks =
          await _geocoding.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return 'Lokasi saya';
      final place = placemarks.first;
      for (final name in [
        place.locality,
        place.subAdministrativeArea,
        place.administrativeArea,
      ]) {
        if (name != null && name.trim().isNotEmpty) return name.trim();
      }
    } on Exception catch (error) {
      debugPrint('Gagal mendapatkan nama kota: $error');
    }
    return 'Lokasi saya';
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
      return GeoPoint.fromJson(
          (jsonDecode(raw) as Map).cast<String, dynamic>());
    } on Object {
      return null;
    }
  }

  Future<void> save(GeoPoint point) =>
      _settings.set(_key, jsonEncode(point.toJson()));
}
