// M7 Arah Kiblat (FR-QBL-02, FR-QBL-04, FR-QBL-05)
import 'dart:math' as math;

import '../../../core/utils/geo_utils.dart';

/// Vektor tiga sumbu dari sensor. Sumbu perangkat: x ke kanan, y ke atas
/// layar, z keluar dari layar (sama dengan Android dan sensors_plus).
class Vec3 {
  const Vec3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  double get length => math.sqrt(x * x + y * y + z * z);

  @override
  String toString() => 'Vec3($x, $y, $z)';
}

/// Heading kompas dengan kompensasi kemiringan memakai akselerometer
/// (gravitasi) dan magnetometer, mengikuti SensorManager.getRotationMatrix.
abstract final class CompassMath {
  /// Heading magnetik (derajat searah jarum jam dari utara magnetik) dari arah
  /// yang dihadapi perangkat, atau null bila vektor tidak dapat dipakai
  /// (jatuh bebas atau medan magnet hampir nol).
  ///
  /// Ponsel dipegang datar: arah yang dihitung adalah bagian atas ponsel.
  /// Ponsel dipegang tegak: arah yang dihitung adalah bagian belakang ponsel.
  /// Peralihan terjadi saat kemiringan melewati sekitar 45 derajat.
  static double? headingFrom({required Vec3 accel, required Vec3 magnetic}) {
    final aLen = accel.length;
    if (aLen < 1e-6) return null;

    // H = magnetic x accel adalah arah timur dalam koordinat perangkat.
    var hx = magnetic.y * accel.z - magnetic.z * accel.y;
    var hy = magnetic.z * accel.x - magnetic.x * accel.z;
    var hz = magnetic.x * accel.y - magnetic.y * accel.x;
    final hLen = math.sqrt(hx * hx + hy * hy + hz * hz);
    if (hLen < 0.1) return null;
    hx /= hLen;
    hy /= hLen;
    hz /= hLen;

    final ax = accel.x / aLen;
    final ay = accel.y / aLen;
    final az = accel.z / aLen;

    // M = accel x H adalah arah utara dalam koordinat perangkat.
    final my = az * hx - ax * hz;
    final mz = ax * hy - ay * hx;

    final double east;
    final double north;
    if (az.abs() > 0.7) {
      east = hy;
      north = my;
    } else {
      east = -hz;
      north = -mz;
    }
    return GeoUtils.normalizeDegrees(math.atan2(east, north) * 180 / math.pi);
  }

  /// Laju putar heading (derajat per detik, searah jarum jam positif) dari
  /// gyroscope [gyro] dalam rad/s. Hanya komponen di sekitar sumbu vertikal
  /// yang mengubah heading, jadi diproyeksikan ke arah gravitasi [accel].
  static double? yawRateDegPerSec({required Vec3 gyro, required Vec3 accel}) {
    final aLen = accel.length;
    if (aLen < 1e-6) return null;
    final aroundUp =
        (gyro.x * accel.x + gyro.y * accel.y + gyro.z * accel.z) / aLen;
    // Putaran berlawanan arah jarum jam (dari atas) bernilai positif pada
    // sumbu vertikal, sedangkan heading bertambah searah jarum jam.
    return -aroundUp * 180 / math.pi;
  }
}

/// Tingkat keandalan pembacaan kompas (FR-QBL-04).
enum CompassAccuracy {
  high('Tinggi'),
  medium('Sedang'),
  low('Rendah'),
  unreliable('Terganggu');

  const CompassAccuracy(this.label);

  final String label;

  /// Banner kalibrasi tampil pada akurasi rendah ke bawah (AC-QBL-04).
  bool get needsCalibration =>
      this == CompassAccuracy.low || this == CompassAccuracy.unreliable;
}

abstract final class CompassQuality {
  /// Kuat medan magnet bumi di permukaan sekitar 25 sampai 65 mikrotesla.
  static const double normalMin = 25;
  static const double normalMax = 65;

  /// Di luar rentang ini hampir pasti ada gangguan magnet (FR-QBL-05).
  static const double interferenceMin = 15;
  static const double interferenceMax = 80;

  /// Simpangan baku kuat medan (mikrotesla) di atas ini berarti ponsel belum
  /// terkalibrasi atau ada logam bergerak di dekatnya.
  static const double noisyDeviation = 4;
  static const double veryNoisyDeviation = 8;

  /// [strength] kuat medan terbaru, [recent] sampel terakhir (sekitar 1 detik).
  static CompassAccuracy evaluate({
    required double strength,
    required List<double> recent,
  }) {
    if (strength < interferenceMin || strength > interferenceMax) {
      return CompassAccuracy.unreliable;
    }
    final deviation = _standardDeviation(recent);
    if (deviation > veryNoisyDeviation) return CompassAccuracy.unreliable;
    if (strength < normalMin || strength > normalMax) {
      return CompassAccuracy.low;
    }
    if (deviation > noisyDeviation) return CompassAccuracy.low;
    if (deviation > noisyDeviation / 2) return CompassAccuracy.medium;
    return CompassAccuracy.high;
  }

  static bool hasInterference(double strength) =>
      strength < interferenceMin || strength > interferenceMax;

  static double _standardDeviation(List<double> values) {
    if (values.length < 2) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values
            .map((v) => (v - mean) * (v - mean))
            .reduce((a, b) => a + b) /
        values.length;
    return math.sqrt(variance);
  }
}
