// M20 Basis Data Lokal, Online, dan Sinkronisasi
// (FR-SYNC-01, FR-SYNC-02, FR-SYNC-06, FR-SYNC-07, FR-OUT-04, FR-OUT-06)
import 'package:drift/drift.dart';

import '../../config/app_config.dart';
import '../app_database.dart';
import '../tables/outbox_table.dart';

part 'outbox_dao.g.dart';

/// Satu item antrean outbox.
typedef OutboxItem = OutboxTableData;


@DriftAccessor(tables: [OutboxTable])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.db);

  /// Menambah item ke antrean. Mengembalikan id baris. [now] untuk pengujian.
  Future<int> enqueue({
    required String entity,
    required String op,
    required String payload,
    DateTime? now,
  }) {
    final t = now ?? DateTime.now();
    return into(outboxTable).insert(
      OutboxTableCompanion.insert(
        entity: entity,
        op: op,
        payload: payload,
        createdAt: t,
        nextAttemptAt: t,
      ),
    );
  }

  /// Item yang boleh dicoba sekarang: waktu percobaan berikutnya sudah tiba
  /// dan jumlah percobaan belum mencapai AppConfig.syncMaxAttempts. Terurut
  /// dari yang terlama.
  Future<List<OutboxItem>> getDue({
    DateTime? now,
    int limit = 50,
    String? entity,
  }) {
    final t = now ?? DateTime.now();
    final query = select(outboxTable)
      ..where((r) {
        final due = r.attempts.isSmallerThanValue(AppConfig.syncMaxAttempts) &
            r.nextAttemptAt.isSmallerOrEqualValue(t);
        return entity == null ? due : due & r.entity.equals(entity);
      })
      ..orderBy([(r) => OrderingTerm.asc(r.id)])
      ..limit(limit);
    return query.get();
  }

  /// Item yang sudah gagal sebanyak batas percobaan dan tidak dicoba lagi
  /// sampai [retryAllNow] dipanggil.
  Future<List<OutboxItem>> getDead() {
    return (select(outboxTable)
          ..where(
            (r) => r.attempts.isBiggerOrEqualValue(AppConfig.syncMaxAttempts),
          )
          ..orderBy([(r) => OrderingTerm.asc(r.id)]))
        .get();
  }


  /// Item yang pernah gagal, untuk ditampilkan di Pengaturan agar penyebabnya
  /// terlihat (entity dan galat terakhir).
  Stream<List<OutboxItem>> watchFailed() {
    return (select(outboxTable)
          ..where((r) => r.attempts.isBiggerThanValue(0))
          ..orderBy([(r) => OrderingTerm.asc(r.id)]))
        .watch();
  }

  Future<void> markSuccess(int id) async {
    await (delete(outboxTable)..where((r) => r.id.equals(id))).go();
  }


  Future<void> markFailure(int id, String error, {DateTime? now}) {
    return transaction(() async {
      final row = await (select(outboxTable)..where((r) => r.id.equals(id)))
          .getSingleOrNull();
      if (row == null) return;
      final attempts = row.attempts + 1;
      final t = now ?? DateTime.now();
      await (update(outboxTable)..where((r) => r.id.equals(id))).write(
        OutboxTableCompanion(
          attempts: Value(attempts),
          lastError: Value(error),
          nextAttemptAt: Value(t.add(AppConfig.syncBackoff(attempts))),
        ),
      );
    });
  }


  Future<void> retryAllNow({DateTime? now}) async {
    await update(outboxTable).write(
      OutboxTableCompanion(
        attempts: const Value(0),
        nextAttemptAt: Value(now ?? DateTime.now()),
      ),
    );
  }

  Future<int> pendingCount() async {
    final total = outboxTable.id.count();
    final query = selectOnly(outboxTable)..addColumns([total]);
    final row = await query.getSingle();
    return row.read(total) ?? 0;
  }


  Stream<int> watchPendingCount() {
    final total = outboxTable.id.count();
    final query = selectOnly(outboxTable)..addColumns([total]);
    return query.map((row) => row.read(total) ?? 0).watchSingle();
  }

  /// Hanya untuk "Hapus data di perangkat ini" saat logout (FR-OUT-04).
  Future<void> clearAll() async {
    await delete(outboxTable).go();
  }
}
