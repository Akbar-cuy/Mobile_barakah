// M8 Tasbih Digital (FR-TSB-05). Tabel tasbih_log.
import 'package:drift/drift.dart';

import '../../sync/sync_status.dart';

class TasbihLogTable extends Table {
  @override
  String get tableName => 'tasbih_log';

  TextColumn get id => text()();

  TextColumn get date => text()();
  IntColumn get target => integer()();
  IntColumn get count => integer()();
  TextColumn get syncState =>
      text().withDefault(const Constant(SyncState.pending))();

  @override
  Set<Column> get primaryKey => {id};
}
