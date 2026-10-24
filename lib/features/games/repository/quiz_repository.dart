import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/network/api_client.dart';
import '../../../core/sync/sync_status.dart';
import '../../ai_light/ai_light.dart';
import '../models/quiz_attempt.dart';
import '../models/quiz_question.dart';
import '../services/quiz_session.dart';

class QuizBankUnavailable implements Exception {
  const QuizBankUnavailable();

  @override
  String toString() =>
      'Bank soal belum tersedia. Sambungkan ke internet lalu coba lagi.';
}

class QuizRepository {
  QuizRepository({
    required this.db,
    required this.api,
    Random? random,
  }) : _random = random ?? Random.secure();

  final AppDatabase db;
  final ApiGateway api;
  final Random _random;

  Future<List<QuizQuestion>> loadQuestions(QuizCategory category) async {
    final local = await _localQuestions(category);
    final knownVersion = local.fold<int>(
      0,
      (version, question) => max(version, question.version),
    );
    try {
      final response = await api.request(
        'GET',
        ApiEndpoints.quizQuestions,
        query: {'category': category.id, 'version': knownVersion},
      );
      final items = response['items'];
      if (items is! List || items.length > 500) {
        throw const FormatException('Respons bank soal tidak valid.');
      }
      final questions = items
          .map((item) => QuizQuestion.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(growable: false);
      if (questions.any((question) => question.category != category) ||
          questions.map((question) => question.id).toSet().length !=
              questions.length) {
        throw const FormatException('Respons bank soal tidak valid.');
      }
      if (questions.isNotEmpty) {
        await db.transaction(() async {
          for (final question in questions) {
            await db.into(db.quizQuestionTable).insertOnConflictUpdate(
                  QuizQuestionTableCompanion.insert(
                    id: question.id,
                    category: question.category.id,
                    difficulty: question.difficulty,
                    question: question.question,
                    options: question.optionsJson,
                    answerIndex: question.answerIndex,
                    explanation: question.explanation,
                    version: question.version,
                  ),
                );
          }
        });
      }
      final updated = await _localQuestions(category);
      if (updated.isNotEmpty) return updated;
    } on Object {
      if (local.length >= AppConfig.quizQuestionsPerSession) return local;
      rethrow;
    }
    if (local.length >= AppConfig.quizQuestionsPerSession) return local;
    throw const QuizBankUnavailable();
  }

  Future<List<QuizQuestion>> _localQuestions(QuizCategory category) async {
    final rows = await (db.select(db.quizQuestionTable)
          ..where((table) => table.category.equals(category.id)))
        .get();
    return [
      for (final row in rows)
        QuizQuestion.fromJson({
          'id': row.id,
          'category': row.category,
          'difficulty': row.difficulty,
          'question': row.question,
          'options': row.options,
          'answer_index': row.answerIndex,
          'explanation': row.explanation,
          'version': row.version,
        }),
    ];
  }

  Future<List<QuizAttempt>> attempts() async {
    final rows = await (db.select(db.quizAttemptTable)
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .get();
    return [
      for (final row in rows)
        QuizAttempt(
          id: row.id,
          category: _category(row.category),
          score: row.score,
          correct: row.correct,
          total: row.total,
          averageTimeSeconds: row.avgTimeSeconds ?? 0,
          createdAt: DateTime.parse(row.createdAt).toUtc(),
          syncState: row.syncState,
        ),
    ];
  }

  Future<List<HasilKuis>> adaptiveHistory() async => [
        for (final attempt in await attempts())
          HasilKuis(
            kategori: attempt.category.label,
            benar: attempt.correct,
            total: attempt.total,
            waktu: attempt.createdAt,
          ),
      ];

  Future<int> bestScore(QuizCategory category) async {
    final rows = await (db.select(db.quizAttemptTable)
          ..where((table) => table.category.equals(category.id)))
        .get();
    return rows.fold<int>(0, (best, row) => max(best, row.score));
  }

  Future<QuizSession> startSession(QuizCategory category) async {
    final questions = await loadQuestions(category);
    final history = await adaptiveHistory();
    final composition = const AdaptiveQuizEngine().komposisiSoal(
      category.label,
      history,
    );
    final remaining = List<QuizQuestion>.of(questions);
    final selected = <QuizQuestion>[];
    for (final (difficulty, count) in [
      (1, composition.mudah),
      (2, composition.sedang),
      (3, composition.sulit),
    ]) {
      final pool = remaining
          .where((question) => question.difficulty == difficulty)
          .toList()
        ..shuffle(_random);
      final chosen = pool.take(count).toList();
      selected.addAll(chosen);
      remaining.removeWhere((question) => chosen.contains(question));
    }
    remaining.shuffle(_random);
    if (selected.length < AppConfig.quizQuestionsPerSession) {
      selected.addAll(
          remaining.take(AppConfig.quizQuestionsPerSession - selected.length));
    }
    if (selected.length < AppConfig.quizQuestionsPerSession) {
      throw const QuizBankUnavailable();
    }
    selected.shuffle(_random);
    return QuizSession(questions: selected);
  }

  Future<QuizAttempt> saveAttempt(QuizSession session) async {
    if (!session.isFinished ||
        session.results.length != AppConfig.quizQuestionsPerSession) {
      throw StateError('Sesi kuis belum selesai.');
    }
    final attempt = QuizAttempt(
      id: _uuidV4(_random),
      category: session.questions.first.category,
      score: session.score,
      correct: session.correct,
      total: session.results.length,
      averageTimeSeconds: session.averageTimeSeconds,
      createdAt: DateTime.now().toUtc(),
    );
    final payload = {
      ...attempt.toSyncJson(),
      'answers': [for (final result in session.results) result.toJson()],
    };
    await db.transaction(() async {
      await db.into(db.quizAttemptTable).insert(
            QuizAttemptTableCompanion.insert(
              id: attempt.id,
              category: attempt.category.id,
              score: attempt.score,
              correct: attempt.correct,
              total: attempt.total,
              avgTimeSeconds: Value(attempt.averageTimeSeconds),
              createdAt: attempt.createdAt.toIso8601String(),
              syncState: const Value(SyncState.pending),
            ),
          );
      await db.outboxDao.enqueue(
        entity: OutboxEntity.quizAttempt,
        op: OutboxOp.create,
        payload: jsonEncode(payload),
        now: attempt.createdAt,
      );
    });
    return attempt;
  }

  Future<List<Map<String, dynamic>>> leaderboard(QuizCategory category) async {
    final response = await api.request(
      'GET',
      ApiEndpoints.quizLeaderboard,
      query: {'category': category.id},
    );
    final items = response['items'];
    if (items is! List) throw const FormatException('Papan skor tidak valid.');
    return items.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  static QuizCategory _category(String id) =>
      QuizCategory.values.firstWhere((category) => category.id == id);

  static String _uuidV4(Random random) {
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
