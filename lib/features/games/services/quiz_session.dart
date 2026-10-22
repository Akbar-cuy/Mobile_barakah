import 'dart:math';

import '../models/quiz_attempt.dart';
import '../models/quiz_question.dart';
import '../repository/quiz_repository.dart';

// Rekomendasi kategori dengan alasannya (FR.AI.02 dan FR.AI.04)
class CategoryAdvice {
  final String category;
  final String reason;

  const CategoryAdvice(this.category, this.reason);
}

// AI ringan di perangkat (PRD M14): kesulitan adaptif dan rekomendasi kategori
class QuizAdvisor {
  static const double alpha = 0.3; // bobot EWMA untuk sesi terbaru

  // Akurasi 10 sesi terakhir satu kategori, urutan lama ke baru
  static List<double> recentAccuracies(
    List<QuizAttempt> attempts,
    String category,
  ) {
    final list = attempts.where((a) => a.category == category).toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final recent = list.length > 10 ? list.sublist(list.length - 10) : list;
    return recent.map((a) => a.accuracy).toList();
  }

  // Akurasi tertimbang eksponensial (FR.AI.01). Null bila belum ada riwayat.
  static double? ewma(List<double> values) {
    if (values.isEmpty) return null;
    double result = values.first;
    for (int i = 1; i < values.length; i++) {
      result = alpha * values[i] + (1 - alpha) * result;
    }
    return result;
  }

  // Jumlah soal [mudah, sedang, sulit] dari 10 soal.
  // Akurasi tinggi menaikkan kesulitan, akurasi rendah menurunkannya.
  static List<int> difficultyMix(double? accuracy) {
    if (accuracy == null) return [4, 4, 2];
    if (accuracy >= 0.8) return [2, 4, 4];
    if (accuracy >= 0.5) return [3, 4, 3];
    return [5, 3, 2];
  }

  // Alasan singkat yang bisa dibaca pengguna (FR.AI.04)
  static String difficultyReason(String category, double? accuracy) {
    if (accuracy == null) {
      return 'Belum ada riwayat, soal disusun seimbang.';
    }
    final percent = (accuracy * 100).round();
    final text = 'Akurasi Anda pada $category $percent persen';
    if (accuracy >= 0.8) return '$text, soal sulit ditambah.';
    if (accuracy >= 0.5) return '$text, soal disusun seimbang.';
    return '$text, soal mudah ditambah.';
  }

  // Kategori berikutnya: akurasi terendah dan paling lama tidak dimainkan
  // (FR.AI.02). Kategori yang belum pernah dimainkan didahulukan.
  static CategoryAdvice recommendCategory(List<QuizAttempt> attempts) {
    String bestCategory = QuizCategories.all.first;
    String bestReason = '';
    double bestPriority = -1;

    for (final category in QuizCategories.all) {
      final accuracies = recentAccuracies(attempts, category);
      final avg = ewma(accuracies);

      double priority;
      String reason;

      if (avg == null) {
        priority = 1.5;
        reason = 'Anda belum pernah memainkan kategori ini.';
      } else {
        final played = attempts.where((a) => a.category == category);
        final last = played
            .map((a) => a.createdAt)
            .reduce((a, b) => a.isAfter(b) ? a : b);
        final days = DateTime.now().toUtc().difference(last).inDays;

        priority = (1 - avg) + min(days, 14) / 14 * 0.3;
        reason = 'Akurasi Anda pada $category ${(avg * 100).round()} persen';
        if (days >= 3) reason += ' dan sudah $days hari tidak dimainkan';
        reason += '.';
      }

      if (priority > bestPriority) {
        bestPriority = priority;
        bestCategory = category;
        bestReason = reason;
      }
    }
    return CategoryAdvice(bestCategory, bestReason);
  }
}

// Satu sesi kuis: 10 soal, skor, dan jawaban (FR.GAME.02 dan FR.GAME.04)
class QuizSession {
  static const int questionCount = 10;
  static const int secondsPerQuestion = 20;
  static const int basePoints = 10; // poin dasar tiap jawaban benar
  static const int maxSpeedBonus = 5; // bonus kecepatan maksimal

  final String category;
  final List<QuizQuestion> questions;
  final String reason; // alasan susunan soal (kosong bila rekomendasi mati)

  int index = 0;
  int score = 0;
  int correct = 0;
  int _totalSeconds = 0;
  final List<int?> selected = []; // null = waktu habis

  QuizSession({
    required this.category,
    required this.questions,
    required this.reason,
  });

  // Susun 10 soal acak tanpa duplikat sesuai kesulitan adaptif.
  // accuracy null = belum ada riwayat atau rekomendasi dimatikan.
  factory QuizSession.create({
    required String category,
    required List<QuizQuestion> bank,
    required double? accuracy,
    required String reason,
  }) {
    final random = Random();
    final mix = QuizAdvisor.difficultyMix(accuracy);

    final picked = <QuizQuestion>[];
    final rest = <QuizQuestion>[];

    for (int level = 1; level <= 3; level++) {
      final list = bank.where((q) => q.difficulty == level).toList()
        ..shuffle(random);
      final take = mix[level - 1];
      picked.addAll(list.take(take));
      rest.addAll(list.skip(take));
    }

    // Bila ada tingkat yang kurang soal, isi dari sisa soal
    rest.shuffle(random);
    while (picked.length < questionCount && rest.isNotEmpty) {
      picked.add(rest.removeLast());
    }
    picked.shuffle(random);

    return QuizSession(
      category: category,
      questions: picked.map((q) => q.withShuffledOptions(random)).toList(),
      reason: reason,
    );
  }

  QuizQuestion get current => questions[index];
  int get number => index + 1;
  int get total => questions.length;
  bool get isLast => index >= questions.length - 1;

  // Catat jawaban. choice null berarti waktu habis (dihitung salah).
  // Mengembalikan poin yang didapat.
  int answer(int? choice, int secondsLeft) {
    selected.add(choice);
    _totalSeconds += secondsPerQuestion - secondsLeft;

    if (choice != null && choice == current.answerIndex) {
      correct++;
      final bonus = (secondsLeft / secondsPerQuestion * maxSpeedBonus).round();
      final points = basePoints + bonus;
      score += points;
      return points;
    }
    return 0;
  }

  void next() {
    if (!isLast) index++;
  }

  // Rata-rata detik per soal yang sudah dijawab
  double get avgTime {
    if (selected.isEmpty) return 0;
    return _totalSeconds / selected.length;
  }
}
