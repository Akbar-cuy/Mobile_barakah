// M18 Saran dan Kesan (FR-FB-03, FR-FB-05). Tabel feedback_local.
import 'package:drift/drift.dart';

import '../../sync/sync_status.dart';

class FeedbackLocalTable extends Table {
  @override
  String get tableName => 'feedback_local';

  TextColumn get id => text()();
  IntColumn get rating => integer()();
  TextColumn get impression => text()();
  TextColumn get suggestion => text()();
  TextColumn get createdAt => text()();

  TextColumn get updatedAt => text()();
  TextColumn get syncState =>
      text().withDefault(const Constant(SyncState.pending))();

  @override
  Set<Column> get primaryKey => {id};
}
