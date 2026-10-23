// M5 Pusat Ibadah (FR-SRC-03, FR-SRC-04) dan M4 (FR-LBS-05).
import 'dart:convert';

import '../../../core/database/daos/settings_dao.dart';

/// Kota yang dipilih pengguna secara manual, dipakai saat izin lokasi
/// ditolak. Disimpan di tabel settings pada kunci [ManualCityStore.key]
/// sebagai JSON {name, lat, lon}, sehingga modul Beranda dapat membacanya juga.
class ManualCity {
  const ManualCity({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory ManualCity.fromJson(Map<String, dynamic> json) {
    return ManualCity(
      name: json['name'].toString(),
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lon'] as num).toDouble(),
    );
  }

  final String name;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => {'name': name, 'lat': latitude, 'lon': longitude};
}

class ManualCityStore {
  ManualCityStore(this._settings);

  final SettingsDao _settings;

  static const String key = 'manual_city';

  Future<ManualCity?> read() async {
    final raw = await _settings.get(key);
    if (raw == null) return null;
    try {
      return ManualCity.fromJson((jsonDecode(raw) as Map).cast<String, dynamic>());
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<void> save(ManualCity city) =>
      _settings.set(key, jsonEncode(city.toJson()));

  Future<void> clear() => _settings.remove(key);
}
