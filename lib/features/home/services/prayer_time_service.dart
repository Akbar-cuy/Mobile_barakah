// Service untuk:
// 1. mengambil jadwal sholat dari API Aladhan
// 2. mengubah jam ke zona waktu lain (WIB, WITA, WIT, London)
// 3. mencari sholat berikutnya

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prayer_times.dart';

// Menyimpan info sholat berikutnya.
class NextPrayer {
  final String name; // contoh: "Ashar"
  final String timeText; // contoh: "15:08"
  final DateTime time; // waktu lengkap, dipakai untuk hitung mundur

  NextPrayer(this.name, this.timeText, this.time);
}

class PrayerTimeService {
  // Selisih jam terhadap UTC.
  // Catatan: London dianggap UTC+0 (belum menghitung musim panas / BST).
  final Map<String, int> zones = {
    'WIB': 7,
    'WITA': 8,
    'WIT': 9,
    'London': 0,
  };

  // Ambil jadwal dari internet.
  Future<PrayerTimes> fetchTimes(
      double latitude, double longitude, String city) async {
    // method=20 adalah metode Kemenag RI
    final url = Uri.parse(
      'https://api.aladhan.com/v1/timings'
      '?latitude=$latitude&longitude=$longitude&method=20',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil jadwal sholat. Coba lagi nanti.');
    }

    final data = jsonDecode(response.body);
    return PrayerTimes.fromJson(data, city);
  }

  // Mengubah jam "11:45" dari zona perangkat ke zona yang dipilih.
  // Contoh: perangkat di WIB, zona WIT -> 11:45 jadi 13:45.
  String convertZone(String time, String zone) {
    int hour = int.parse(time.substring(0, 2));
    String minute = time.substring(3, 5);

    int deviceOffset = DateTime.now().timeZoneOffset.inHours;
    int zoneOffset = zones[zone] ?? deviceOffset;

    int newHour = (hour + zoneOffset - deviceOffset) % 24;

    String hourText = newHour.toString().padLeft(2, '0');
    return '$hourText:$minute';
  }

  // True kalau zona yang dipilih beda dengan zona perangkat.
  bool isOtherZone(String zone) {
    int deviceOffset = DateTime.now().timeZoneOffset.inHours;
    return zones[zone] != deviceOffset;
  }

  // Mencari sholat berikutnya dari jam sekarang.
  NextPrayer getNextPrayer(PrayerTimes times) {
    DateTime now = DateTime.now();

    // Terbit tidak dihitung sebagai sholat
    Map<String, String> prayers = {
      'Subuh': times.fajr,
      'Dzuhur': times.dhuhr,
      'Ashar': times.asr,
      'Maghrib': times.maghrib,
      'Isya': times.isha,
    };

    for (var entry in prayers.entries) {
      DateTime prayerTime = _toDateTime(entry.value, now);
      if (prayerTime.isAfter(now)) {
        return NextPrayer(entry.key, entry.value, prayerTime);
      }
    }

    // Semua sholat hari ini sudah lewat, berarti Subuh besok.
    DateTime tomorrowSubuh =
        _toDateTime(times.fajr, now).add(const Duration(days: 1));
    return NextPrayer('Subuh', times.fajr, tomorrowSubuh);
  }

  // Mengubah teks "15:08" menjadi DateTime pada tanggal hari ini.
  DateTime _toDateTime(String time, DateTime today) {
    int hour = int.parse(time.substring(0, 2));
    int minute = int.parse(time.substring(3, 5));
    return DateTime(today.year, today.month, today.day, hour, minute);
  }
}
