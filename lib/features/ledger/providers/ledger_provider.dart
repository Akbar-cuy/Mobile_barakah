// M12 Blockchain Sederhana (FR-BLK)
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/sync/sync_status.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/session_provider.dart';
import '../models/block.dart';
import '../repository/ledger_repository.dart';
import '../services/chain_verifier.dart';

final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  return ApiLedgerRepository(
    db: ref.watch(appDatabaseProvider),
    ledger: ref.watch(ledgerDaoProvider),
    settings: ref.watch(settingsDaoProvider),
    api: ref.watch(apiGatewayProvider),
    currentUserId: () async {
      final fromSession = ref.read(sessionProvider).user?.id;
      if (fromSession != null) return fromSession;
      return (await ref.read(authRepositoryProvider).cachedUser())?.id;
    },
  );
});

/// Daftar blok dari yang terbaru. Diperbarui otomatis saat tabel berubah.
final ledgerBlocksProvider = StreamProvider<List<Block>>((ref) {
  return ref.watch(ledgerRepositoryProvider).watchBlocks();
});

class LedgerViewState {
  const LedgerViewState({
    this.verifying = false,
    this.verification,
    this.checkingHead = false,
    this.head,
    this.headOffline = false,
    this.syncing = false,
    this.error,
  });

  final bool verifying;
  final ChainVerification? verification;
  final bool checkingHead;
  final HeadComparison? head;

  /// Server tidak terjangkau saat memeriksa head.
  final bool headOffline;
  final bool syncing;
  final String? error;

  LedgerViewState copyWith({
    bool? verifying,
    ChainVerification? verification,
    bool? checkingHead,
    HeadComparison? head,
    bool? headOffline,
    bool? syncing,
    String? error,
    bool clearError = false,
  }) {
    return LedgerViewState(
      verifying: verifying ?? this.verifying,
      verification: verification ?? this.verification,
      checkingHead: checkingHead ?? this.checkingHead,
      head: head ?? this.head,
      headOffline: headOffline ?? this.headOffline,
      syncing: syncing ?? this.syncing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class LedgerController extends Notifier<LedgerViewState> {
  @override
  LedgerViewState build() => const LedgerViewState();

  LedgerRepository get _repo => ref.read(ledgerRepositoryProvider);

  /// Verifikasi Rantai (FR-BLK-04). Mengembalikan hasilnya, atau null bila
  /// gagal dijalankan (galat ada di [LedgerViewState.error]).
  Future<ChainVerification?> verify() async {
    state = state.copyWith(verifying: true, clearError: true);
    try {
      final result = await _repo.verifyLocal();
      state = state.copyWith(verifying: false, verification: result);
      return result;
    } on LedgerException catch (e) {
      state = state.copyWith(verifying: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
        verifying: false,
        error: 'Verifikasi gagal dijalankan.',
      );
    }
    return null;
  }

  /// Membandingkan head lokal dengan head server (FR-BLK-08).
  Future<void> refreshHead() async {
    state = state.copyWith(checkingHead: true, clearError: true);
    try {
      final head = await _repo.compareWithServer();
      state = state.copyWith(
        checkingHead: false,
        head: head,
        headOffline: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        checkingHead: false,
        headOffline: e.isConnectivity,
        error: e.isConnectivity ? null : e.message,
      );
    } on LedgerException catch (e) {
      state = state.copyWith(checkingHead: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
        checkingHead: false,
        error: 'Head server tidak dapat diperiksa.',
      );
    }
  }

  /// Menarik blok dari server dan menyelesaikan tabrakan head (FR-BLK-09),
  /// lalu mengirim ulang antrean.
  Future<LedgerSyncReport?> sync() async {
    state = state.copyWith(syncing: true, clearError: true);
    LedgerSyncReport? report;
    try {
      report = await _repo.reconcile();
      unawaited(ref.read(syncServiceProvider).syncNow(manual: true));
    } on ApiException catch (e) {
      state = state.copyWith(
        syncing: false,
        headOffline: e.isConnectivity,
        error: e.isConnectivity ? 'Tidak ada koneksi ke server.' : e.message,
      );
      return null;
    } on LedgerException catch (e) {
      state = state.copyWith(syncing: false, error: e.message);
      return null;
    } catch (_) {
      state = state.copyWith(syncing: false, error: 'Sinkronisasi ledger gagal.');
      return null;
    }
    state = state.copyWith(syncing: false);
    await refreshHead();
    return report;
  }

  /// Ekspor ledger sebagai JSON (FR-BLK-10): disalin ke papan klip dan
  /// disimpan sebagai berkas. Mengembalikan jalur berkas, atau null bila gagal.
  Future<String?> exportJson() async {
    try {
      final json = await _repo.exportJson();
      await Clipboard.setData(ClipboardData(text: json));
      final dir = await getApplicationDocumentsDirectory();
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/ledger_barakah_$stamp.json');
      await file.writeAsString(json, flush: true);
      return file.path;
    } on LedgerException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (_) {
      state = state.copyWith(error: 'Ledger gagal diekspor.');
    }
    return null;
  }
}

final ledgerControllerProvider =
    NotifierProvider<LedgerController, LedgerViewState>(LedgerController.new);

/// Memantau donasi di outbox yang ditolak server karena prev_hash tidak cocok
/// (perangkat lain menambah blok lebih dulu) dan menghitung ulang blok itu di
/// atas head server (FR-BLK-09). Aktifkan dengan `ref.watch` di shell.
final ledgerConflictWatcherProvider = Provider<void>((ref) {
  const minGap = Duration(seconds: 30);
  final sync = ref.watch(syncServiceProvider);
  var busy = false;
  DateTime? lastRun;

  final sub = sync.statusStream.listen((status) async {
    if (status != SyncStatus.error || busy) return;
    final now = DateTime.now();
    if (lastRun != null && now.difference(lastRun!) < minGap) return;
    busy = true;
    lastRun = now;
    try {
      final report = await ref.read(ledgerRepositoryProvider).resolveConflicts();
      if (report != null && report.changedAnything) {
        unawaited(sync.syncNow());
      }
    } catch (_) {
      // Dicoba lagi pada galat sinkronisasi berikutnya.
    } finally {
      busy = false;
    }
  });
  ref.onDispose(sub.cancel);
});
