// M12 Blockchain Sederhana (FR-BLK)
import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/ledger_dao.dart';
import '../../../core/database/daos/settings_dao.dart';
import '../../../core/network/api_client.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/utils/date_time_utils.dart';
import '../models/block.dart';
import '../services/block_hasher.dart';
import '../services/chain_verifier.dart';
import '../services/proof_of_work.dart';

// ------------------------------------------------------------------ Galat

/// Galat ledger dengan pesan yang dapat ditampilkan ke pengguna.
class LedgerException implements Exception {
  const LedgerException(this.message);

  final String message;

  @override
  String toString() => 'LedgerException: $message';
}

/// Ledger di perangkat ini milik akun lain. Data lokal dibiarkan utuh
/// (FR-OUT-04) dan hanya dapat dibuka oleh akun yang sama.
class LedgerOwnerMismatchException extends LedgerException {
  const LedgerOwnerMismatchException()
      : super(
          'Ledger di perangkat ini milik akun lain. Masuk dengan akun '
          'tersebut, atau hapus data di perangkat saat logout.',
        );
}

// ------------------------------------------------------------ Nilai masukan

/// Data donasi yang akan dikunci menjadi blok. Nilai uang berupa teks desimal
/// kanonik (misalnya "100000" atau "50.00"), bukan double, agar hash tidak
/// berubah oleh pembulatan (FR-BLK, AC-BLK-06).
class DonationBlockInput {
  const DonationBlockInput({
    required this.donationId,
    required this.campaign,
    required this.amount,
    required this.currency,
    required this.amountIdr,
    required this.rateUsed,
    required this.createdAt,
    this.donorAlias = defaultAlias,
    this.campaignId,
  });

  static const String defaultAlias = 'Hamba Allah';

  /// UUID dari klien. Dipakai server untuk pengiriman idempoten (FR-SYNC-05).
  final String donationId;
  final String campaign;
  final String amount;

  /// IDR, USD, atau SAR.
  final String currency;
  final String amountIdr;
  final String rateUsed;
  final DateTime createdAt;

  /// Ledger memakai alias, bukan nama asli (NFR-07).
  final String donorAlias;

  /// Opsional: id kampanye di server.
  final String? campaignId;
}

/// Hasil pembuatan blok. [requestBody] adalah isi POST /donations yang siap
/// dimasukkan ke outbox oleh modul donasi.
class LedgerAppendResult {
  const LedgerAppendResult({
    required this.block,
    required this.requestBody,
    this.genesis,
  });

  final Block block;

  /// Blok genesis yang belum terkirim ke server. Ikut dikirim bersama blok
  /// pertama agar server dapat memeriksa rantai sejak indeks 0.
  final Block? genesis;

  final Map<String, dynamic> requestBody;
}

// ------------------------------------------------------------- Head server

enum HeadStatus {
  /// Head terakhir yang tersinkron sama dengan head server.
  match,

  /// Server memiliki blok yang belum ada di perangkat ini.
  serverAhead,

  /// Hash pada indeks yang sama berbeda, atau server kehilangan blok.
  mismatch,

  /// Belum diperiksa, misalnya karena offline.
  unknown,
}

class HeadComparison {
  const HeadComparison({
    required this.status,
    this.localIndex,
    this.serverIndex,
    this.serverHash,
    this.pendingCount = 0,
  });

  const HeadComparison.unknown({int pendingCount = 0})
      : this(status: HeadStatus.unknown, pendingCount: pendingCount);

  final HeadStatus status;

  /// Indeks blok terakhir yang sudah tersinkron di perangkat.
  final int? localIndex;
  final int? serverIndex;
  final String? serverHash;

  /// Blok lokal yang belum terkirim.
  final int pendingCount;

  /// FR-BLK-08: membandingkan head lokal yang tersinkron dengan head server.
  static HeadComparison compare({
    required List<Block> localBlocks,
    int? serverIndex,
    String? serverHash,
  }) {
    final synced = localBlocks.where((b) => b.isSynced).toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final pending = localBlocks.length - synced.length;
    final localHead = synced.isEmpty ? null : synced.last;
    final serverHasBlocks = serverIndex != null && serverHash != null;

    HeadStatus status;
    if (!serverHasBlocks) {
      status = localHead == null ? HeadStatus.match : HeadStatus.mismatch;
    } else if (localHead == null) {
      status = HeadStatus.serverAhead;
    } else if (localHead.index == serverIndex) {
      status = localHead.hash == serverHash ? HeadStatus.match : HeadStatus.mismatch;
    } else if (localHead.index < serverIndex) {
      status = HeadStatus.serverAhead;
    } else {
      status = HeadStatus.mismatch;
    }

    return HeadComparison(
      status: status,
      localIndex: localHead?.index,
      serverIndex: serverIndex,
      serverHash: serverHash,
      pendingCount: pending,
    );
  }
}

/// Ringkasan hasil [LedgerRepository.reconcile].
class LedgerSyncReport {
  const LedgerSyncReport({
    this.pulledBlocks = 0,
    this.remined = 0,
    this.markedSynced = 0,
  });

  /// Blok dari server yang ditambahkan ke perangkat.
  final int pulledBlocks;

  /// Blok lokal yang dihitung ulang di atas head server (FR-BLK-09).
  final int remined;

  /// Blok lokal yang ternyata sudah ada di server.
  final int markedSynced;

  bool get changedAnything => pulledBlocks + remined + markedSynced > 0;
}

// -------------------------------------------------------------- Antarmuka

abstract interface class LedgerRepository {
  /// Daftar blok dari yang terbaru (FR-BLK-10).
  Stream<List<Block>> watchBlocks();

  /// Seluruh blok dari yang terlama.
  Future<List<Block>> blocks();

  Future<Block?> blockAt(int index);

  /// Verifikasi Rantai lokal (FR-BLK-04, FR-BLK-05).
  Future<ChainVerification> verifyLocal();

  /// Membandingkan head lokal dengan head server (FR-BLK-08).
  /// Melempar ApiException bila server tidak terjangkau.
  Future<HeadComparison> compareWithServer();

  /// Membuat blok untuk satu donasi (FR-BLK-01, FR-BLK-02). Blok genesis
  /// dibuat otomatis pada pemakaian pertama. Pencarian nonce berjalan di
  /// isolate (FR-BLK-03).
  ///
  /// Pemanggil (modul donasi) menyimpan donasi lokal, lalu memasukkan
  /// [LedgerAppendResult.requestBody] ke outbox dengan OutboxEntity.donation.
  Future<LedgerAppendResult> appendDonation(DonationBlockInput input);

  /// Mengambil blok dari server dan, bila ada tabrakan indeks dengan blok
  /// lokal yang belum terkirim, menghitung ulang blok itu di atas head server
  /// (FR-BLK-09).
  Future<LedgerSyncReport> reconcile();

  /// Menjalankan [reconcile] hanya bila ada donasi di outbox yang ditolak
  /// server karena prev_hash tidak cocok. Mengembalikan null bila tidak ada.
  Future<LedgerSyncReport?> resolveConflicts();

  /// Ekspor ledger sebagai JSON (FR-BLK-10).
  Future<String> exportJson();
}

// ------------------------------------------------------------ Implementasi

class ApiLedgerRepository implements LedgerRepository {
  ApiLedgerRepository({
    required this.db,
    required this.ledger,
    required this.settings,
    required this.api,
    required this.currentUserId,
    this.hasher = const BlockHasher(),
    this.pow = const ProofOfWork(),
    DateTime Function()? clock,
  })  : _now = clock ?? DateTime.now,
        _verifier = ChainVerifier(hasher: hasher, pow: pow);

  final AppDatabase db;
  final LedgerDao ledger;
  final SettingsDao settings;
  final ApiGateway api;

  /// Id akun yang sedang masuk, atau null bila belum masuk.
  final Future<String?> Function() currentUserId;
  final BlockHasher hasher;
  final ProofOfWork pow;
  final DateTime Function() _now;
  final ChainVerifier _verifier;

  final _Serial _serial = _Serial();

  static const _kOwner = 'ledger_owner';
  static const _kGenesisAlias = 'Genesis';
  static const _kGenesisCampaign = 'genesis';

  static final RegExp _decimal = RegExp(r'^[0-9]+(\.[0-9]+)?$');

  // ----------------------------------------------------------------- Baca

  @override
  Stream<List<Block>> watchBlocks() {
    return ledger
        .watchAll()
        .map((rows) => [for (final r in rows) Block.fromRow(r)]);
  }

  @override
  Future<List<Block>> blocks() async {
    final rows = await ledger.getAllAscending();
    return [for (final r in rows) Block.fromRow(r)];
  }

  @override
  Future<Block?> blockAt(int index) async {
    final row = await ledger.getByIndex(index);
    return row == null ? null : Block.fromRow(row);
  }

  @override
  Future<ChainVerification> verifyLocal() async {
    final userId = await _requireUser();
    await _checkOwner(userId);
    return _verifier.verify(await blocks(), userId: userId);
  }

  @override
  Future<HeadComparison> compareWithServer() async {
    final userId = await _requireUser();
    await _checkOwner(userId);
    final res = await api.request('GET', ApiEndpoints.ledgerVerify);
    final head = _parseHead(res);
    return HeadComparison.compare(
      localBlocks: await blocks(),
      serverIndex: head.index,
      serverHash: head.hash,
    );
  }

  @override
  Future<String> exportJson() async {
    final userId = await _requireUser();
    await _checkOwner(userId);
    final chain = await blocks();
    final verification = _verifier.verify(chain, userId: userId);
    final data = <String, dynamic>{
      'app': 'barakah',
      'exported_at': DateTimeUtils.toIsoUtcSeconds(_now()),
      'user_id': userId,
      'block_count': chain.length,
      'chain_valid': verification.isValid,
      if (!verification.isValid)
        'first_invalid_index': verification.firstInvalidIndex,
      'blocks': [
        for (final b in chain) {...b.toJson(), 'sync_state': b.syncState},
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  // ---------------------------------------------------------------- Tulis

  @override
  Future<LedgerAppendResult> appendDonation(DonationBlockInput input) {
    return _serial.run(() async {
      final userId = await _requireUser();
      await _claimOwner(userId);
      _validate(input);

      var head = await ledger.getLatest();
      if (head == null) {
        final genesis = await _mine(
          userId: userId,
          index: AppConstants.ledgerGenesisIndex,
          timestamp: DateTimeUtils.toIsoUtcSeconds(_now()),
          donorAlias: _kGenesisAlias,
          campaign: _kGenesisCampaign,
          amount: '0',
          currency: AppCurrency.idr.code,
          amountIdr: '0',
          rateUsed: '1',
          prevHash: AppConstants.ledgerGenesisPrevHash,
        );
        await ledger.appendBlock(_companion(genesis));
        head = await ledger.getLatest();
      }
      final previous = head!;

      final block = await _mine(
        userId: userId,
        index: previous.idx + 1,
        timestamp: DateTimeUtils.toIsoUtcSeconds(input.createdAt),
        donorAlias: _alias(input.donorAlias),
        campaign: BlockHasher.sanitize(input.campaign),
        amount: input.amount,
        currency: input.currency,
        amountIdr: input.amountIdr,
        rateUsed: input.rateUsed,
        prevHash: previous.hash,
      );
      await ledger.appendBlock(_companion(block));

      final genesisRow = await ledger.getByIndex(AppConstants.ledgerGenesisIndex);
      final genesis = genesisRow == null ? null : Block.fromRow(genesisRow);
      final pendingGenesis =
          genesis != null && !genesis.isSynced ? genesis : null;

      return LedgerAppendResult(
        block: block,
        genesis: pendingGenesis,
        requestBody: {
          'id': input.donationId,
          'campaign': block.campaign,
          if (input.campaignId != null) 'campaign_id': input.campaignId,
          'amount': block.amount,
          'currency': block.currency,
          'amount_idr': block.amountIdr,
          'rate_used': block.rateUsed,
          'created_at': DateTimeUtils.toIsoUtcSeconds(input.createdAt),
          'block': block.toJson(),
          if (pendingGenesis != null) 'genesis': pendingGenesis.toJson(),
        },
      );
    });
  }

  // ----------------------------------------------------------- Rekonsiliasi

  @override
  Future<LedgerSyncReport?> resolveConflicts() async {
    final stuck = await _conflictedDonationRows();
    if (stuck.isEmpty) return null;
    return reconcile();
  }

  @override
  Future<LedgerSyncReport> reconcile() {
    return _serial.run(() async {
      final userId = await _requireUser();
      await _checkOwner(userId);

      final res = await api.request('GET', ApiEndpoints.ledger);
      final server = _parseBlocks(res);
      final check = _verifier.verify(server, userId: userId);
      if (!check.isValid) {
        throw LedgerException(
          'Rantai di server tidak valid pada blok ${check.firstInvalidIndex}.',
        );
      }

      final local = await blocks();
      final serverByIndex = {for (final b in server) b.index: b};

      // Blok yang sudah tersinkron harus sama persis dengan milik server.
      for (final b in local.where((b) => b.isSynced)) {
        final s = serverByIndex[b.index];
        if (s == null || s.hash != b.hash) {
          throw LedgerException(
            'Blok ${b.index} di perangkat tidak cocok dengan server. '
            'Jalankan Verifikasi Rantai untuk memeriksa.',
          );
        }
      }

      final pending = local.where((b) => !b.isSynced).toList();
      final alreadyOnServer = [
        for (final b in pending)
          if (serverByIndex[b.index]?.hash == b.hash) b,
      ];
      final toPlace = [
        for (final b in pending)
          if (serverByIndex[b.index]?.hash != b.hash) b,
      ];
      final Block? serverHead = server.isEmpty ? null : server.last;

      final needsRebase = serverHead != null &&
          toPlace.isNotEmpty &&
          !(toPlace.first.index == serverHead.index + 1 &&
              toPlace.first.prevHash == serverHead.hash);

      var remined = 0;
      final replacements = <String, Block?>{};
      final rebased = <Block>[];

      if (needsRebase) {
        var cursor = serverHead;
        for (final p in toPlace) {
          // Server sudah punya genesis sendiri, genesis lokal dibuang.
          if (p.isGenesis) {
            replacements[p.hash] = null;
            continue;
          }
          final mined = await _mine(
            userId: userId,
            index: cursor.index + 1,
            timestamp: p.timestamp,
            donorAlias: p.donorAlias,
            campaign: p.campaign,
            amount: p.amount,
            currency: p.currency,
            amountIdr: p.amountIdr,
            rateUsed: p.rateUsed,
            prevHash: cursor.hash,
          );
          rebased.add(mined);
          replacements[p.hash] = mined;
          cursor = mined;
          remined++;
        }
      }

      var pulled = 0;
      await db.transaction(() async {
        // Blok lokal yang belum terkirim dibuang dulu; yang valid dimasukkan
        // kembali di bawah, berurutan di atas head server.
        if (needsRebase) {
          await (db.delete(db.ledgerLocalTable)
                ..where((t) => t.syncState.equals(SyncState.synced).not()))
              .go();
        }
        final present = {
          for (final r in await ledger.getAllAscending()) r.idx,
        };
        for (final b in server) {
          if (present.contains(b.index)) continue;
          await db
              .into(db.ledgerLocalTable)
              .insert(_companion(b.copyWith(syncState: SyncState.synced)));
          pulled++;
        }
        for (final b in rebased) {
          await db.into(db.ledgerLocalTable).insert(_companion(b));
        }
        for (final b in alreadyOnServer) {
          await ledger.markSynced(b.index);
        }
      });

      if (replacements.isNotEmpty) {
        await _rewriteOutbox(replacements, dropGenesis: serverHead != null);
      }

      return LedgerSyncReport(
        pulledBlocks: pulled,
        remined: remined,
        markedSynced: alreadyOnServer.length,
      );
    });
  }

  // --------------------------------------------------------------- Bantu

  Future<String> _requireUser() async {
    final id = await currentUserId();
    if (id == null || id.isEmpty) {
      throw const LedgerException('Masuk terlebih dahulu untuk memakai ledger.');
    }
    return id;
  }

  Future<void> _claimOwner(String userId) async {
    final owner = await settings.get(_kOwner);
    if (owner == null) {
      await settings.set(_kOwner, userId);
    } else if (owner != userId) {
      throw const LedgerOwnerMismatchException();
    }
  }

  Future<void> _checkOwner(String userId) async {
    final owner = await settings.get(_kOwner);
    if (owner != null && owner != userId) {
      throw const LedgerOwnerMismatchException();
    }
  }

  String _alias(String raw) {
    final cleaned = BlockHasher.sanitize(raw);
    return cleaned.isEmpty ? DonationBlockInput.defaultAlias : cleaned;
  }

  void _validate(DonationBlockInput input) {
    if (AppCurrency.tryParse(input.currency) == null) {
      throw const LedgerException('Mata uang harus IDR, USD, atau SAR.');
    }
    for (final entry in {
      'Nominal': input.amount,
      'Nilai setara rupiah': input.amountIdr,
      'Kurs': input.rateUsed,
    }.entries) {
      if (!_decimal.hasMatch(entry.value)) {
        throw LedgerException('${entry.key} tidak valid: "${entry.value}".');
      }
    }
    if (BlockHasher.sanitize(input.campaign).isEmpty) {
      throw const LedgerException('Nama kampanye wajib diisi.');
    }
  }

  Future<Block> _mine({
    required String userId,
    required int index,
    required String timestamp,
    required String donorAlias,
    required String campaign,
    required String amount,
    required String currency,
    required String amountIdr,
    required String rateUsed,
    required String prevHash,
  }) async {
    final prefix = hasher.prefix(
      index: index,
      timestamp: timestamp,
      userId: userId,
      donorAlias: donorAlias,
      campaign: campaign,
      amount: amount,
      currency: currency,
      amountIdr: amountIdr,
      rateUsed: rateUsed,
      prevHash: prevHash,
    );
    final result = await pow.mine(prefix);
    final block = Block(
      index: index,
      timestamp: timestamp,
      donorAlias: donorAlias,
      campaign: campaign,
      amount: amount,
      currency: currency,
      amountIdr: amountIdr,
      rateUsed: rateUsed,
      prevHash: prevHash,
      nonce: result.nonce,
      hash: result.hash,
    );
    if (hasher.compute(block, userId) != block.hash) {
      throw StateError('Hash hasil pencarian nonce tidak cocok dengan BlockHasher.');
    }
    return block;
  }

  LedgerLocalTableCompanion _companion(Block b) {
    return LedgerLocalTableCompanion.insert(
      idx: Value(b.index),
      timestamp: b.timestamp,
      donorAlias: b.donorAlias,
      campaign: b.campaign,
      amount: b.amount,
      currency: b.currency,
      amountIdr: b.amountIdr,
      rateUsed: b.rateUsed,
      prevHash: b.prevHash,
      nonce: b.nonce,
      hash: b.hash,
      syncState: Value(b.syncState),
    );
  }

  List<Block> _parseBlocks(Map<String, dynamic> res) {
    final raw = res['items'] ?? res['blocks'];
    if (raw is! List) return const [];
    final blocks = [
      for (final item in raw)
        if (item is Map) Block.fromJson(item.cast<String, dynamic>()),
    ]..sort((a, b) => a.index.compareTo(b.index));
    return blocks;
  }

  /// Head server dapat berupa {head_idx, head_hash}, {head, head_idx}, atau
  /// {head: {idx, hash}}. Ketiganya diterima.
  ({int? index, String? hash}) _parseHead(Map<String, dynamic> res) {
    final head = res['head'];
    int? index = _asInt(res['head_idx']);
    String? hash = res['head_hash']?.toString();
    if (head is Map) {
      index ??= _asInt(head['idx']);
      hash ??= head['hash']?.toString();
    } else if (head != null) {
      hash ??= head.toString();
    }
    if (index == null || index < 0 || hash == null || hash.isEmpty) {
      return (index: null, hash: null);
    }
    return (index: index, hash: hash);
  }

  static int? _asInt(Object? v) => v is num ? v.toInt() : int.tryParse('$v');

  Future<List<OutboxTableData>> _conflictedDonationRows() {
    return (db.select(db.outboxTable)
          ..where((t) =>
              t.entity.equals(OutboxEntity.donation) &
              t.lastError.like('%${ApiErrorCodes.prevHashMismatch}%')))
        .get();
  }

  /// Mengganti blok pada payload donasi di outbox dengan blok hasil re-mine,
  /// lalu mengaktifkan percobaan ulang segera.
  Future<void> _rewriteOutbox(
    Map<String, Block?> replacements, {
    required bool dropGenesis,
  }) async {
    final rows = await (db.select(db.outboxTable)
          ..where((t) => t.entity.equals(OutboxEntity.donation)))
        .get();
    for (final row in rows) {
      Map<String, dynamic> payload;
      try {
        payload = (jsonDecode(row.payload) as Map).cast<String, dynamic>();
      } on FormatException {
        continue;
      }
      var changed = false;
      final block = payload['block'];
      if (block is Map) {
        final replacement = replacements[block['hash']];
        if (replacement != null) {
          payload['block'] = replacement.toJson();
          changed = true;
        }
      }
      if (dropGenesis && payload.containsKey('genesis')) {
        payload.remove('genesis');
        changed = true;
      }
      if (!changed) continue;
      await (db.update(db.outboxTable)..where((t) => t.id.equals(row.id))).write(
        OutboxTableCompanion(
          payload: Value(jsonEncode(payload)),
          attempts: const Value(0),
          lastError: const Value(null),
          nextAttemptAt: Value(_now()),
        ),
      );
    }
  }
}

/// Menjalankan tugas satu per satu agar pembuatan blok dan rekonsiliasi tidak
/// saling menimpa head rantai.
class _Serial {
  Future<void> _tail = Future<void>.value();

  Future<T> run<T>(Future<T> Function() task) {
    final completer = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        completer.complete(await task());
      } catch (e, s) {
        completer.completeError(e, s);
      }
    });
    return completer.future;
  }
}
