// Repository: penghubung antara provider dan service.
// Provider cukup memanggil satu fungsi, urusan lokasi dan API diurus di sini.

import '../models/prayer_times.dart';
import '../services/location_service.dart';
import '../services/prayer_time_service.dart';

class PrayerRepository {
  final LocationService _locationService = LocationService();
  final PrayerTimeService _prayerTimeService = PrayerTimeService();

  Future<PrayerTimes> getTodayTimes() async {
    // 1. Ambil lokasi
    LocationData location = await _locationService.getCurrentLocation();

    // 2. Ambil jadwal sholat untuk lokasi itu
    PrayerTimes times = await _prayerTimeService.fetchTimes(
      location.latitude,
      location.longitude,
      location.city,
    );

    return times;
  }
}