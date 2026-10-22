// M7 Arah Kiblat (FR-QBL)
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/geo_utils.dart';
import '../../worship/services/position_source.dart';
import '../../worship/services/sensor_source.dart';
import '../services/compass_math.dart';
import '../services/heading_filter.dart';
import '../services/qibla_calculator.dart';
import '../services/qibla_sensor_service.dart';

enum QiblaLocationStatus {
  loading,
  ready,
  denied,
  deniedForever,
  serviceDisabled,
  unavailable,
}

class QiblaState {
  const QiblaState({
    this.location = QiblaLocationStatus.loading,
    this.position,
    this.result,
    this.sensor = SensorHealth.starting,
    this.reading,
    this.dialAngle = 0,
    this.difference,
    this.aligned = false,
  });

  final QiblaLocationStatus location;
  final GeoPosition? position;

  /// Sudut kiblat dan jarak ke Ka'bah (AC-QBL-01). Null bila belum ada lokasi.
  final QiblaResult? result;
  final SensorHealth sensor;
  final HeadingReading? reading;

  /// Heading kontinu (tanpa lompatan 360 ke 0) untuk animasi putaran.
  final double dialAngle;

  /// Selisih kiblat dikurangi heading, -180 sampai 180. Positif berarti perlu
  /// memutar ke kanan (searah jarum jam).
  final double? difference;
  final bool aligned;

  bool get hasSensor => sensor == SensorHealth.ok && reading != null;

  CompassAccuracy? get accuracy => reading?.accuracy;

  QiblaState copyWith({
    QiblaLocationStatus? location,
    GeoPosition? position,
    QiblaResult? result,
    SensorHealth? sensor,
    HeadingReading? reading,
    double? dialAngle,
    double? difference,
    bool? aligned,
  }) {
    return QiblaState(
      location: location ?? this.location,
      position: position ?? this.position,
      result: result ?? this.result,
      sensor: sensor ?? this.sensor,
      reading: reading ?? this.reading,
      dialAngle: dialAngle ?? this.dialAngle,
      difference: difference ?? this.difference,
      aligned: aligned ?? this.aligned,
    );
  }
}

class QiblaController extends Notifier<QiblaState> {
  QiblaSensorService? _service;
  StreamSubscription<HeadingReading>? _readingSub;
  StreamSubscription<SensorHealth>? _healthSub;
  final HeadingUnwrapper _unwrapper = HeadingUnwrapper();
  bool _started = false;

  @override
  QiblaState build() {
    ref.onDispose(() => unawaited(_release()));
    return const QiblaState();
  }

  /// Dipanggil saat layar dibuka atau aplikasi kembali aktif.
  Future<void> start({bool askPermission = true}) async {
    if (_started) return;
    _started = true;
    state = const QiblaState();
    await _loadLocation(askPermission: askPermission);
    if (!_started) return;
    _startSensors();
  }

  /// Dipanggil saat layar ditinggalkan atau aplikasi ke latar belakang. Sensor
  /// dilepas (FR-QBL-06, NFR-12).
  Future<void> stop() async {
    _started = false;
    await _release();
  }

  Future<void> retry({bool askPermission = true}) async {
    await stop();
    await start(askPermission: askPermission);
  }

  Future<void> _loadLocation({required bool askPermission}) async {
    final outcome = await ref
        .read(locationResolverProvider)
        .resolve(askPermission: askPermission);
    final position = outcome.position;
    if (position != null) {
      state = state.copyWith(
        location: QiblaLocationStatus.ready,
        position: position,
        result: QiblaCalculator.calculate(position.latitude, position.longitude),
      );
      return;
    }
    state = state.copyWith(
      location: switch (outcome.access) {
        LocationAccess.denied => QiblaLocationStatus.denied,
        LocationAccess.deniedForever => QiblaLocationStatus.deniedForever,
        LocationAccess.serviceDisabled => QiblaLocationStatus.serviceDisabled,
        LocationAccess.granted => QiblaLocationStatus.unavailable,
      },
    );
  }

  void _startSensors() {
    final service = QiblaSensorService(source: ref.read(sensorSourceProvider));
    _service = service;
    _unwrapper.reset();
    _readingSub = service.readings.listen(_onReading);
    _healthSub = service.health.listen(
      (h) => state = state.copyWith(sensor: h),
    );
    service.start();
  }

  void _onReading(HeadingReading reading) {
    final qibla = state.result?.bearing;
    double? difference;
    var aligned = state.aligned;
    if (qibla != null) {
      difference = GeoUtils.angleDifference(qibla, reading.heading);
      const tolerance = AppConfig.qiblaToleranceDegrees;
      if (aligned) {
        // Histeresis supaya status tidak berkedip di tepi toleransi.
        aligned = difference.abs() <= tolerance + 2;
      } else if (difference.abs() <= tolerance) {
        aligned = true;
        unawaited(HapticFeedback.vibrate()); // AC-QBL-03
      }
    }
    state = state.copyWith(
      sensor: SensorHealth.ok,
      reading: reading,
      dialAngle: _unwrapper.unwrap(reading.heading),
      difference: difference,
      aligned: aligned,
    );
  }

  Future<void> _release() async {
    await _readingSub?.cancel();
    await _healthSub?.cancel();
    _readingSub = null;
    _healthSub = null;
    final service = _service;
    _service = null;
    await service?.dispose();
  }
}

final qiblaControllerProvider =
    NotifierProvider<QiblaController, QiblaState>(QiblaController.new);
