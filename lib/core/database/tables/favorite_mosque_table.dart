// M6 Masjid Terdekat (FR-LBS-12). Tabel favorite_mosque.
import 'package:drift/drift.dart';

import '../../sync/sync_status.dart';

class FavoriteMosqueTable extends Table {
  @override
  String get tableName => 'favorite_mosque';

  TextColumn get id => text()();

  TextColumn get osmId => text().unique()();
  TextColumn get name => text()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  TextColumn get syncState =>
      text().withDefault(const Constant(SyncState.pending))();

  @override
  Set<Column> get primaryKey => {id};
}
