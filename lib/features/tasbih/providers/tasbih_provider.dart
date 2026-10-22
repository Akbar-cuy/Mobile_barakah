// M8 Tasbih Digital (FR-TSB-01..05)
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/utils/uuid.dart';
import '../../profile/providers/theme_provider.dart';
import '../../qibla/services/compass_math.dart';
import '../../worship/services/sensor_source.dart';
import '../models/tasbih_log.dart';
import '../repository/tasbih_repository.dart';
import '../services/shake_detector.dart';
import '../services/tasbih_counter.dart';

final tasbihRepositoryProvider = Provider<TasbihRepository>((ref) {
  return DriftTasbihRepository(
    db: ref.watch(appDatabaseProvider),
    outbox: ref.watch(outboxDaoProvider),
  );
});

/// Daftarkan ini di syncPullHandlersProvider agar riwayat ikut tersinkron.
final tasbihPullHandlerProvider = Provider<TasbihPullHandler>(
  (ref) => TasbihPullHandler(ref.watch(tasbihRepositoryProvider)),
);

final tasbihLogsProvider = StreamProvider<List<TasbihLog>>(
  (ref) => ref.watch(tasbihRepositoryProvider).watchAll(),
);

/// Total dzikir hari ini untuk ringkasan Beranda (FR-LBS-06).
final todayDhikrCountProvider = StreamProvider<int>(
  (ref) => ref.watch(tasbihRepositoryProvider).watchTodayCount(),
);

/// Saran target. Ganti lewat override bila modul AI (M14) menyediakannya.
final tasbihSuggestionProvider = FutureProvider<int?>((ref) async {
  final days = await ref.watch(tasbihRepositoryProvider).recentDaily();
  return TasbihSuggestion.fromTotals([for (final d in days) d.total]);
});

enum TasbihMode { shake, tap }

abstract final class _Keys {
  static const mode = 'tasbih_mode';
  static const sensitivity = 'tasbih_sensitivity';
  static const vibrate = 'tasbih_vibrate';
  static const target = 'tasbih_target';
}

class TasbihState {
  const TasbihState({
    required this.sessionId,
    required this.date,
    this.target = 33,
    this.count = 0,
    this.mode = TasbihMode.shake,
    this.sensitivity = ShakeSensitivity.medium,
    this.vibrate = true,
    this.sensorAvailable = true,
  });

  final String sessionId;
  final String date;
  final int target;
  final int count;
  final TasbihMode mode;
  final ShakeSensitivity sensitivity;
  final bool vibrate;

  /// False bila akselerometer tidak ada; layar menyarankan mode ketuk.
  final bool sensorAvailable;

  bool get isCompleted => count >= target;
  double get progress => (count / target).clamp(0.0, 1.0);

  TasbihState copyWith({
    String? sessionId,
    String? date,
    int? target,
    int? count,
    TasbihMode? mode,
    ShakeSensitivity? sensitivity,
    bool? vibrate,
    bool? sensorAvailable,
  }) {
    return TasbihState(
      sessionId: sessionId ?? this.sessionId,
      date: date ?? this.date,
      target: target ?? this.target,
      count: count ?? this.count,
      mode: mode ?? this.mode,
      sensitivity: sensitivity ?? this.sensitivity,
      vibrate: vibrate ?? this.vibrate,
      sensorAvailable: sensorAvailable ?? this.sensorAvailable,
    );
  }
}

class TasbihController extends Notifier<TasbihState> {
  final ShakeDetector _detector = ShakeDetector();
  StreamSubscription<Vec3>? _sub;
  bool _active = false;
  bool _disposed = false;

  @override
  TasbihState build() {
    ref.onDispose(() {
      _disposed = true;
      _sub?.cancel();
    });
    unawaited(_loadSettings());
    return TasbihState(
      sessionId: Uuid4.generate(),
      date: DateTimeUtils.dateKey(DateTime.now()),
    );
  }

  Future<void> _loadSettings() async {
    final dao = ref.read(settingsDaoProvider);
    final mode = await dao.get(_Keys.mode);
    final sens = await dao.get(_Keys.sensitivity);
    final vib = await dao.get(_Keys.vibrate);
    final target = int.tryParse(await dao.get(_Keys.target) ?? '');
    if (_disposed) return;
    final newTarget = target != null && TasbihLimits.isValidTarget(target)
        ? target
        : state.target;
    state = state.copyWith(
      mode: mode == 'tap' ? TasbihMode.tap : TasbihMode.shake,
      sensitivity: ShakeSensitivity.fromId(sens),
      vibrate: vib != 'false',
      // Target hanya dipulihkan bila sesi belum berjalan.
      target: state.count == 0 ? newTarget : state.target,
    );
    _detector.threshold = state.sensitivity.threshold;
    _syncSensor();
  }

  /// Dipanggil layar saat tampil, atau kembali dari latar belakang.
  void activate() {
    _active = true;
    _syncSensor();
  }

  /// Sensor dilepas di latar belakang (hemat baterai) dan hitungan disimpan.
  Future<void> deactivate() async {
    _active = false;
    _syncSensor();
    await flush();
  }

  void _syncSensor() {
    final shouldListen = _active && state.mode == TasbihMode.shake;
    if (!shouldListen) {
      _sub?.cancel();
      _sub = null;
      return;
    }
    if (_sub != null) return;
    _detector.reset();
    try {
      _sub = ref.read(sensorSourceProvider).accelerometer().listen(
        (v) {
          if (_detector.process(v, DateTime.now())) _hit();
        },
        onError: (_) {
          _sub?.cancel();
          _sub = null;
          state = state.copyWith(sensorAvailable: false, mode: TasbihMode.tap);
        },
      );
    } catch (_) {
      state = state.copyWith(sensorAvailable: false, mode: TasbihMode.tap);
    }
  }

  /// Satu hitungan, dari goyangan atau ketukan.
  void _hit() {
    if (state.isCompleted) return;
    final next = state.count + 1;
    state = state.copyWith(count: next);
    if (state.vibrate) {
      if (next >= state.target) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    }
    if (next >= state.target) unawaited(flush());
  }

  void tap() => _hit();

  /// Menyimpan sesi berjalan (bila ada hitungan). Aman dipanggil berulang;
  /// baris yang sama diperbarui karena id sesi tetap.
  Future<void> flush() async {
    if (state.count == 0) return;
    await ref.read(tasbihRepositoryProvider).save(
          TasbihLog(
            id: state.sessionId,
            date: state.date,
            target: state.target,
            count: state.count,
          ),
        );
  }

  /// Mulai sesi baru. Sesi lama disimpan lebih dulu.
  Future<void> reset() async {
    await flush();
    state = state.copyWith(
      sessionId: Uuid4.generate(),
      date: DateTimeUtils.dateKey(DateTime.now()),
      count: 0,
    );
  }

  Future<bool> setTarget(int target) async {
    if (!TasbihLimits.isValidTarget(target)) return false;
    if (state.count > 0) await reset();
    state = state.copyWith(target: target);
    await ref.read(syncedSettingsProvider).set(_Keys.target, '$target');
    return true;
  }

  Future<void> setMode(TasbihMode mode) async {
    state = state.copyWith(mode: mode);
    _syncSensor();
    await ref
        .read(syncedSettingsProvider)
        .set(_Keys.mode, mode == TasbihMode.tap ? 'tap' : 'shake');
  }

  Future<void> setSensitivity(ShakeSensitivity s) async {
    _detector.threshold = s.threshold;
    state = state.copyWith(sensitivity: s);
    await ref.read(syncedSettingsProvider).set(_Keys.sensitivity, s.id);
  }

  Future<void> setVibrate(bool v) async {
    state = state.copyWith(vibrate: v);
    await ref.read(syncedSettingsProvider).set(_Keys.vibrate, '$v');
  }
}

final tasbihControllerProvider =
    NotifierProvider<TasbihController, TasbihState>(TasbihController.new);
