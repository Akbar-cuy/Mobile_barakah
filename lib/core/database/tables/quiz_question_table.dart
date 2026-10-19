// M15 Mini Game (FR-GAME-05). Tabel quiz_question.
import 'package:drift/drift.dart';

class QuizQuestionTable extends Table {
  @override
  String get tableName => 'quiz_question';

  TextColumn get id => text()();

  TextColumn get category => text()();

  IntColumn get difficulty => integer()();
  TextColumn get question => text()();

  TextColumn get options => text()();
  IntColumn get answerIndex => integer()();
  TextColumn get explanation => text()();

  IntColumn get version => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
