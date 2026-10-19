// M13 Fitur LLM (FR-LLM-08). Tabel chat_message.
import 'package:drift/drift.dart';

import '../../sync/sync_status.dart';

class ChatMessageTable extends Table {
  @override
  String get tableName => 'chat_message';

  TextColumn get id => text()();

  TextColumn get role => text()();
  TextColumn get content => text()();
  TextColumn get createdAt => text()();
  TextColumn get syncState =>
      text().withDefault(const Constant(SyncState.pending))();

  @override
  Set<Column> get primaryKey => {id};
}
