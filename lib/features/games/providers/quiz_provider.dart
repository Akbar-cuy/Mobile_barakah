import 'dart:async';

import 'package:flutter/material.dart';

import '../models/quiz_attempt.dart';
import '../repository/quiz_repository.dart';
import '../services/quiz_session.dart';

// State untuk kuis: pilih kategori, menjawab soal, dan hasil
class QuizProvider extends ChangeNotifier {
  final QuizRepository _repository = QuizRepository.instance;

  Timer? _timer; // hitung mundur 20 detik
  Timer? _advanceTimer; // lanjut otomatis setelah waktu habis
  bool _disposed = false;

  // ---------- State layar kategori ----------
  bool loading = true;
  bool starting = false;
  String? errorText;
  CategoryAdvice? advice; // rekomendasi kategori (null bila dimatikan)

  // ---------- State sesi kuis ----------
  QuizSession? session;
  int secondsLeft = QuizSession.secondsPerQuestion;
  int? selectedIndex; // jawaban yang dipilih, null bila belum atau waktu habis
  bool answered = false;
  bool timedOut = false;
  int lastPoints = 0;

  // ---------- State hasil ----------
  bool saving = false;
  bool finished = false;
  QuizAttempt? result;
  int bestScore = 0; // skor tertinggi kategori setelah sesi ini
  bool isNewBest = false;

  QuizProvider() {
    _load();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _advanceTimer?.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> _load() async {
    await _repository.syncPending();
    _refreshAdvice();
    loading = false;
    notifyListeners();
  }

  // FR.AI.05: rekomendasi bisa dimatikan
  void _refreshAdvice() {
    if (_repository.recommendationsEnabled) {
      advice = QuizAdvisor.recommendCategory(_repository.attempts);
    } else {
      advice = null;
    }
  }

  // =====================================================
  // Layar kategori
  // =====================================================

  List<String> get categories => QuizCategories.all;

  int bestScoreOf(String category) => _repository.bestScore(category);

  String accuracyTextOf(String category) {
    final recent = QuizAdvisor.recentAccuracies(_repository.attempts, category);
    final avg = QuizAdvisor.ewma(recent);
    if (avg == null) return 'Belum dimainkan';
    return 'Akurasi ${(avg * 100).round()} persen';
  }

  // =====================================================
  // Memulai sesi
  // =====================================================

  // Mengembalikan true bila sesi siap dimainkan
  Future<bool> startQuiz(String category) async {
    starting = true;
    errorText = null;
    notifyListeners();

    final bank = await _repository.getQuestions(category);
    if (bank.isEmpty) {
      starting = false;
      errorText = 'Soal untuk kategori ini belum tersedia.';
      notifyListeners();
      return false;
    }

    // Kesulitan adaptif dari riwayat 10 sesi terakhir (FR.AI.01)
    double? accuracy;
    String reason = '';
    if (_repository.recommendationsEnabled) {
      final recent =
          QuizAdvisor.recentAccuracies(_repository.attempts, category);
      accuracy = QuizAdvisor.ewma(recent);
      reason = QuizAdvisor.difficultyReason(category, accuracy);
    }

    session = QuizSession.create(
      category: category,
      bank: bank,
      accuracy: accuracy,
      reason: reason,
    );

    finished = false;
    result = null;
    isNewBest = false;
    saving = false;
    _resetQuestionState();
    starting = false;
    _startTimer();
    notifyListeners();
    return true;
  }

  void _resetQuestionState() {
    selectedIndex = null;
    answered = false;
    timedOut = false;
    lastPoints = 0;
  }

  // =====================================================
  // Menjawab
  // =====================================================

  void _startTimer() {
    _timer?.cancel();
    secondsLeft = QuizSession.secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsLeft--;
      if (secondsLeft <= 0) {
        secondsLeft = 0;
        _onTimeout();
      }
      notifyListeners();
    });
  }

  // Pengguna memilih satu jawaban (FR.GAME.03)
  void answer(int index) {
    final current = session;
    if (current == null || answered) return;

    _timer?.cancel();
    lastPoints = current.answer(index, secondsLeft);
    selectedIndex = index;
    answered = true;
    notifyListeners();
  }

  // Waktu 20 detik habis: dihitung salah, lalu lanjut (AC.GAME.02)
  void _onTimeout() {
    final current = session;
    if (current == null || answered) return;

    _timer?.cancel();
    current.answer(null, 0);
    selectedIndex = null;
    answered = true;
    timedOut = true;
    lastPoints = 0;

    // Beri waktu 3 detik untuk membaca jawaban benar, lalu lanjut sendiri
    _advanceTimer?.cancel();
    _advanceTimer = Timer(const Duration(seconds: 3), nextQuestion);
  }

  // Lanjut ke soal berikutnya, atau selesai bila soal terakhir
  Future<void> nextQuestion() async {
    final current = session;
    if (current == null || !answered || saving || finished) return;

    _advanceTimer?.cancel();

    if (current.isLast) {
      await _finishQuiz();
      return;
    }

    current.next();
    _resetQuestionState();
    _startTimer();
    notifyListeners();
  }

  // Simpan hasil sesi (FR.GAME.04)
  Future<void> _finishQuiz() async {
    final current = session;
    if (current == null) return;

    saving = true;
    notifyListeners();

    final previousBest = _repository.bestScore(current.category);

    final attempt = await _repository.saveAttempt(
      category: current.category,
      score: current.score,
      correct: current.correct,
      total: current.total,
      avgTime: current.avgTime,
    );

    result = attempt;
    bestScore = attempt.score > previousBest ? attempt.score : previousBest;
    isNewBest = attempt.score > previousBest;
    _refreshAdvice();

    saving = false;
    finished = true;
    notifyListeners();
  }

  // Pengguna keluar di tengah sesi: hentikan timer, sesi tidak disimpan
  void cancelQuiz() {
    _timer?.cancel();
    _advanceTimer?.cancel();
    session = null;
    finished = false;
    result = null;
    _resetQuestionState();
    notifyListeners();
  }
}