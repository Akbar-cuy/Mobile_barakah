// M20 Basis Data Lokal, Online, dan Sinkronisasi (FR-SYNC-02, FR-SYNC-05, FR-SYNC-06)
import 'package:drift/drift.dart';


class OutboxTable extends Table {
  @override
  String get tableName => 'outbox';

  IntColumn get id => integer().autoIncrement()();

  /// Lihat OutboxEntity.
  TextColumn get entity => text()();

  /// Lihat OutboxOp.
  TextColumn get op => text()();

  /// Isi perubahan dalam JSON.
  TextColumn get payload => text()();

  DateTimeColumn get createdAt => dateTime()();

  IntColumn get attempts => integer().withDefault(const Constant(0))();

  TextColumn get lastError => text().nullable()();

  /// Saat paling cepat item boleh dicoba lagi.
  DateTimeColumn get nextAttemptAt => dateTime()();
}
