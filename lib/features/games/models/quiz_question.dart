import 'dart:math';

// Satu soal kuis (PRD M15, tabel quiz_question)
class QuizQuestion {
  final String id;
  final String category;
  final int difficulty; // 1 mudah, 2 sedang, 3 sulit
  final String question;
  final List<String> options; // 4 pilihan
  final int answerIndex; // indeks jawaban benar di options
  final String explanation;
  final int version;

  const QuizQuestion({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
    required this.version,
  });

  // Acak urutan pilihan supaya posisi jawaban tidak bisa dihafal
  QuizQuestion withShuffledOptions(Random random) {
    final order = List<int>.generate(options.length, (i) => i)..shuffle(random);
    return QuizQuestion(
      id: id,
      category: category,
      difficulty: difficulty,
      question: question,
      options: [for (final i in order) options[i]],
      answerIndex: order.indexOf(answerIndex),
      explanation: explanation,
      version: version,
    );
  }
}