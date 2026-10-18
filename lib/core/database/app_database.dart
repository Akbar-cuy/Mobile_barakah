
import 'package:drift/drift.dart';

import '../constants/app_constants.dart';

import '../sync/sync_status.dart';
import 'daos/ledger_dao.dart';
import 'daos/outbox_dao.dart';
import 'tables/ledger_local_table.dart';
import 'tables/outbox_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [LedgerLocalTable, OutboxTable],
  daos: [LedgerDao, OutboxDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => AppConstants.databaseSchemaVersion;
}
