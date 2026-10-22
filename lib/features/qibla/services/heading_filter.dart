// M7 Arah Kiblat (FR-QBL-02, AC-QBL-02)
import '../../../core/config/app_config.dart';
import '../../../core/utils/geo_utils.dart';

/// Filter komplementer untuk heading (PRD bagian 9.7):
///
/// ```
/// heading = a * (heading + gyroYawRate * dt) + (1 - a) * magHeading
/// ```
///
/// Gyroscope halus tetapi melayang, magnetometer stabil tetapi berisik. Selisih
/// dihitung melingkar, sehingga perpindahan 359 ke 1 derajat tidak melonjak.
class HeadingFilter {
  HeadingFilter({
    this.alpha = AppConfig.headingFilterAlpha,
    this.alphaWithoutGyro = 0.85,
  });

  /// Bobot gyroscope. Bernilai tinggi agar gerak cepat mulus.
  final double alpha;

  /// Bobot riwayat bila gyroscope tidak tersedia. Lebih rendah agar kompas
  /// tetap tanggap, karena tanpa gyroscope tidak ada prediksi gerak.
  final double alphaWithoutGyro;

  double? _heading;

  /// Heading terakhir (derajat, 0 sampai <360), atau null sebelum ada data.
  double? get heading => _heading;

  void reset() => _heading = null;

  /// [magneticHeading] derajat dari magnetometer. [yawRateDegPerSec] laju
  /// putar searah jarum jam dalam derajat per detik (null bila tidak ada
  /// gyroscope). [dtSeconds] selang sejak pembaruan sebelumnya.
  double update({
    required double magneticHeading,
    double? yawRateDegPerSec,
    required double dtSeconds,
  }) {
    final mag = GeoUtils.normalizeDegrees(magneticHeading);
    final current = _heading;
    if (current == null) {
      _heading = mag;
      return mag;
    }
    final hasGyro = yawRateDegPerSec != null;
    final a = hasGyro ? alpha : alphaWithoutGyro;
    final predicted = hasGyro
        ? GeoUtils.normalizeDegrees(current + yawRateDegPerSec * dtSeconds)
        : current;
    final error = GeoUtils.angleDifference(mag, predicted);
    _heading = GeoUtils.normalizeDegrees(predicted + (1 - a) * error);
    return _heading!;
  }
}

/// Mengubah heading 0 sampai 360 menjadi sudut kontinu tanpa lompatan agar
/// animasi jarum memutar lewat jalur terpendek (359 ke 1 derajat bergerak 2
/// derajat, bukan 358).
class HeadingUnwrapper {
  double? _last;
  double _accumulated = 0;

  double unwrap(double heading) {
    final last = _last;
    if (last == null) {
      _accumulated = heading;
    } else {
      _accumulated += GeoUtils.angleDifference(heading, last);
    }
    _last = heading;
    return _accumulated;
  }

  void reset() {
    _last = null;
    _accumulated = 0;
  }
}
