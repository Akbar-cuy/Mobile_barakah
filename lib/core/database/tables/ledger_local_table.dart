// M12 Blockchain Sederhana (FR-BLK) dan M20 (FR-SYNC). Tabel ledger_local.
import 'package:drift/drift.dart';

import '../../sync/sync_status.dart';

class LedgerLocalTable extends Table {
  @override
  String get tableName => 'ledger_local';

  IntColumn get idx => integer()();
  TextColumn get timestamp => text()();
  TextColumn get donorAlias => text()();
  TextColumn get campaign => text()();
  TextColumn get amount => text()();

  /// IDR, USD, atau SAR (lihat AppCurrency.code). Divalidasi di kode.
  TextColumn get currency => text()();
  TextColumn get amountIdr => text()();
  TextColumn get rateUsed => text()();
  TextColumn get prevHash => text()();
  IntColumn get nonce => integer()();
  TextColumn get hash => text().unique()();

  /// SyncState.pending, synced, atau failed.
  TextColumn get syncState =>
      text().withDefault(const Constant(SyncState.pending))();

  @override
  Set<Column> get primaryKey => {idx};
}
