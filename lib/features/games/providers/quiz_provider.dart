import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../ai_light/ai_light.dart';
import '../models/quiz_attempt.dart';
import '../models/quiz_question.dart';
import '../services/quiz_session.dart';
import '../repository/quiz_repository.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) => QuizRepository(
      db: ref.watch(appDatabaseProvider),
      api: ref.watch(apiGatewayProvider),
    ));

class QuizGameState {
  const QuizGameState({
    this.loading = false,
    this.category,
    this.index = 0,
    this.score = 0,
    this.correct = 0,
    this.remainingSeconds = 20,
    this.selectedIndex,
    this.result,
    this.attempt,
    this.bestScore = 0,
    this.recommendation,
    this.composition,
    this.leaderboard = const [],
    this.error,
    this.finished = false,
  });

  final bool loading;
  final QuizCategory? category;
  final int index;
  final int score;
  final int correct;
  final int remainingSeconds;
  final int? selectedIndex;
  final QuizQuestionResult? result;
  final QuizAttempt? attempt;
  final int bestScore;
  final KategoriSaran? recommendation;
  final KomposisiSoal? composition;
  final List<Map<String, dynamic>> leaderboard;
  final String? error;
  final bool finished;
}

class QuizController extends Notifier<QuizGameState> {
  QuizSession? _session;
  Timer? _timer;
  int _elapsedMilliseconds = 0;
  int _lastShownSecond = 20;
  bool _saving = false;
  QuizAttempt? _pendingAttempt;

  QuizQuestion? get currentQuestion =>
      _session == null || _session!.isFinished ? null : _session!.current;

  @override
  QuizGameState build() {
    ref.onDispose(() => _timer?.cancel());
    return const QuizGameState();
  }

  Future<void> loadOverview() async {
    final repository = ref.read(quizRepositoryProvider);
    try {
      final history = await repository.adaptiveHistory();
      final now = DateTime.now();
      final engine = const AdaptiveQuizEngine();
      final recommendation = engine.kategoriBerikutnya(history, now);
      final category = QuizCategory.values.firstWhere(
        (item) => item.label == recommendation.kategori,
      );
      state = QuizGameState(
        recommendation: recommendation,
        composition: engine.komposisiSoal(category.label, history),
      );
    } on Object catch (error) {
      state = QuizGameState(error: _message(error));
    }
  }

  Future<bool> start(QuizCategory category) async {
    _timer?.cancel();
    _pendingAttempt = null;
    state = QuizGameState(loading: true, category: category);
    try {
      final repository = ref.read(quizRepositoryProvider);
      final session = await repository.startSession(category);
      _session = session;
      final best = await repository.bestScore(category);
      final history = await repository.adaptiveHistory();
      final composition = const AdaptiveQuizEngine().komposisiSoal(
        category.label,
        history,
      );
      state = QuizGameState(
        category: category,
        bestScore: best,
        composition: composition,
      );
      _startTimer();
      return true;
    } on Object catch (error) {
      _session = null;
      state = QuizGameState(category: category, error: _message(error));
      return false;
    }
  }

  void answer(int index) {
    if (_session == null || _session!.currentResult != null || state.finished) {
      return;
    }
    final elapsed = _elapsedMilliseconds.clamp(
      0,
      AppConfig.quizTimePerQuestion.inMilliseconds,
    );
    _timer?.cancel();
    final result = _session!.answer(
      selectedIndex: index,
      elapsedMilliseconds: elapsed,
    );
    _showResult(result);
  }

  void _timeout() {
    final session = _session;
    if (session == null || session.currentResult != null || state.finished) {
      return;
    }
    _timer?.cancel();
    final result = session.answer(
      selectedIndex: null,
      elapsedMilliseconds: AppConfig.quizTimePerQuestion.inMilliseconds,
    );
    _showResult(result);
  }

  void _showResult(QuizQuestionResult result) {
    state = QuizGameState(
      category: state.category,
      index: _session!.index,
      score: _session!.score,
      correct: _session!.correct,
      remainingSeconds: state.remainingSeconds,
      selectedIndex: result.selectedIndex,
      result: result,
      bestScore: state.bestScore,
      composition: state.composition,
    );
  }

  Future<void> next() async {
    final session = _session;
    if (session == null || session.currentResult == null || _saving) return;
    if (session.index + 1 < session.questions.length) {
      session.next();
      state = QuizGameState(
        category: state.category,
        index: session.index,
        score: session.score,
        correct: session.correct,
        bestScore: state.bestScore,
        composition: state.composition,
      );
      _elapsedMilliseconds = 0;
      _startTimer();
      return;
    }

    _saving = true;
    state = QuizGameState(
      loading: true,
      category: state.category,
      index: session.index,
      score: session.score,
      correct: session.correct,
      bestScore: state.bestScore,
      composition: state.composition,
    );
    try {
      session.next();
      final repository = ref.read(quizRepositoryProvider);
      final attempt = _pendingAttempt ??= await repository.saveAttempt(session);
      await ref.read(syncServiceProvider).syncNow();
      final best = await repository.bestScore(attempt.category);
      List<Map<String, dynamic>> leaderboard = const [];
      try {
        leaderboard = await repository.leaderboard(attempt.category);
      } on Object {
        // Offline quiz remains playable and the attempt stays in the outbox.
      }
      state = QuizGameState(
        category: attempt.category,
        index: session.index,
        score: attempt.score,
        correct: attempt.correct,
        attempt: attempt,
        bestScore: best,
        leaderboard: leaderboard,
        finished: true,
      );
    } on Object catch (error) {
      state = QuizGameState(
        category: state.category,
        score: session.score,
        correct: session.correct,
        error: 'Skor belum dapat disimpan: ${_message(error)}',
      );
    } finally {
      _saving = false;
    }
  }

  Future<void> retrySave() async {
    final session = _session;
    if (session == null || !session.isFinished || _saving) return;
    _saving = true;
    state = QuizGameState(
      loading: true,
      category: state.category,
      score: session.score,
      correct: session.correct,
      index: session.index,
    );
    try {
      final repository = ref.read(quizRepositoryProvider);
      final attempt = _pendingAttempt ??= await repository.saveAttempt(session);
      await ref.read(syncServiceProvider).syncNow();
      final best = await repository.bestScore(attempt.category);
      List<Map<String, dynamic>> leaderboard = const [];
      try {
        leaderboard = await repository.leaderboard(attempt.category);
      } on Object {
        // The attempt is saved locally and queued for later sync.
      }
      state = QuizGameState(
        category: attempt.category,
        index: session.index,
        score: attempt.score,
        correct: attempt.correct,
        attempt: attempt,
        bestScore: best,
        leaderboard: leaderboard,
        finished: true,
      );
    } on Object catch (error) {
      state = QuizGameState(
        category: state.category,
        score: session.score,
        correct: session.correct,
        index: session.index,
        error: 'Skor belum dapat disimpan: ${_message(error)}',
      );
    } finally {
      _saving = false;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _elapsedMilliseconds = 0;
    _lastShownSecond = AppConfig.quizTimePerQuestion.inSeconds;
    final started = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_session == null ||
          _session!.currentResult != null ||
          state.finished) {
        timer.cancel();
        return;
      }
      _elapsedMilliseconds = DateTime.now().difference(started).inMilliseconds;
      final remaining =
          (AppConfig.quizTimePerQuestion.inMilliseconds - _elapsedMilliseconds)
              .clamp(0, AppConfig.quizTimePerQuestion.inMilliseconds);
      final seconds = (remaining / 1000).ceil();
      if (seconds != _lastShownSecond) {
        _lastShownSecond = seconds;
        state = QuizGameState(
          category: state.category,
          index: _session!.index,
          score: _session!.score,
          correct: _session!.correct,
          remainingSeconds: seconds,
          bestScore: state.bestScore,
          composition: state.composition,
        );
      }
      if (remaining <= 0) _timeout();
    });
  }

  void leaveQuestion() {
    _timer?.cancel();
    _session = null;
    _saving = false;
  }

  String _message(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}

final quizProvider = NotifierProvider<QuizController, QuizGameState>(
  QuizController.new,
);
