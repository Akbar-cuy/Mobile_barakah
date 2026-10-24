import '../../../core/constants/app_constants.dart';

class QuizAttempt {
  const QuizAttempt({
    required this.id,
    required this.category,
    required this.score,
    required this.correct,
    required this.total,
    required this.averageTimeSeconds,
    required this.createdAt,
    this.syncState = 'pending',
  });

  final String id;
  final QuizCategory category;
  final int score;
  final int correct;
  final int total;
  final double averageTimeSeconds;
  final DateTime createdAt;
  final String syncState;

  Map<String, dynamic> toSyncJson() => {
        'id': id,
        'category': category.id,
        'score': score,
        'correct': correct,
        'total': total,
        'avg_time': averageTimeSeconds,
        'created_at': createdAt.toUtc().toIso8601String(),
      };
}
