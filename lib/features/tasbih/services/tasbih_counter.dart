// M8 Tasbih Digital (FR-TSB-02, AC-TSB-03)

/// Penghitung satu sesi dzikir. Tanpa ketergantungan pada Flutter.
class TasbihCounter {
  TasbihCounter({required this.id, required this.target, required this.date})
      : assert(target > 0);

  /// UUID sesi. Satu sesi menjadi satu baris riwayat (FR-TSB-05).
  final String id;
  int target;

  /// Tanggal lokal sesi dimulai (yyyy-MM-dd).
  final String date;
  int _count = 0;

  int get count => _count;

  bool get isCompleted => _count >= target;

  double get progress => (_count / target).clamp(0.0, 1.0);

  /// Menambah satu hitungan. Mengembalikan true tepat saat target tercapai.
  /// Setelah target tercapai hitungan berhenti sampai sesi baru dimulai.
  bool increment() {
    if (isCompleted) return false;
    _count++;
    return isCompleted;
  }
}

/// Rentang target yang diterima pada pilihan kustom (FR-TSB-02).
abstract final class TasbihLimits {
  static const int minTarget = 1;
  static const int maxTarget = 9999;

  static bool isValidTarget(int v) => v >= minTarget && v <= maxTarget;
}

/// Saran target harian dari rata-rata riwayat (wireframe 11.7: "rata-rata
/// 7 hari terakhir"). Ini perhitungan sederhana. Bila modul AI ringan (M14)
/// sudah tersedia, ganti lewat override tasbihSuggestionProvider.
abstract final class TasbihSuggestion {
  static const List<int> presets = [33, 99, 100];

  /// [dailyTotals] jumlah hitungan per hari yang ada datanya (maksimal 7).
  /// Null bila belum ada riwayat.
  static int? fromTotals(List<int> dailyTotals) {
    final days = dailyTotals.where((t) => t > 0).toList();
    if (days.isEmpty) return null;
    final average = days.reduce((a, b) => a + b) / days.length;
    var best = presets.first;
    for (final p in presets) {
      if ((p - average).abs() < (best - average).abs()) best = p;
    }
    return best;
  }
}
