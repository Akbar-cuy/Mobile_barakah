// M7 Arah Kiblat (FR-QBL-02, FR-QBL-04, FR-QBL-05, FR-QBL-06)
import 'dart:async';

import '../../worship/services/sensor_source.dart';
import 'compass_math.dart';
import 'heading_filter.dart';

/// Keadaan sensor kompas.
enum SensorHealth {
  /// Menunggu data pertama.
  starting,
  ok,

  /// Magnetometer atau akselerometer tidak ada, atau tidak memberi data
  /// (AC-QBL-05). Layar kembali ke sudut statis.
  unavailable,
}

class HeadingReading {
  const HeadingReading({
    required this.heading,
    required this.magneticHeading,
    required this.fieldStrength,
    required this.accuracy,
    required this.hasGyro,
  });

  /// Heading halus (derajat, 0 sampai <360) hasil filter komplementer.
  final double heading;

  /// Heading mentah dari magnetometer.
  final double magneticHeading;

  /// Kuat medan magnet, mikrotesla.
  final double fieldStrength;
  final CompassAccuracy accuracy;
  final bool hasGyro;

  bool get interference => CompassQuality.hasInterference(fieldStrength);
}

/// Menggabungkan akselerometer, magnetometer, dan gyroscope menjadi heading
/// halus. Langganan sensor hanya aktif antara [start] dan [stop], sehingga
/// sensor dilepas saat layar ditinggalkan (FR-QBL-06, NFR-12).
class QiblaSensorService {
  QiblaSensorService({
    required SensorSource source,
    HeadingFilter? filter,
    DateTime Function()? clock,
    this.noDataTimeout = const Duration(seconds: 2),
  })  : _source = source,
        _filter = filter ?? HeadingFilter(),
        _now = clock ?? DateTime.now;

  final SensorSource _source;
  final HeadingFilter _filter;
  final DateTime Function() _now;

  /// Bila tidak ada pembacaan dalam waktu ini setelah [start], sensor
  /// dianggap tidak tersedia.
  final Duration noDataTimeout;

  final _readings = StreamController<HeadingReading>.broadcast();
  final _health = StreamController<SensorHealth>.broadcast();

  StreamSubscription<Vec3>? _accelSub;
  StreamSubscription<Vec3>? _magSub;
  StreamSubscription<Vec3>? _gyroSub;
  Timer? _timeout;

  Vec3? _accel;
  Vec3? _gyro;
  DateTime? _lastUpdate;
  final List<double> _recentStrength = [];
  SensorHealth _current = SensorHealth.starting;

  static const int _strengthWindow = 16;

  Stream<HeadingReading> get readings => _readings.stream;
  Stream<SensorHealth> get health => _health.stream;
  SensorHealth get currentHealth => _current;
  bool get isRunning => _magSub != null;

  void start() {
    if (isRunning) return;
    _filter.reset();
    _accel = null;
    _gyro = null;
    _lastUpdate = null;
    _recentStrength.clear();
    _setHealth(SensorHealth.starting);

    _accelSub = _source.accelerometer().listen(
      (v) => _accel = v,
      onError: (_) => _setHealth(SensorHealth.unavailable),
    );
    _magSub = _source.magnetometer().listen(
      _onMagnetometer,
      onError: (_) => _setHealth(SensorHealth.unavailable),
    );
    // Gyroscope opsional: tanpa itu filter memakai magnetometer saja.
    _gyroSub = _source.gyroscope().listen(
      (v) => _gyro = v,
      onError: (_) => _gyro = null,
    );
    _timeout = Timer(noDataTimeout, () {
      if (_current == SensorHealth.starting) {
        _setHealth(SensorHealth.unavailable);
      }
    });
  }

  /// Melepas semua langganan sensor.
  Future<void> stop() async {
    _timeout?.cancel();
    _timeout = null;
    final subs = [_accelSub, _magSub, _gyroSub];
    _accelSub = null;
    _magSub = null;
    _gyroSub = null;
    for (final s in subs) {
      await s?.cancel();
    }
  }

  Future<void> dispose() async {
    await stop();
    await _readings.close();
    await _health.close();
  }

  void _onMagnetometer(Vec3 mag) {
    final accel = _accel;
    if (accel == null) return;

    final magHeading = CompassMath.headingFrom(accel: accel, magnetic: mag);
    if (magHeading == null) return;

    final strength = mag.length;
    _recentStrength.add(strength);
    if (_recentStrength.length > _strengthWindow) _recentStrength.removeAt(0);

    final now = _now();
    final last = _lastUpdate;
    _lastUpdate = now;
    var dt = last == null ? 0.0 : now.difference(last).inMicroseconds / 1e6;
    if (dt < 0 || dt > 0.5) dt = 0;

    final gyro = _gyro;
    final yawRate =
        gyro == null ? null : CompassMath.yawRateDegPerSec(gyro: gyro, accel: accel);

    final heading = _filter.update(
      magneticHeading: magHeading,
      yawRateDegPerSec: yawRate,
      dtSeconds: dt,
    );

    _setHealth(SensorHealth.ok);
    if (_readings.isClosed) return;
    _readings.add(
      HeadingReading(
        heading: heading,
        magneticHeading: magHeading,
        fieldStrength: strength,
        accuracy: CompassQuality.evaluate(
          strength: strength,
          recent: List.unmodifiable(_recentStrength),
        ),
        hasGyro: yawRate != null,
      ),
    );
  }

  void _setHealth(SensorHealth next) {
    if (_current == next) return;
    _current = next;
    if (!_health.isClosed) _health.add(next);
  }
}
