// M15 Mini Game (FR-GAME-04). Tabel quiz_attempt.
import 'package:drift/drift.dart';

import '../../sync/sync_status.dart';

class QuizAttemptTable extends Table {
  @override
  String get tableName => 'quiz_attempt';

  TextColumn get id => text()();

  TextColumn get category => text()();
  IntColumn get score => integer()();
  IntColumn get correct => integer()();
  IntColumn get total => integer()();

  RealColumn get avgTimeSeconds => real().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get syncState =>
      text().withDefault(const Constant(SyncState.pending))();

  @override
  Set<Column> get primaryKey => {id};
}
