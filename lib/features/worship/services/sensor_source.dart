// M7 Kiblat, M8 Tasbih, M15 Cari Arah. Satu-satunya tempat yang memanggil
// sensors_plus, sehingga logika di atasnya dapat diuji dengan sumber palsu.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../qibla/services/compass_math.dart';

abstract interface class SensorSource {
  /// Percepatan termasuk gravitasi, m/s^2.
  Stream<Vec3> accelerometer();

  /// Medan magnet, mikrotesla.
  Stream<Vec3> magnetometer();

  /// Laju putar, rad/s.
  Stream<Vec3> gyroscope();
}

class SensorsPlusSource implements SensorSource {
  const SensorsPlusSource({this.interval = SensorInterval.uiInterval});

  /// Selang pembaruan. uiInterval sekitar 16 Hz, memenuhi NFR-02 (minimal 10 Hz).
  final Duration interval;

  @override
  Stream<Vec3> accelerometer() => accelerometerEventStream(samplingPeriod: interval)
      .map((e) => Vec3(e.x, e.y, e.z));

  @override
  Stream<Vec3> magnetometer() => magnetometerEventStream(samplingPeriod: interval)
      .map((e) => Vec3(e.x, e.y, e.z));

  @override
  Stream<Vec3> gyroscope() => gyroscopeEventStream(samplingPeriod: interval)
      .map((e) => Vec3(e.x, e.y, e.z));
}

final sensorSourceProvider =
    Provider<SensorSource>((ref) => const SensorsPlusSource());
