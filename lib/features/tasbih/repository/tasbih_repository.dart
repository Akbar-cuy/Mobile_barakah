// M8 Tasbih Digital (FR-TSB-05, FR-SYNC-01, FR-SYNC-02)
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/outbox_dao.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/utils/date_time_utils.dart';
import '../models/tasbih_log.dart';

abstract interface class TasbihRepository {
  /// Menyimpan atau memperbarui satu sesi dan memasukkannya ke outbox.
  Future<void> save(TasbihLog log);

  /// Seluruh riwayat dari yang terbaru.
  Stream<List<TasbihLog>> watchAll();

  /// Total hitungan hari ini (ringkasan Beranda, FR-LBS-06).
  Stream<int> watchTodayCount();

  /// Total per hari untuk [days] hari terakhir, hanya hari yang ada datanya.
  Future<List<DailyDhikr>> recentDaily({int days = 7});

  /// Menerapkan data dari server (sync pull).
  Future<void> applyRemote(List<Map<String, dynamic>> items);
}

class DriftTasbihRepository implements TasbihRepository {
  DriftTasbihRepository({
    required this.db,
    required this.outbox,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final AppDatabase db;
  final OutboxDao outbox;
  final DateTime Function() _now;

  @override
  Future<void> save(TasbihLog log) {
    return db.transaction(() async {
      final existing = await (db.select(db.tasbihLogTable)
            ..where((t) => t.id.equals(log.id)))
          .getSingleOrNull();
      await db.into(db.tasbihLogTable).insertOnConflictUpdate(
            TasbihLogTableCompanion.insert(
              id: log.id,
              date: log.date,
              target: log.target,
              count: log.count,
              syncState: const Value(SyncState.pending),
            ),
          );
      await outbox.enqueue(
        entity: OutboxEntity.tasbihLog,
        op: existing == null ? OutboxOp.create : OutboxOp.update,
        payload: jsonEncode(log.toPayload()),
        now: _now(),
      );
    });
  }

  @override
  Stream<List<TasbihLog>> watchAll() {
    final query = db.select(db.tasbihLogTable)
      ..orderBy([
        (t) => OrderingTerm.desc(t.date),
      ]);
    return query.watch().map((rows) => [for (final r in rows) TasbihLog.fromRow(r)]);
  }

  @override
  Stream<int> watchTodayCount() {
    final today = DateTimeUtils.dateKey(_now());
    final query = db.select(db.tasbihLogTable)
      ..where((t) => t.date.equals(today));
    return query
        .watch()
        .map((rows) => rows.fold<int>(0, (sum, r) => sum + r.count));
  }

  @override
  Future<List<DailyDhikr>> recentDaily({int days = 7}) async {
    final from = DateTimeUtils.dateKey(_now().subtract(Duration(days: days - 1)));
    final rows = await (db.select(db.tasbihLogTable)
          ..where((t) => t.date.isBiggerOrEqualValue(from)))
        .get();
    final totals = <String, int>{};
    final sessions = <String, int>{};
    for (final r in rows) {
      totals[r.date] = (totals[r.date] ?? 0) + r.count;
      sessions[r.date] = (sessions[r.date] ?? 0) + 1;
    }
    final keys = totals.keys.toList()..sort();
    return [
      for (final k in keys)
        DailyDhikr(date: k, total: totals[k]!, sessions: sessions[k]!),
    ];
  }

  @override
  Future<void> applyRemote(List<Map<String, dynamic>> items) {
    return db.transaction(() async {
      for (final item in items) {
        final TasbihLog remote;
        try {
          remote = TasbihLog.fromJson(item);
        } catch (_) {
          continue; // baris rusak tidak boleh menggagalkan seluruh sinkronisasi
        }
        final local = await (db.select(db.tasbihLogTable)
              ..where((t) => t.id.equals(remote.id)))
            .getSingleOrNull();
        // Perubahan lokal yang belum terkirim tidak ditimpa (FR-SYNC-04).
        if (local != null && local.syncState != SyncState.synced) continue;
        await db.into(db.tasbihLogTable).insertOnConflictUpdate(
              TasbihLogTableCompanion.insert(
                id: remote.id,
                date: remote.date,
                target: remote.target,
                count: remote.count,
                syncState: const Value(SyncState.synced),
              ),
            );
      }
    });
  }
}

/// Menerapkan entity tasbih_log dari GET /sync/pull (FR-SYNC-03).
class TasbihPullHandler implements SyncPullHandler {
  TasbihPullHandler(this._repository);

  final TasbihRepository _repository;

  @override
  String get entity => OutboxEntity.tasbihLog;

  @override
  Future<void> apply(List<Map<String, dynamic>> items) =>
      _repository.applyRemote(items);
}
