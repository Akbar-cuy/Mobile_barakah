// M8 Tasbih Digital (FR-TSB-01, FR-TSB-03, AC-TSB-01, AC-TSB-02)
import '../../../core/config/app_config.dart';
import '../../qibla/services/compass_math.dart';

/// Sensitivitas goyang (FR-TSB-03). Ambang dalam m/s^2 pada percepatan
/// total termasuk gravitasi (sekitar 9,8 saat diam), jadi semua ambang harus
/// di atas itu. Makin rendah ambang, makin mudah terhitung.
enum ShakeSensitivity {
  low('rendah', 'Rendah', 20),
  medium('sedang', 'Sedang', AppConfig.shakeThreshold),
  high('tinggi', 'Tinggi', 12);

  const ShakeSensitivity(this.id, this.label, this.threshold);

  final String id;
  final String label;
  final double threshold;

  static ShakeSensitivity fromId(String? id) {
    for (final s in values) {
      if (s.id == id) return s;
    }
    return ShakeSensitivity.medium;
  }
}

/// Satu goyangan dihitung bila magnitudo percepatan melewati ambang, dengan
/// jeda minimal [debounce] antar hitungan (FR-TSB-01).
class ShakeDetector {
  ShakeDetector({
    this.threshold = AppConfig.shakeThreshold,
    this.debounce = AppConfig.shakeDebounce,
  });

  /// Dapat diubah saat berjalan ketika pengguna mengganti sensitivitas.
  double threshold;
  final Duration debounce;

  DateTime? _lastShake;

  /// Mengembalikan true bila sampel ini dihitung sebagai satu goyangan.
  /// [now] diberikan pemanggil agar mudah diuji.
  bool process(Vec3 sample, DateTime now) {
    if (sample.length <= threshold) return false;
    final last = _lastShake;
    if (last != null && now.difference(last) < debounce) return false;
    _lastShake = now;
    return true;
  }

  void reset() => _lastShake = null;
}
