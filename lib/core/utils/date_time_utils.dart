// Fondasi lintas fitur. Format waktu dan tanggal (FR-TZ-07: simpan UTC).
abstract final class DateTimeUtils {
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static String two(int n) => n.toString().padLeft(2, '0');

  static String hm(DateTime t) => '${two(t.hour)}.${two(t.minute)}';

  static String hms(Duration d) {
    final s = d.inSeconds < 0 ? 0 : d.inSeconds;
    return '${two(s ~/ 3600)}:${two((s ~/ 60) % 60)}:${two(s % 60)}';
  }

  static String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${two(d.month)}-${two(d.day)}';

  static String toIsoUtcSeconds(DateTime t) {
    final u = t.toUtc();
    return '${u.year.toString().padLeft(4, '0')}-${two(u.month)}-${two(u.day)}'
        'T${two(u.hour)}:${two(u.minute)}:${two(u.second)}Z';
  }

  static DateTime parseIso(String s) => DateTime.parse(s).toUtc();

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
