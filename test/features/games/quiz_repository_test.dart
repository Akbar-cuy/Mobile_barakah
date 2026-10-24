import 'dart:convert';

import 'package:barakah/core/constants/app_constants.dart';
import 'package:barakah/core/database/app_database.dart';
import 'package:barakah/core/network/api_client.dart';
import 'package:barakah/core/sync/sync_status.dart';
import 'package:barakah/features/games/repository/quiz_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _QuizApi implements ApiGateway {
  Map<String, dynamic> response = const {'items': []};
  Object? failure;
  final calls = <(String, String, Map<String, Object?>?)>[];

  @override
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Duration? receiveTimeout,
  }) async {
    calls.add((method, path, query));
    if (failure case final failure?) throw failure;
    return response;
  }
}

List<Map<String, dynamic>> _bank({int version = 1}) => [
      for (var index = 0; index < 12; index++)
        {
          'id': '50000000-0000-4000-8000-${index.toString().padLeft(12, '0')}',
          'category': 'umum',
          'difficulty': index % 3 + 1,
          'question': 'Pertanyaan $index',
          'options': ['A', 'B', 'C', 'D'],
          'answer_index': index % 4,
          'explanation': 'Penjelasan $index',
          'version': version,
        },
    ];

void main() {
  late AppDatabase db;
  late _QuizApi api;
  late QuizRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = _QuizApi();
    repository = QuizRepository(db: db, api: api);
  });

  tearDown(() async => db.close());

  test('downloads and caches a valid question bank', () async {
    api.response = {'version': 1, 'items': _bank()};

    final questions = await repository.loadQuestions(QuizCategory.umum);

    expect(questions, hasLength(12));
    expect(api.calls.single.$1, 'GET');
    expect(api.calls.single.$2, '/quiz/questions');
    expect(api.calls.single.$3, {'category': 'umum', 'version': 0});
    expect(await db.select(db.quizQuestionTable).get(), hasLength(12));
  });

  test('uses a valid local bank after an API failure', () async {
    api.response = {'version': 1, 'items': _bank()};
    await repository.loadQuestions(QuizCategory.umum);
    api.failure = StateError('simulated offline');

    expect(await repository.loadQuestions(QuizCategory.umum), hasLength(12));
  });

  test('uses a valid local bank when the response payload is invalid',
      () async {
    api.response = {'version': 1, 'items': _bank()};
    await repository.loadQuestions(QuizCategory.umum);
    api.response = {
      'version': 2,
      'items': [
        {'question': 'invalid'}
      ]
    };

    final questions = await repository.loadQuestions(QuizCategory.umum);

    expect(questions, hasLength(12));
    expect(questions.every((question) => question.version == 1), isTrue);
  });

  test('empty bank response without cache is unavailable, not fabricated',
      () async {
    api.response = const {'version': 0, 'items': []};

    await expectLater(
      repository.loadQuestions(QuizCategory.umum),
      throwsA(isA<QuizBankUnavailable>()),
    );
    expect(await db.select(db.quizQuestionTable).get(), isEmpty);
  });

  test('invalid questions are not partially cached', () async {
    final items = _bank();
    items[5] = {
      ...items[5],
      'options': ['only', 'three', 'options']
    };
    api.response = {'version': 1, 'items': items};

    await expectLater(
      repository.loadQuestions(QuizCategory.umum),
      throwsA(isA<FormatException>()),
    );
    expect(await db.select(db.quizQuestionTable).get(), isEmpty);
  });

  test('session contains ten unique questions selected from the bank',
      () async {
    api.response = {'version': 1, 'items': _bank()};

    final session = await repository.startSession(QuizCategory.umum);

    expect(session.questions, hasLength(10));
    expect(session.questions.map((question) => question.id).toSet(),
        hasLength(10));
  });

  test('saved attempt and answers are persisted with an outbox item', () async {
    api.response = {'version': 1, 'items': _bank()};
    final session = await repository.startSession(QuizCategory.umum);
    for (var index = 0; index < 10; index++) {
      session.answer(
        selectedIndex: session.current.answerIndex,
        elapsedMilliseconds: 1000,
      );
      session.next();
    }

    final attempt = await repository.saveAttempt(session);
    final attempts = await repository.attempts();
    final outbox = await db.outboxDao.getDue(
      now: DateTime.now().add(const Duration(seconds: 1)),
    );
    final payload = jsonDecode(outbox.single.payload) as Map<String, dynamic>;

    expect(attempt.score, 1190);
    expect(attempts.single.id, attempt.id);
    expect(outbox.single.entity, OutboxEntity.quizAttempt);
    expect(payload['answers'], hasLength(10));
  });
}
