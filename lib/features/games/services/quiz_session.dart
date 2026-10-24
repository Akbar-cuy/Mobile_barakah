import '../../../core/config/app_config.dart';
import '../models/quiz_question.dart';

class QuizQuestionResult {
  const QuizQuestionResult({
    required this.question,
    required this.selectedIndex,
    required this.elapsedMilliseconds,
  });

  final QuizQuestion question;
  final int? selectedIndex;
  final int elapsedMilliseconds;

  bool get isCorrect => selectedIndex == question.answerIndex;

  Map<String, dynamic> toJson() => {
        'question_id': question.id,
        'selected_index': selectedIndex,
        'elapsed_ms': elapsedMilliseconds,
      };
}

class QuizSession {
  QuizSession({required List<QuizQuestion> questions})
      : questions = List.unmodifiable(questions) {
    if (questions.length != AppConfig.quizQuestionsPerSession ||
        questions.map((q) => q.id).toSet().length != questions.length ||
        questions.map((q) => q.category).toSet().length != 1 ||
        questions.any((q) => q.options.length != 4)) {
      throw ArgumentError('Sesi harus berisi 10 soal unik dari satu kategori.');
    }
  }

  final List<QuizQuestion> questions;
  final List<QuizQuestionResult> results = [];
  int _index = 0;
  int _score = 0;

  int get index => _index;
  int get score => _score;
  int get correct => results.where((result) => result.isCorrect).length;
  bool get isFinished => _index >= questions.length;
  QuizQuestion get current => questions[_index];
  QuizQuestionResult? get currentResult =>
      isFinished || results.isEmpty || results.last.question.id != current.id
          ? null
          : results.last;

  QuizQuestionResult answer({
    required int? selectedIndex,
    required int elapsedMilliseconds,
  }) {
    if (isFinished || currentResult != null) {
      throw StateError('Soal saat ini sudah dijawab atau sesi telah selesai.');
    }
    if (selectedIndex != null &&
        (selectedIndex < 0 || selectedIndex >= current.options.length)) {
      throw RangeError.index(selectedIndex, current.options);
    }
    final elapsed = elapsedMilliseconds
        .clamp(
          0,
          AppConfig.quizTimePerQuestion.inMilliseconds,
        )
        .toInt();
    final result = QuizQuestionResult(
      question: current,
      selectedIndex: selectedIndex,
      elapsedMilliseconds: elapsed,
    );
    results.add(result);
    if (result.isCorrect) {
      final secondsLeft =
          (AppConfig.quizTimePerQuestion.inMilliseconds - elapsed) ~/ 1000;
      _score += 100 + secondsLeft;
    }
    return result;
  }

  void next() {
    if (currentResult == null) {
      throw StateError('Jawab soal atau tunggu waktu habis sebelum lanjut.');
    }
    _index++;
  }

  double get averageTimeSeconds => results.isEmpty
      ? 0
      : results.fold<int>(0, (sum, item) => sum + item.elapsedMilliseconds) /
          results.length /
          1000;
}
