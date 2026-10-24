import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/providers/app_providers.dart';
import '../../qibla/services/qibla_calculator.dart';
import '../../qibla/services/qibla_sensor_service.dart';
import '../../worship/services/position_source.dart';
import '../../worship/services/sensor_source.dart';
import '../repository/game_score_repository.dart';
import '../services/direction_game_engine.dart';

final gameScoreRepositoryProvider = Provider<GameScoreRepository>(
  (ref) => GameScoreRepository(db: ref.watch(appDatabaseProvider)),
);

enum DirectionGamePhase { idle, loading, playing, finished, unavailable }

class DirectionGameState {
  const DirectionGameState({
    this.phase = DirectionGamePhase.idle,
    this.targets = const [],
    this.targetIndex = 0,
    this.remainingSeconds = 15,
    this.heading,
    this.errorDegrees,
    this.holdProgress = 0,
    this.score = 0,
    this.bestScore = 0,
    this.successes = 0,
    this.sensorHealth = SensorHealth.starting,
    this.message,
  });

  final DirectionGamePhase phase;
  final List<DirectionTarget> targets;
  final int targetIndex;
  final int remainingSeconds;
  final double? heading;
  final double? errorDegrees;
  final double holdProgress;
  final int score;
  final int bestScore;
  final int successes;
  final SensorHealth sensorHealth;
  final String? message;

  DirectionTarget? get target =>
      targetIndex < targets.length ? targets[targetIndex] : null;
}

class DirectionGameController extends Notifier<DirectionGameState> {
  final _engine = const DirectionGameEngine();
  final _random = Random.secure();
  QiblaSensorService? _sensorService;
  StreamSubscription<HeadingReading>? _readingSubscription;
  StreamSubscription<SensorHealth>? _healthSubscription;
  Timer? _timer;
  DateTime? _targetStartedAt;
  DateTime? _withinSince;
  DateTime? _lastHeadingAt;
  double? _lastError;
  bool _disposed = false;
  bool _finishing = false;
  int _generation = 0;
  final DateTime Function() _clock = DateTime.now;

  @override
  DirectionGameState build() {
    ref.onDispose(() {
      _disposed = true;
      unawaited(_releaseSensors());
    });
    return const DirectionGameState();
  }

  Future<void> start() async {
    await stop();
    if (_disposed) return;
    final generation = ++_generation;
    state = const DirectionGameState(phase: DirectionGamePhase.loading);
    try {
      final outcome =
          await ref.read(locationResolverProvider).resolve(askPermission: true);
      if (_disposed || generation != _generation) return;
      final position = outcome.position;
      if (position == null) {
        state = DirectionGameState(
          phase: DirectionGamePhase.unavailable,
          message: switch (outcome.access) {
            LocationAccess.denied =>
              'Izin lokasi diperlukan untuk menghitung arah Kiblat dan kota. Izinkan lokasi lalu coba lagi.',
            LocationAccess.deniedForever =>
              'Izin lokasi ditolak permanen. Aktifkan dari Pengaturan Android atau pilih kota di fitur Jadwal Sholat.',
            LocationAccess.serviceDisabled =>
              'Layanan lokasi mati. Aktifkan lokasi atau pilih kota di fitur Jadwal Sholat.',
            LocationAccess.granted =>
              'Lokasi belum tersedia. Coba lagi atau pilih kota di fitur Jadwal Sholat.',
          },
          sensorHealth: SensorHealth.unavailable,
        );
        return;
      }
      final qibla = QiblaCalculator.calculate(
        position.latitude,
        position.longitude,
      );
      final targets = _engine.createTargets(
        qiblaBearing: qibla.bearing,
        latitude: position.latitude,
        longitude: position.longitude,
        random: _random,
      );
      final best = await ref.read(gameScoreRepositoryProvider).directionBest();
      if (_disposed || generation != _generation) return;
      state = DirectionGameState(
        phase: DirectionGamePhase.playing,
        targets: targets,
        bestScore: best,
      );
      _startTargetClock();
      _startSensors();
    } on Object catch (error) {
      if (_disposed || generation != _generation) return;
      state = DirectionGameState(
        phase: DirectionGamePhase.unavailable,
        message: 'Game tidak dapat dimulai: ${error.runtimeType}. Coba lagi.',
        sensorHealth: SensorHealth.unavailable,
      );
    }
  }

  void _startSensors() {
    final generation = _generation;
    final service = QiblaSensorService(
      source: ref.read(sensorSourceProvider),
    );
    _sensorService = service;
    _readingSubscription = service.readings.listen(
      (reading) {
        if (generation == _generation) _onReading(reading);
      },
      onError: (_) {
        if (generation == _generation) _sensorUnavailable();
      },
    );
    _healthSubscription = service.health.listen((health) {
      if (_disposed || generation != _generation) return;
      state = _copy(sensorHealth: health);
      if (health == SensorHealth.unavailable) _sensorUnavailable();
    });
    service.start();
  }

  void _onReading(HeadingReading reading) {
    if (_disposed || state.phase != DirectionGamePhase.playing) return;
    final target = state.target;
    if (target == null) return;
    final now = _clock();
    final error = _engine.errorDegrees(target.bearing, reading.heading);
    _lastHeadingAt = now;
    _lastError = error;
    if (_engine.isWithinTolerance(target.bearing, reading.heading)) {
      _withinSince ??= now;
    } else {
      _withinSince = null;
    }
    state = _copy(
      heading: reading.heading,
      errorDegrees: error,
      sensorHealth: SensorHealth.ok,
    );
  }

  void _startTargetClock() {
    _timer?.cancel();
    _targetStartedAt = _clock();
    _withinSince = null;
    _lastHeadingAt = null;
    _lastError = null;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
  }

  void _tick() {
    if (_disposed || state.phase != DirectionGamePhase.playing) return;
    final now = _clock();
    final started = _targetStartedAt ?? now;
    final elapsed = now.difference(started);
    final remaining = (AppConfig.directionGameTimePerTarget - elapsed)
        .inMilliseconds
        .clamp(0, AppConfig.directionGameTimePerTarget.inMilliseconds);
    final holdSince = _withinSince;
    final lastHeading = _lastHeadingAt;
    final freshReading = lastHeading != null &&
        now.difference(lastHeading) < const Duration(seconds: 1);
    if (!freshReading) _withinSince = null;
    final holdMs = holdSince == null || !freshReading
        ? 0
        : now.difference(holdSince).inMilliseconds;
    state = _copy(
      remainingSeconds: (remaining / 1000).ceil(),
      holdProgress:
          (holdMs / AppConfig.directionGameHold.inMilliseconds).clamp(0.0, 1.0),
    );
    if (holdMs >= AppConfig.directionGameHold.inMilliseconds) {
      final score = _engine.scoreTarget(
        errorDegrees: _lastError ?? AppConfig.directionGameToleranceDegrees,
        elapsed: elapsed,
      );
      unawaited(_advanceTarget(success: true, points: score));
    } else if (remaining == 0) {
      unawaited(_advanceTarget(success: false, points: 0));
    }
  }

  Future<void> _advanceTarget(
      {required bool success, required int points}) async {
    if (state.phase != DirectionGamePhase.playing) return;
    final nextIndex = state.targetIndex + 1;
    final score = state.score + points;
    final successes = state.successes + (success ? 1 : 0);
    if (nextIndex >= state.targets.length) {
      await _finish(score, successes);
      return;
    }
    state = DirectionGameState(
      phase: DirectionGamePhase.playing,
      targets: state.targets,
      targetIndex: nextIndex,
      remainingSeconds: AppConfig.directionGameTimePerTarget.inSeconds,
      score: score,
      bestScore: state.bestScore,
      successes: successes,
      sensorHealth: state.sensorHealth,
    );
    _startTargetClock();
  }

  Future<void> _finish(int score, int successes) async {
    if (_finishing) return;
    _finishing = true;
    _timer?.cancel();
    await _releaseSensors();
    var best = state.bestScore;
    try {
      await ref.read(gameScoreRepositoryProvider).saveDirectionBest(score);
      await ref.read(syncServiceProvider).syncNow();
      best = await ref.read(gameScoreRepositoryProvider).directionBest();
    } on Object {
      // A completed local game remains visible even if saving the record fails.
    }
    if (!_disposed) {
      state = DirectionGameState(
        phase: DirectionGamePhase.finished,
        targets: state.targets,
        targetIndex: state.targets.length,
        remainingSeconds: 0,
        score: score,
        bestScore: best,
        successes: successes,
        sensorHealth: state.sensorHealth,
        message: 'Skor tinggi dikirim saat sinkronisasi tersedia.',
      );
    }
    _finishing = false;
  }

  void _sensorUnavailable() {
    if (_disposed || state.phase != DirectionGamePhase.playing) return;
    _timer?.cancel();
    unawaited(_releaseSensors());
    state = DirectionGameState(
      phase: DirectionGamePhase.unavailable,
      message:
          'Sensor kompas tidak tersedia. Coba Kuis Islami sebagai alternatif.',
      sensorHealth: SensorHealth.unavailable,
      bestScore: state.bestScore,
    );
  }

  Future<void> stop() async {
    _generation++;
    _timer?.cancel();
    _timer = null;
    await _releaseSensors();
    if (!_disposed && state.phase == DirectionGamePhase.playing) {
      state = const DirectionGameState(
        phase: DirectionGamePhase.idle,
        message: 'Permainan dihentikan.',
      );
    }
  }

  Future<void> _releaseSensors() async {
    await _readingSubscription?.cancel();
    await _healthSubscription?.cancel();
    _readingSubscription = null;
    _healthSubscription = null;
    final service = _sensorService;
    _sensorService = null;
    await service?.dispose();
  }

  DirectionGameState _copy({
    double? heading,
    double? errorDegrees,
    double? holdProgress,
    int? remainingSeconds,
    SensorHealth? sensorHealth,
  }) =>
      DirectionGameState(
        phase: state.phase,
        targets: state.targets,
        targetIndex: state.targetIndex,
        remainingSeconds: remainingSeconds ?? state.remainingSeconds,
        heading: heading ?? state.heading,
        errorDegrees: errorDegrees ?? state.errorDegrees,
        holdProgress: holdProgress ?? state.holdProgress,
        score: state.score,
        bestScore: state.bestScore,
        successes: state.successes,
        sensorHealth: sensorHealth ?? state.sensorHealth,
        message: state.message,
      );
}

final directionGameProvider =
    NotifierProvider<DirectionGameController, DirectionGameState>(
  DirectionGameController.new,
);
