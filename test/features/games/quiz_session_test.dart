import 'package:barakah/core/constants/app_constants.dart';
import 'package:barakah/features/games/models/quiz_question.dart';
import 'package:barakah/features/games/services/quiz_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final questions = List.generate(
    10,
    (index) => QuizQuestion(
      id: 'question-$index',
      category: QuizCategory.umum,
      difficulty: index % 3 + 1,
      question: 'Question $index',
      options: const ['A', 'B', 'C', 'D'],
      answerIndex: 2,
      explanation: 'Rujukan sumber lokal.',
      version: 1,
    ),
  );

  test('session requires ten unique questions from one category', () {
    expect(QuizSession(questions: questions).questions, hasLength(10));
    expect(
      () => QuizSession(questions: questions.take(9).toList()),
      throwsArgumentError,
    );
    expect(
      () => QuizSession(questions: [...questions.take(9), questions.first]),
      throwsArgumentError,
    );
  });

  test('correct answer receives speed bonus; timeout is wrong and advances',
      () {
    final session = QuizSession(questions: questions);
    final first = session.answer(
      selectedIndex: 2,
      elapsedMilliseconds: 0,
    );
    expect(first.isCorrect, isTrue);
    expect(session.score, 120);
    expect(() => session.answer(selectedIndex: 2, elapsedMilliseconds: 10),
        throwsStateError);

    session.next();
    final timedOut = session.answer(
      selectedIndex: null,
      elapsedMilliseconds: 20000,
    );
    expect(timedOut.isCorrect, isFalse);
    expect(session.correct, 1);
    expect(session.score, 120);
    expect(session.averageTimeSeconds, 10);

    for (var i = 2; i < 10; i++) {
      session.next();
      session.answer(selectedIndex: null, elapsedMilliseconds: 20000);
    }
    session.next();
    expect(session.isFinished, isTrue);
    expect(session.results, hasLength(10));
  });
}
