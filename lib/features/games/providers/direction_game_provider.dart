import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../repository/quiz_repository.dart';
import '../services/direction_game_engine.dart';

enum GameStatus { idle, checking, noSensor, playing, finished }

// State untuk game Cari Arah (magnetometer dan gyroscope)
class DirectionGameProvider extends ChangeNotifier {
  static const String gameName = 'cari_arah';

  final QuizRepository _repository = QuizRepository.instance;
  final DirectionGameEngine _engine = DirectionGameEngine();
  final HeadingFilter _filter = HeadingFilter();

  StreamSubscription? _compassSub;
  StreamSubscription? _gyroSub;
  Timer? _loopTimer;
  Timer? _checkTimer;

  double? _magHeading; // heading terakhir dari magnetometer
  double _yawRate = 0; // laju putar terakhir dari gyroscope (derajat per detik)
  DateTime? _lastTick;
  bool _disposed = false;

  GameStatus status = GameStatus.idle;
  double heading = 0; // heading yang sudah dihaluskan
  String message = ''; // hasil target terakhir
  int highScore = 0;
  bool isNewBest = false;

  DirectionGameProvider() {
    highScore = _repository.getGameHighScore(gameName);
  }

  // Sensor harus dilepas saat layar ditinggalkan
  @override
  void dispose() {
    _disposed = true;
    _stopSensors();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  // ---------- Data untuk layar ----------

  String get targetName => _engine.currentTarget.name;
  int get targetNumber => _engine.targetNumber;
  int get targetCount => DirectionGameEngine.targetCount;
  int get secondsLeft => max(0, _engine.timeLeft.ceil());
  double get holdProgress => _engine.holdProgress;
  int get score => _engine.score;

  // Sudut putar panah (radian). Panah menghadap atas bila perangkat
  // sudah menghadap target.
  double get arrowAngle {
    final diff = angleDifference(_engine.currentTarget.bearing, heading);
    return diff * pi / 180;
  }

  // Apakah heading saat ini sudah dalam toleransi
  bool get onTarget {
    final diff = angleDifference(_engine.currentTarget.bearing, heading);
    return diff.abs() <= DirectionGameEngine.toleranceDeg;
  }

  // ---------- Mulai dan berhenti ----------

  Future<void> start() async {
    _stopSensors();
    status = GameStatus.checking;
    message = '';
    isNewBest = false;
    highScore = _repository.getGameHighScore(gameName);
    notifyListeners();

    // Pada perangkat tanpa magnetometer, stream ini bernilai null
    final compassStream = FlutterCompass.events;
    if (compassStream == null) {
      status = GameStatus.noSensor;
      notifyListeners();
      return;
    }

    _magHeading = null;
    _yawRate = 0;
    _lastTick = null;
    _filter.reset();

    _compassSub = compassStream.listen(
      (event) {
        final h = event.heading;
        if (h != null) _magHeading = h;
      },
      onError: (_) {},
    );

    // Gyroscope dipakai untuk menghaluskan. Ponsel dipegang mendatar,
    // putaran searah jarum jam berarti nilai z negatif.
    _gyroSub = gyroscopeEventStream().listen(
      (event) {
        _yawRate = -event.z * 180 / pi;
      },
      onError: (_) {
        _yawRate = 0;
      },
    );

    // Bila 3 detik tidak ada data heading, anggap sensor tidak tersedia
    _checkTimer = Timer(const Duration(seconds: 3), () {
      if (status == GameStatus.checking && _magHeading == null) {
        _stopSensors();
        status = GameStatus.noSensor;
        notifyListeners();
      }
    });

    // 20 pembaruan per detik
    _loopTimer = Timer.periodic(const Duration(milliseconds: 50), _onTick);
  }

  void _stopSensors() {
    _compassSub?.cancel();
    _gyroSub?.cancel();
    _loopTimer?.cancel();
    _checkTimer?.cancel();
    _compassSub = null;
    _gyroSub = null;
    _loopTimer = null;
    _checkTimer = null;
  }

  // Dipanggil layar bila pemain keluar di tengah permainan
  void stop() {
    _stopSensors();
    status = GameStatus.idle;
    notifyListeners();
  }

  // ---------- Putaran permainan ----------

  void _onTick(Timer timer) {
    final mag = _magHeading;
    if (mag == null) return;

    // Heading pertama sudah masuk: putaran dimulai
    if (status == GameStatus.checking) {
      _checkTimer?.cancel();
      _engine.startRound();
      status = GameStatus.playing;
    }

    final now = DateTime.now();
    final last = _lastTick;
    _lastTick = now;
    double dt = 0.05;
    if (last != null) {
      dt = now.difference(last).inMilliseconds / 1000;
      dt = dt.clamp(0.0, 0.2).toDouble();
    }

    heading = _filter.update(mag, _yawRate, dt);

    if (status == GameStatus.playing) {
      final outcome = _engine.update(heading, dt);
      if (outcome != null) {
        if (outcome.success) {
          message = 'Berhasil! +${outcome.points}';
          HapticFeedback.mediumImpact();
        } else {
          message = 'Waktu habis';
        }
        if (_engine.finished) _finish();
      }
    }

    notifyListeners();
  }

  // Putaran selesai: simpan skor tertinggi (FR.GAME.09)
  void _finish() {
    _stopSensors();
    status = GameStatus.finished;

    final finalScore = _engine.score;
    isNewBest = finalScore > highScore;
    if (isNewBest) highScore = finalScore;
    _repository.saveGameScore(gameName, finalScore);
  }
}