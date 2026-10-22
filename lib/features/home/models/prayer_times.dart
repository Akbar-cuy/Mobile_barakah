// M4 Beranda dan Jadwal Sholat (FR-LBS-03)
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/prayer_cache_dao.dart';

enum PrayerName {
  fajr('Subuh'),
  sunrise('Terbit'),
  dhuhr('Dzuhur'),
  asr('Ashar'),
  maghrib('Maghrib'),
  isha('Isya');

  const PrayerName(this.label);

  final String label;

  /// Terbit bukan waktu sholat wajib, jadi tidak dihitung sebagai sholat berikutnya.
  bool get isObligatory => this != PrayerName.sunrise;

  static List<PrayerName> get obligatory =>
      values.where((p) => p.isObligatory).toList(growable: false);
}

/// Jadwal satu hari untuk satu lokasi dan metode.
class PrayerTimes {
  const PrayerTimes({
    required this.date,
    required this.times,
    required this.utcOffsetMinutes,
    required this.lat,
    required this.lon,
    required this.method,
    required this.locationKey,
  });

  factory PrayerTimes.fromRow(PrayerCacheRow row) {
    return PrayerTimes(
      date: row.date,
      times: {
        PrayerName.fajr: row.fajr,
        PrayerName.sunrise: row.sunrise,
        PrayerName.dhuhr: row.dhuhr,
        PrayerName.asr: row.asr,
        PrayerName.maghrib: row.maghrib,
        PrayerName.isha: row.isha,
      },
      utcOffsetMinutes: row.utcOffsetMinutes,
      lat: row.lat,
      lon: row.lon,
      method: row.method,
      locationKey: row.locationKey,
    );
  }

  /// Format yyyy-MM-dd pada zona lokasi sholat.
  final String date;

  /// Jam dinding lokasi dengan format HH:mm.
  final Map<PrayerName, String> times;

  final int utcOffsetMinutes;
  final double lat;
  final double lon;
  final String method;
  final String locationKey;

  /// Saat sholat sebagai waktu UTC.
  DateTime instant(PrayerName prayer) {
    final d = date.split('-').map(int.parse).toList();
    final t = times[prayer]!.split(':').map(int.parse).toList();
    return DateTime.utc(d[0], d[1], d[2], t[0], t[1])
        .subtract(Duration(minutes: utcOffsetMinutes));
  }

  PrayerCacheTableCompanion toCompanion(DateTime fetchedAt) {
    return PrayerCacheTableCompanion.insert(
      date: date,
      locationKey: locationKey,
      lat: lat,
      lon: lon,
      method: method,
      fajr: times[PrayerName.fajr]!,
      sunrise: times[PrayerName.sunrise]!,
      dhuhr: times[PrayerName.dhuhr]!,
      asr: times[PrayerName.asr]!,
      maghrib: times[PrayerName.maghrib]!,
      isha: times[PrayerName.isha]!,
      utcOffsetMinutes: utcOffsetMinutes,
      fetchedAt: fetchedAt,
    );
  }
}
