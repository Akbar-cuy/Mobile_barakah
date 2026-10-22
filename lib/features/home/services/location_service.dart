// Service untuk mengambil lokasi pengguna (GPS) dan nama kotanya.
// GPS: package geolocator.
// Nama kota: Nominatim (OpenStreetMap) lewat package http.

import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// Kelas kecil untuk membungkus hasil lokasi.
class LocationData {
  final double latitude;
  final double longitude;
  final String city;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.city,
  });
}

class LocationService {
  Future<LocationData> getCurrentLocation() async {
    // 1. Cek apakah GPS menyala
    bool gpsOn = await Geolocator.isLocationServiceEnabled();
    if (!gpsOn) {
      throw Exception('GPS belum aktif. Nyalakan GPS lalu coba lagi.');
    }

    // 2. Cek izin lokasi, kalau belum ada maka minta
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak. Aktifkan izin di pengaturan.');
    }

    // 3. Ambil koordinat
    Position position = await Geolocator.getCurrentPosition();

    // 4. Ubah koordinat menjadi nama kota
    String city = await _getCityName(position.latitude, position.longitude);

    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      city: city,
    );
  }

  // Mengambil nama kota dari koordinat. Kalau gagal, pakai 'Lokasi saya'.
  Future<String> _getCityName(double latitude, double longitude) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=jsonv2&lat=$latitude&lon=$longitude&zoom=10',
      );

      // Nominatim mewajibkan User-Agent yang mengenali aplikasi kita
      final response = await http.get(
        url,
        headers: {'User-Agent': 'BarakahApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'];

        // Coba beberapa kunci, ambil yang pertama tersedia
        final name = address['city'] ??
            address['town'] ??
            address['municipality'] ??
            address['county'] ??
            address['state'];

        if (name != null) {
          return name.toString();
        }
      }
    } catch (e) {
      // Kalau gagal, lanjut ke nilai bawaan di bawah
    }

    return 'Lokasi saya';
  }
}
