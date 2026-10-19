// M11 Zakat dan Donasi (FR-ZKT-05, FR-ZKT-06). Tabel donation_local.
import 'package:drift/drift.dart';

import '../../sync/sync_status.dart';

// Nilai uang berupa teks desimal kanonik, sama dengan blok ledger terkait.
class DonationLocalTable extends Table {
  @override
  String get tableName => 'donation_local';

  TextColumn get id => text()();
  TextColumn get campaign => text()();
  TextColumn get amount => text()();
  TextColumn get currency => text()();
  TextColumn get amountIdr => text()();
  TextColumn get rateUsed => text()();

  TextColumn get createdAt => text()();
  TextColumn get syncState =>
      text().withDefault(const Constant(SyncState.pending))();

  @override
  Set<Column> get primaryKey => {id};
}
