import 'dart:convert';
import 'dart:math';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/database/app_database.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/sync/sync_status.dart';
import '../../ledger/models/block.dart';
import '../../ledger/repository/ledger_repository.dart';
import '../models/donation_models.dart';

class DonationRepository {
  DonationRepository({
    required this.db,
    required this.api,
    required this.ledger,
  });

  final AppDatabase db;
  final ApiGateway api;
  final LedgerRepository ledger;

  static const double maxAmountIdr = 1000000000000000;
  static final RegExp _decimal = RegExp(r'^(?:0|[1-9]\d*)(?:\.\d+)?$');

  Future<List<Campaign>> getCampaigns({String? query, String? category}) async {
    final response = await api.request(
      'GET',
      ApiEndpoints.campaigns,
      query: {
        'q': query?.trim().isEmpty == true ? null : query?.trim(),
        'category': category == null || category == 'Semua' ? null : category,
      },
    );
    final items = response['items'];
    if (items is! List) {
      throw const FormatException('Data kampanye tidak valid.');
    }
    return items.map((item) {
      if (item is! Map) {
        throw const FormatException('Data kampanye tidak valid.');
      }
      final row = Map<String, dynamic>.from(item);
      final id = row['id'];
      final title = row['title'];
      final description = row['description'];
      final categoryValue = row['category'];
      final target = row['target_idr'];
      if (id is! String ||
          id.isEmpty ||
          title is! String ||
          title.trim().isEmpty ||
          description is! String ||
          categoryValue is! String ||
          (target != null && target is! num) ||
          (target is num && (!target.toDouble().isFinite || target < 0))) {
        throw const FormatException('Data kampanye tidak valid.');
      }
      return Campaign(
        id: id,
        title: title,
        description: description,
        category: categoryValue,
        targetIdr: (target as num?)?.toDouble() ?? 0,
      );
    }).toList(growable: false);
  }

  Future<List<Donation>> getDonations() async {
    try {
      await ledger.reconcile();
    } on ApiException catch (error) {
      if (!error.isConnectivity) rethrow;
    }
    final blocks = await ledger.blocks();
    return blocks
        .where((block) => !block.isGenesis)
        .map(_donationFromBlock)
        .toList(growable: false);
  }

  Future<Donation> saveDonation({
    required Campaign? campaign,
    required String campaignTitle,
    required String donorAlias,
    required double amount,
    required String currency,
    required double amountIdr,
    required double rateUsed,
  }) async {
    if (!amount.isFinite ||
        amount <= 0 ||
        !amountIdr.isFinite ||
        amountIdr <= 0 ||
        amountIdr > maxAmountIdr ||
        !rateUsed.isFinite ||
        rateUsed <= 0 ||
        !['IDR', 'USD', 'SAR'].contains(currency)) {
      throw const FormatException('Nominal donasi tidak valid.');
    }
    final alias = donorAlias.trim();
    if (alias.isEmpty || alias.length > 80) {
      throw const FormatException('Alias donatur harus 1–80 karakter.');
    }
    final title = campaign?.title ?? campaignTitle.trim();
    if (title.isEmpty || title.length > 120) {
      throw const FormatException('Kampanye tidak valid.');
    }

    final donationId = _uuidV4();
    final createdAt = DateTime.now().toUtc();
    final amountText = _canonicalAmount(amount, currency);
    final idrText = _canonicalAmount(amountIdr, 'IDR');
    final rateText = rateUsed.toString();
    try {
      await ledger.reconcile();
    } on ApiException catch (error) {
      if (!error.isConnectivity) rethrow;
    }
    final (appended, outboxId) = await db.transaction(() async {
      final result = await ledger.appendDonation(DonationBlockInput(
        donationId: donationId,
        campaign: title,
        campaignId: campaign?.id,
        amount: amountText,
        currency: currency,
        amountIdr: idrText,
        rateUsed: rateText,
        createdAt: createdAt,
        donorAlias: alias,
      ));
      final queuedId = await db.outboxDao.enqueue(
        entity: OutboxEntity.donation,
        op: OutboxOp.create,
        payload: jsonEncode(result.requestBody),
        now: createdAt,
      );
      return (result, queuedId);
    });

    try {
      final response = await api.request('POST', ApiEndpoints.donations,
          body: appended.requestBody);
      if (response['ok'] != true ||
          response['duplicate'] is! bool ||
          (response['duplicate'] != true &&
              (response['donation_id'] != donationId ||
                  response['hash'] != appended.block.hash))) {
        throw const FormatException('Respons server donasi tidak valid.');
      }
    } on ApiException catch (error) {
      if (_shouldRetry(error)) {
        return _donationFromBlock(appended.block);
      }
      await db.outboxDao.markSuccess(outboxId);
      await db.ledgerDao.rollbackPendingDonation(
        idx: appended.block.index,
        genesisIndex: appended.genesis?.index,
      );
      rethrow;
    } catch (_) {
      return _donationFromBlock(appended.block);
    }

    try {
      await db.transaction(() async {
        await db.ledgerDao.markSynced(appended.block.index);
        if (appended.genesis != null) {
          await db.ledgerDao.markSynced(appended.genesis!.index);
        }
        await db.outboxDao.markSuccess(outboxId);
      });
    } catch (_) {
      // Server telah menerima donasi. Outbox menyimpan retry idempoten jika
      // pembaruan status lokal gagal.
    }
    return _donationFromBlock(
        appended.block.copyWith(syncState: SyncState.synced));
  }

  bool _shouldRetry(ApiException error) =>
      error.isConnectivity ||
      error.kind == ApiErrorKind.server ||
      error.kind == ApiErrorKind.tooManyRequests ||
      error.code == 'ledger_conflict' ||
      error.code == 'genesis_conflict';

  Donation _donationFromBlock(Block block) => Donation(
        id: block.hash,
        campaignTitle: block.campaign,
        donorAlias: block.donorAlias,
        amount: double.parse(block.amount),
        currency: block.currency,
        amountIdr: double.parse(block.amountIdr),
        rateUsed: double.parse(block.rateUsed),
        createdAt: DateTime.parse(block.timestamp).toUtc(),
        blockIndex: block.index,
        prevHash: block.prevHash,
        nonce: block.nonce,
        hash: block.hash,
        isSynced: block.isSynced,
      );

  String _canonicalAmount(double value, String currency) {
    if (!value.isFinite || value < 0 || value > maxAmountIdr) {
      throw const FormatException('Nominal donasi terlalu besar.');
    }
    final canonical = value.toString();
    if (!_decimal.hasMatch(canonical)) {
      throw const FormatException('Nominal donasi tidak valid.');
    }
    if (currency == 'IDR' && canonical.contains('.')) {
      final fraction = canonical.split('.').last;
      if (fraction.replaceAll('0', '').isNotEmpty) {
        throw const FormatException('Nominal IDR harus berupa bilangan bulat.');
      }
    } else if (canonical.contains('.') &&
        canonical.split('.').last.length > 2) {
      throw const FormatException('Maksimal dua angka di belakang koma.');
    }
    return currency == 'IDR' ? value.toStringAsFixed(0) : canonical;
  }

  String _uuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex =
        bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
