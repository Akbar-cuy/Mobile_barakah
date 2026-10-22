// Hasil satu sesi kuis (PRD M15, tabel quiz_attempt)
class QuizAttempt {
  // Nilai sync_state sesuai PRD
  static const String statePending = 'pending';
  static const String stateSynced = 'synced';
  static const String stateFailed = 'failed';

  final String id;
  final String category;
  final int score;
  final int correct;
  final int total;
  final double avgTime; // rata-rata detik per soal
  final DateTime createdAt; // disimpan sebagai UTC
  final String syncState;

  const QuizAttempt({
    required this.id,
    required this.category,
    required this.score,
    required this.correct,
    required this.total,
    required this.avgTime,
    required this.createdAt,
    required this.syncState,
  });

  // Akurasi 0 sampai 1
  double get accuracy => total == 0 ? 0 : correct / total;

  QuizAttempt copyWith({String? syncState}) {
    return QuizAttempt(
      id: id,
      category: category,
      score: score,
      correct: correct,
      total: total,
      avgTime: avgTime,
      createdAt: createdAt,
      syncState: syncState ?? this.syncState,
    );
  }
}