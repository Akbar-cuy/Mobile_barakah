// M9 Konversi Waktu (FR-TZ). Aturan zona untuk WIB, WITA, WIT, dan London.
// Dipakai lebih dulu oleh Beranda untuk menampilkan jadwal sholat di zona lain.

enum AppZone {
  local('Lokasi'),
  wib('WIB'),
  wita('WITA'),
  wit('WIT'),
  london('London');

  const AppZone(this.label);

  final String label;
}

/// London memakai aturan BST: dari Minggu terakhir Maret pukul 01.00 UTC sampai
/// Minggu terakhir Oktober pukul 01.00 UTC.
abstract final class TimezoneService {
  static const wib = 420;
  static const wita = 480;
  static const wit = 540;

  static const _byName = <String, int>{
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
    final u = instantUtc.toUtc();
    final start = _lastSunday(u.year, 3);
    final end = _lastSunday(u.year, 10);
    final summer = !u.isBefore(start) && u.isBefore(end);
    return summer ? 60 : 0;
  }

  /// Selisih UTC (menit) untuk nama zona IANA pada tanggal tertentu. Zona yang
  /// tidak dikenal memakai selisih perangkat pada tanggal itu.
  static int offsetForZoneName(String zoneName, DateTime date) {
    if (zoneName == 'Europe/London') {
      return londonOffsetMinutes(DateTime.utc(date.year, date.month, date.day, 12));
    }
    final known = _byName[zoneName];
    if (known != null) return known;
    return DateTime(date.year, date.month, date.day, 12).timeZoneOffset.inMinutes;
  }

  /// [locationOffset] adalah selisih UTC lokasi sholat, dipakai oleh [AppZone.local].
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

  /// Waktu dinding pada zona itu. Hasilnya bertanda UTC dan hanya dipakai untuk
  /// membaca jam dan menit.
  static DateTime wallClock(AppZone zone, DateTime instantUtc, int locationOffset) {
    return instantUtc.toUtc().add(
          Duration(minutes: offsetOf(zone, instantUtc, locationOffset)),
        );
  }
}
