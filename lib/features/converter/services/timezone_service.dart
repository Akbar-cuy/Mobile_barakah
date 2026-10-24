import 'package:timezone/timezone.dart' as tz;

enum AppZone {
  local('Lokasi'),
  wib('WIB'),
  wita('WITA'),
  wit('WIT'),
  london('London');

  const AppZone(this.label);

  final String label;
}

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
  static const wib = 420;
  static const wita = 480;
  static const wit = 540;

  static const _offsetByName = <String, int>{
    'Asia/Jakarta': wib,
    'Asia/Pontianak': wib,
    'Asia/Makassar': wita,
    'Asia/Jayapura': wit,
    'Asia/Singapore': 480,
    'Asia/Kuala_Lumpur': 480,
    'Asia/Brunei': 480,
    'Asia/Bangkok': 420,
    'Asia/Riyadh': 180,
    'Asia/Dubai': 240,
  };

  static DateTime _lastSunday(int year, int month) {
    final lastDay = DateTime.utc(year, month + 1, 0).day;
    final lastDate = DateTime.utc(year, month, lastDay);
    return DateTime.utc(year, month, lastDay - (lastDate.weekday % 7), 1);
  }

  static int londonOffsetMinutes(DateTime instantUtc) {
    final utc = instantUtc.toUtc();
    final start = _lastSunday(utc.year, 3);
    final end = _lastSunday(utc.year, 10);
    return !utc.isBefore(start) && utc.isBefore(end) ? 60 : 0;
  }

  static int offsetForZoneName(String zoneName, DateTime date) {
    if (zoneName == 'Europe/London') {
      return londonOffsetMinutes(
        DateTime.utc(date.year, date.month, date.day, 12),
      );
    }
    final knownOffset = _offsetByName[zoneName];
    if (knownOffset != null) return knownOffset;
    return DateTime(date.year, date.month, date.day, 12)
        .timeZoneOffset
        .inMinutes;
  }

  static int offsetOf(AppZone zone, DateTime instantUtc, int locationOffset) {
    switch (zone) {
      case AppZone.local:
        return locationOffset;
      case AppZone.wib:
        return wib;
      case AppZone.wita:
        return wita;
      case AppZone.wit:
        return wit;
      case AppZone.london:
        return londonOffsetMinutes(instantUtc);
    }
  }

  static DateTime wallClock(
    AppZone zone,
    DateTime instantUtc,
    int locationOffset,
  ) {
    return instantUtc.toUtc().add(
          Duration(minutes: offsetOf(zone, instantUtc, locationOffset)),
        );
  }

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
