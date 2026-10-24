// M12 Blockchain Sederhana (FR-BLK-01, FR-BLK-02, FR-BLK-04, FR-BLK-10, FR-BLK-11)
// dan M20 (FR-SYNC-01, FR-SYNC-02).
import 'package:drift/drift.dart';

import '../../constants/app_constants.dart';
import '../../sync/sync_status.dart';
import '../app_database.dart';
import '../tables/ledger_local_table.dart';

part 'ledger_dao.g.dart';

/// Satu baris blok pada ledger lokal.
typedef LedgerBlockRow = LedgerLocalTableData;

/// Dilempar saat blok baru tidak menyambung ke rantai yang ada.
class LedgerAppendException implements Exception {
  const LedgerAppendException(this.message);

  final String message;

  @override
  String toString() => 'LedgerAppendException: $message';
}

@DriftAccessor(tables: [LedgerLocalTable])
class LedgerDao extends DatabaseAccessor<AppDatabase> with _$LedgerDaoMixin {
  LedgerDao(super.db);

  /// Daftar blok dari yang terbaru, untuk layar Ledger (FR-BLK-10).
  Stream<List<LedgerBlockRow>> watchAll() {
    return (select(ledgerLocalTable)
          ..orderBy([(t) => OrderingTerm.desc(t.idx)]))
        .watch();
  }

  /// Seluruh blok dari yang terlama, untuk Verifikasi Rantai (FR-BLK-04).
  Future<List<LedgerBlockRow>> getAllAscending() {
    return (select(ledgerLocalTable)
          ..orderBy([(t) => OrderingTerm.asc(t.idx)]))
        .get();
  }

  /// Blok terakhir (head rantai), atau null bila rantai masih kosong.
  Future<LedgerBlockRow?> getLatest() {
    return (select(ledgerLocalTable)
          ..orderBy([(t) => OrderingTerm.desc(t.idx)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<LedgerBlockRow?> getByIndex(int idx) {
    return (select(ledgerLocalTable)..where((t) => t.idx.equals(idx)))
        .getSingleOrNull();
  }

  Future<int> count() async {
    final total = ledgerLocalTable.idx.count();
    final query = selectOnly(ledgerLocalTable)..addColumns([total]);
    final row = await query.getSingle();
    return row.read(total) ?? 0;
  }

  /// Menambahkan blok di ujung rantai (FR-BLK-02). Seluruhnya dalam satu
  /// transaksi: indeks harus tepat setelah blok terakhir dan prev_hash harus
  /// sama dengan hash blok terakhir. Untuk rantai kosong, indeks harus
  /// AppConstants.ledgerGenesisIndex dan prev_hash AppConstants.ledgerGenesisPrevHash.
  ///
  /// Gunakan LedgerLocalTableCompanion.insert agar semua bidang terisi.
  Future<void> appendBlock(LedgerLocalTableCompanion block) {
    return transaction(() async {
      final head = await getLatest();
      final expectedIdx =
          head == null ? AppConstants.ledgerGenesisIndex : head.idx + 1;
      final expectedPrev =
          head == null ? AppConstants.ledgerGenesisPrevHash : head.hash;

      if (block.idx.value != expectedIdx) {
        throw LedgerAppendException(
          'Indeks blok ${block.idx.value} tidak sesuai, seharusnya $expectedIdx.',
        );
      }
      if (block.prevHash.value != expectedPrev) {
        throw const LedgerAppendException(
          'prev_hash tidak sama dengan hash blok terakhir.',
        );
      }
      await into(ledgerLocalTable).insert(block);
    });
  }

  /// Blok yang belum terkirim ke server, dari yang terlama (FR-SYNC-02).
  Future<List<LedgerBlockRow>> getUnsynced() {
    return (select(ledgerLocalTable)
          ..where(
            (t) => t.syncState.isIn([SyncState.pending, SyncState.failed]),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.idx)]))
        .get();
  }

  Future<void> markSynced(int idx) => _setSyncState(idx, SyncState.synced);

  Future<void> markFailed(int idx) => _setSyncState(idx, SyncState.failed);

  /// Roll back a donation block only when it is still the local pending head.
  /// A newly-created genesis is removed with it when no other block depends on it.
  Future<void> rollbackPendingDonation({
    required int idx,
    int? genesisIndex,
  }) {
    return transaction(() async {
      final head = await getLatest();
      final donation = await getByIndex(idx);
      if (head?.idx != idx ||
          donation == null ||
          donation.syncState == SyncState.synced) {
        throw const LedgerAppendException(
          'Donasi lokal tidak dapat dibatalkan karena ledger sudah berubah.',
        );
      }
      await (delete(ledgerLocalTable)..where((row) => row.idx.equals(idx)))
          .go();
      if (genesisIndex != null) {
        final genesis = await getByIndex(genesisIndex);
        final latest = await getLatest();
        if (genesis != null &&
            latest?.idx == genesisIndex &&
            genesis.syncState != SyncState.synced) {
          await (delete(ledgerLocalTable)
                ..where((row) => row.idx.equals(genesisIndex)))
              .go();
        }
      }
    });
  }

  Future<void> _setSyncState(int idx, String state) async {
    await (update(ledgerLocalTable)..where((t) => t.idx.equals(idx)))
        .write(LedgerLocalTableCompanion(syncState: Value(state)));
  }

  /// Hanya untuk "Hapus data di perangkat ini" saat logout (FR-OUT-04).
  /// Tidak dipanggil dari antarmuka ledger.
  Future<void> clearAll() async {
    await delete(ledgerLocalTable).go();
  }
}
