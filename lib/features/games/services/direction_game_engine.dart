import 'dart:math';

// ---------- Fungsi sudut ----------

// Ubah sudut ke rentang 0 sampai 360
double normalizeAngle(double angle) => (angle % 360 + 360) % 360;

// Selisih terpendek dari heading ke target, rentang -180 sampai 180.
// Positif berarti target ada di sisi kanan (searah jarum jam).
double angleDifference(double target, double heading) {
  double d = (target - heading) % 360;
  if (d < 0) d += 360;
  if (d > 180) d -= 360;
  return d;
}

// Arah (bearing) dari satu titik ke titik lain, rumus yang sama dengan
// perhitungan kiblat di PRD M7
double bearingBetween(
  double latFrom,
  double lonFrom,
  double latTo,
  double lonTo,
) {
  final lat1 = latFrom * pi / 180;
  final lat2 = latTo * pi / 180;
  final dLon = (lonTo - lonFrom) * pi / 180;
  final y = sin(dLon) * cos(lat2);
  final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
  return (atan2(y, x) * 180 / pi + 360) % 360;
}

// ---------- Filter heading (FR.GAME.08) ----------

// Filter komplementer dari PRD M7:
// heading = a * (heading + gyroYawRate * dt) + (1 - a) * magHeading
class HeadingFilter {
  final double alpha;
  double? _heading;

  HeadingFilter({this.alpha = 0.98});

  void reset() => _heading = null;

  // yawRateDeg: laju putar dalam derajat per detik, searah jarum jam positif
  double update(double magHeading, double yawRateDeg, double dt) {
    final mag = normalizeAngle(magHeading);
    final current = _heading;
    if (current == null) {
      _heading = mag;
      return mag;
    }
    final predicted = current + yawRateDeg * dt;
    final error = angleDifference(mag, predicted);
    final result = normalizeAngle(predicted + (1 - alpha) * error);
    _heading = result;
    return result;
  }
}

// ---------- Target dan hasil ----------

class DirectionTarget {
  final String name;
  final double bearing;

  const DirectionTarget(this.name, this.bearing);
}

// Hasil satu target: berhasil atau waktu habis
class TargetOutcome {
  final bool success;
  final int points;

  const TargetOutcome(this.success, this.points);
}

// ---------- Mesin game Cari Arah (FR.GAME.06 dan FR.GAME.07) ----------

class DirectionGameEngine {
  static const int targetCount = 5; // target per putaran
  static const double secondsPerTarget = 15;
  static const double holdSeconds = 2; // harus ditahan 2 detik
  static const double toleranceDeg = 5; // toleransi 5 derajat

  // Posisi acuan: Yogyakarta.
  // TODO: ganti dengan lokasi pengguna dari layanan lokasi.
  static const double refLat = -7.7956;
  static const double refLon = 110.3695;

  // Arah target dihitung dari posisi acuan
  static final List<DirectionTarget> pool = [
    DirectionTarget(
      'KIBLAT',
      bearingBetween(refLat, refLon, 21.4225, 39.8262),
    ),
    const DirectionTarget('UTARA', 0),
    DirectionTarget(
      'BANJARMASIN',
      bearingBetween(refLat, refLon, -3.3194, 114.5908),
    ),
    DirectionTarget(
      'MAKASSAR',
      bearingBetween(refLat, refLon, -5.1477, 119.4327),
    ),
    DirectionTarget(
      'KUPANG',
      bearingBetween(refLat, refLon, -10.1772, 123.6070),
    ),
    DirectionTarget(
      'MEDAN',
      bearingBetween(refLat, refLon, 3.5952, 98.6722),
    ),
  ];

  final Random _random = Random();

  List<DirectionTarget> targets = [];
  int targetIndex = 0;
  int score = 0;
  double timeLeft = secondsPerTarget;
  double holdTime = 0;
  bool finished = false;

  double _errorSum = 0;
  int _errorCount = 0;

  DirectionTarget get currentTarget => targets[targetIndex];
  int get targetNumber => targetIndex + 1;
  double get holdProgress => (holdTime / holdSeconds).clamp(0.0, 1.0);

  // Mulai putaran baru: 5 target acak tanpa duplikat
  void startRound() {
    final list = List<DirectionTarget>.from(pool)..shuffle(_random);
    targets = list.take(targetCount).toList();
    targetIndex = 0;
    score = 0;
    finished = false;
    _resetTarget();
  }

  void _resetTarget() {
    timeLeft = secondsPerTarget;
    holdTime = 0;
    _errorSum = 0;
    _errorCount = 0;
  }

  // Dipanggil berkala dengan heading yang sudah dihaluskan.
  // Mengembalikan hasil bila satu target selesai, kalau belum null.
  TargetOutcome? update(double heading, double dt) {
    if (finished) return null;

    timeLeft -= dt;
    final error = angleDifference(currentTarget.bearing, heading).abs();

    if (error <= toleranceDeg) {
      holdTime += dt;
      _errorSum += error;
      _errorCount++;
    } else {
      // Keluar dari toleransi: hitungan tahan mulai dari nol lagi
      holdTime = 0;
      _errorSum = 0;
      _errorCount = 0;
    }

    // Berhasil menahan 2 detik (AC.GAME.04)
    if (holdTime >= holdSeconds) {
      final points = _calculatePoints();
      score += points;
      return _moveToNext(true, points);
    }

    // Waktu habis, tanpa poin
    if (timeLeft <= 0) {
      return _moveToNext(false, 0);
    }
    return null;
  }

  // Skor per target maksimal 100: kecepatan 60 + ketepatan 40
  int _calculatePoints() {
    final remaining = max(0.0, timeLeft);
    final speedPoints = (remaining / secondsPerTarget * 60).round();

    final avgError = _errorCount == 0 ? 0.0 : _errorSum / _errorCount;
    final accuracyPoints = ((1 - avgError / toleranceDeg) * 40).round();

    return speedPoints + accuracyPoints;
  }

  TargetOutcome _moveToNext(bool success, int points) {
    if (targetIndex >= targets.length - 1) {
      finished = true;
    } else {
      targetIndex++;
      _resetTarget();
    }
    return TargetOutcome(success, points);
  }
}
