import 'package:timezone/timezone.dart' as tz;

// Data zona waktu yang didukung (PRD M9)
class ZoneInfo {
  final String label; // WIB, WITA, WIT, London
  final String iana; // nama zona IANA

  const ZoneInfo(this.label, this.iana);
}

const List<ZoneInfo> zoneList = [
  ZoneInfo('WIB', 'Asia/Jakarta'),
  ZoneInfo('WITA', 'Asia/Makassar'),
  ZoneInfo('WIT', 'Asia/Jayapura'),
  ZoneInfo('London', 'Europe/London'),
];

// Hasil konversi waktu untuk satu zona
class TimeResult {
  final String zoneLabel;
  final String time; // contoh: 13:45
  final String abbreviation; // contoh: WIT, GMT, BST
  final String dayNote; // "", "+1 hari", atau "-1 hari"

  TimeResult(this.zoneLabel, this.time, this.abbreviation, this.dayNote);
}

class TimezoneService {
  // Ubah jam dari zona asal ke semua zona.
  // Memakai tanggal hari ini supaya DST London (GMT/BST) benar.
  // Pastikan tz.initializeTimeZones() sudah dipanggil di main().
  List<TimeResult> convertTime({
    required int hour,
    required int minute,
    required ZoneInfo from,
  }) {
    final fromLocation = tz.getLocation(from.iana);
    final now = tz.TZDateTime.now(fromLocation);
    final source = tz.TZDateTime(
      fromLocation,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    final results = <TimeResult>[];
    for (final zone in zoneList) {
      final location = tz.getLocation(zone.iana);
      final converted = tz.TZDateTime.from(source, location);

      // Cek apakah harinya beda dengan zona asal
      final dayDiff = DateTime(converted.year, converted.month, converted.day)
          .difference(DateTime(source.year, source.month, source.day))
          .inDays;
      String note = '';
      if (dayDiff > 0) note = '+1 hari';
      if (dayDiff < 0) note = '-1 hari';

      results.add(TimeResult(
        zone.label,
        formatTime(converted.hour, converted.minute),
        converted.timeZoneName,
        note,
      ));
    }
    return results;
  }

  String formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}