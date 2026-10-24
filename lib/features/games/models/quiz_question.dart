import 'dart:convert';

import '../../../core/constants/app_constants.dart';

class QuizQuestion {
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

  final String id;
  final QuizCategory category;
  final int difficulty;
  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;
  final int version;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final categoryId = json['category'];
    final category = QuizCategory.values.where((c) => c.id == categoryId);
    final rawOptions = json['options'];
    final options = rawOptions is String ? jsonDecode(rawOptions) : rawOptions;
    final question = json['question'];
    final difficulty = json['difficulty'];
    final answerIndex = json['answer_index'];
    final version = json['version'];
    final id = json['id'];
    final explanation = json['explanation'];
    if (id is! String ||
        id.isEmpty ||
        category.isEmpty ||
        difficulty is! int ||
        difficulty < 1 ||
        difficulty > 3 ||
        question is! String ||
        question.trim().isEmpty ||
        options is! List ||
        options.length != 4 ||
        options.any((option) => option is! String || option.trim().isEmpty) ||
        answerIndex is! int ||
        answerIndex < 0 ||
        answerIndex > 3 ||
        explanation is! String ||
        explanation.trim().isEmpty ||
        version is! int ||
        version < 1) {
      throw const FormatException('Data soal kuis tidak valid.');
    }
    return QuizQuestion(
      id: id,
      category: category.first,
      difficulty: difficulty,
      question: question,
      options: List<String>.unmodifiable(options.cast<String>()),
      answerIndex: answerIndex,
      explanation: explanation,
      version: version,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.id,
        'difficulty': difficulty,
        'question': question,
        'options': options,
        'answer_index': answerIndex,
        'explanation': explanation,
        'version': version,
      };

  String get optionsJson => jsonEncode(options);
}
