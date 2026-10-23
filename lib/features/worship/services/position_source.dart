// M4, M6, M7. Satu-satunya tempat yang memanggil geolocator.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/providers/app_providers.dart';
import 'manual_city.dart';

class GeoPosition {
  const GeoPosition({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    this.label,
    this.isManual = false,
  });

  final double latitude;
  final double longitude;
  final double? accuracyMeters;

  /// Nama tempat, misalnya kota pilihan manual.
  final String? label;

  /// Bukan dari GPS, melainkan kota yang dipilih pengguna (FR-LBS-05).
  final bool isManual;
}

enum LocationAccess { granted, denied, deniedForever, serviceDisabled }

abstract interface class PositionSource {
  Future<LocationAccess> access();

  /// Meminta izin lokasi dengan dialog sistem bila belum diputuskan.
  Future<LocationAccess> requestAccess();

  /// Posisi GPS saat ini, atau null bila tidak tersedia atau waktu habis.
  Future<GeoPosition?> current();

  Future<GeoPosition?> lastKnown();

  Stream<GeoPosition> stream({int distanceFilterMeters = 25});

  Future<void> openAppSettings();

  Future<void> openLocationSettings();
}

class GeolocatorPositionSource implements PositionSource {
  const GeolocatorPositionSource();

  static GeoPosition _map(Position p) => GeoPosition(
        latitude: p.latitude,
        longitude: p.longitude,
        accuracyMeters: p.accuracy,
      );

  static LocationAccess _accessOf(LocationPermission p) {
    switch (p) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationAccess.granted;
      case LocationPermission.deniedForever:
        return LocationAccess.deniedForever;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationAccess.denied;
    }
  }

  @override
  Future<LocationAccess> access() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationAccess.serviceDisabled;
    }
    return _accessOf(await Geolocator.checkPermission());
  }

  @override
  Future<LocationAccess> requestAccess() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationAccess.serviceDisabled;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return _accessOf(permission);
  }

  @override
  Future<GeoPosition?> current() async {
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return _map(p);
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<GeoPosition?> lastKnown() async {
    try {
      final p = await Geolocator.getLastKnownPosition();
      return p == null ? null : _map(p);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<GeoPosition> stream({int distanceFilterMeters = 25}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: distanceFilterMeters,
      ),
    ).map(_map);
  }

  @override
  Future<void> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
}

final positionSourceProvider =
    Provider<PositionSource>((ref) => const GeolocatorPositionSource());

final manualCityStoreProvider = Provider<ManualCityStore>(
  (ref) => ManualCityStore(ref.watch(settingsDaoProvider)),
);

/// Mencari posisi untuk fitur yang butuh koordinat: GPS bila diizinkan,
/// bila tidak, kota pilihan manual (FR-LBS-05).
class LocationResolver {
  LocationResolver({required this.source, required this.manualCity});

  final PositionSource source;
  final ManualCityStore manualCity;

  /// Hasilnya [LocationOutcome.position] bila ada koordinat, atau status
  /// izin bila tidak ada sumber sama sekali.
  Future<LocationOutcome> resolve({bool askPermission = true}) async {
    var access = await source.access();
    if (access == LocationAccess.denied && askPermission) {
      access = await source.requestAccess();
    }
    if (access == LocationAccess.granted) {
      final gps = await source.current() ?? await source.lastKnown();
      if (gps != null) return LocationOutcome.found(gps);
    }
    final city = await manualCity.read();
    if (city != null) {
      return LocationOutcome.found(
        GeoPosition(
          latitude: city.latitude,
          longitude: city.longitude,
          label: city.name,
          isManual: true,
        ),
      );
    }
    return LocationOutcome.missing(access);
  }
}

class LocationOutcome {
  const LocationOutcome._(this.position, this.access);

  factory LocationOutcome.found(GeoPosition p) =>
      LocationOutcome._(p, LocationAccess.granted);

  factory LocationOutcome.missing(LocationAccess access) =>
      LocationOutcome._(null, access);

  final GeoPosition? position;

  /// Status izin saat tidak ada posisi. granted berarti izin ada tetapi GPS
  /// belum memberi hasil.
  final LocationAccess access;
}

final locationResolverProvider = Provider<LocationResolver>((ref) {
  return LocationResolver(
    source: ref.watch(positionSourceProvider),
    manualCity: ref.watch(manualCityStoreProvider),
  );
});
