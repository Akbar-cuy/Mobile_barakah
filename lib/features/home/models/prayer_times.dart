// Model untuk menyimpan jadwal sholat satu hari.
// Semua waktu disimpan sebagai teks berformat "HH:mm", contoh "04:25".

class PrayerTimes {
  final String city;
  final String fajr; // Subuh
  final String sunrise; // Terbit
  final String dhuhr; // Dzuhur
  final String asr; // Ashar
  final String maghrib;
  final String isha; // Isya

  PrayerTimes({
    required this.city,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  // Membuat PrayerTimes dari JSON milik API Aladhan.
  factory PrayerTimes.fromJson(Map<String, dynamic> json, String city) {
    final timings = json['data']['timings'];

    return PrayerTimes(
      city: city,
      fajr: _cleanTime(timings['Fajr']),
      sunrise: _cleanTime(timings['Sunrise']),
      dhuhr: _cleanTime(timings['Dhuhr']),
      asr: _cleanTime(timings['Asr']),
      maghrib: _cleanTime(timings['Maghrib']),
      isha: _cleanTime(timings['Isha']),
    );
  }

  // Kadang API mengirim "04:25 (WIB)". Kita ambil 5 karakter pertama saja.
  static String _cleanTime(String time) {
    return time.substring(0, 5);
  }

  // Semua waktu dalam bentuk Map supaya mudah ditampilkan di ListView.
  Map<String, String> toMap() {
    return {
      'Subuh': fajr,
      'Terbit': sunrise,
      'Dzuhur': dhuhr,
      'Ashar': asr,
      'Maghrib': maghrib,
      'Isya': isha,
    };
  }
}