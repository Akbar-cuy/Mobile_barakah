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

class _CampaignCache {
  const _CampaignCache({required this.items, required this.checkedAt});

  final List<Campaign> items;
  final DateTime checkedAt;
}

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
  static final RegExp _campaignUuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );
  static const campaignsCacheKey = 'donation_campaign_cache';

  Future<CampaignLoadResult> getCampaigns({
    String? query,
    String? category,
  }) async {
    final cached = await _readCampaignCache();
    try {
      final response = await api.request(
        'GET',
        ApiEndpoints.campaigns,
        query: {
          'q': query?.trim().isEmpty == true ? null : query?.trim(),
          'category': category == null || category == 'Semua' ? null : category,
        },
      );
      final campaigns = _parseCampaigns(response['items']);
      final checkedAt = DateTime.now().toUtc();
      String? message;
      try {
        await _writeCampaignCache(campaigns, cached, checkedAt);
      } on Object {
        message =
            'Kampanye dimuat dari server, tetapi cache lokal gagal diperbarui.';
      }
      return CampaignLoadResult(
        items: campaigns,
        source: CampaignDataSource.network,
        checkedAt: checkedAt,
        message: message,
      );
    } on Object catch (error) {
      final message = error is ApiException
          ? error.message
          : 'Kampanye gagal dimuat. Periksa koneksi lalu coba lagi.';
      if (cached != null) {
        return CampaignLoadResult(
          items: cached.items,
          source: CampaignDataSource.cache,
          checkedAt: cached.checkedAt,
          message: message,
        );
      }
      return CampaignLoadResult(
        items: const [],
        source: CampaignDataSource.unavailable,
        message: '$message Tidak ada cache kampanye tersimpan.',
      );
    }
  }

  List<Campaign> _parseCampaigns(Object? value) {
    if (value is! List || value.length > 200) {
      throw const FormatException('Data kampanye tidak valid.');
    }
    final campaigns = <Campaign>[];
    final ids = <String>{};
    for (final item in value) {
      if (item is! Map) {
        throw const FormatException('Data kampanye tidak valid.');
      }
      final row = Map<String, dynamic>.from(item);
      final id = row['id'];
      final title = row['title'];
      final description = row['description'];
      final category = row['category'];
      final target = row['target_idr'];
      final version = row['version'];
      if (id is! String ||
          !_campaignUuid.hasMatch(id) ||
          !ids.add(id) ||
          title is! String ||
          title.trim().isEmpty ||
          description is! String ||
          category is! String ||
          version is! int ||
          (target != null && target is! num) ||
          (target is num && (!target.toDouble().isFinite || target < 0))) {
        throw const FormatException('Data kampanye tidak valid.');
      }
      campaigns.add(Campaign(
        id: id,
        title: title,
        description: description,
        category: category,
        targetIdr: (target as num?)?.toDouble() ?? 0,
        version: version,
      ));
    }
    return campaigns;
  }

  Future<_CampaignCache?> _readCampaignCache() async {
    try {
      final raw = await db.settingsDao.get(campaignsCacheKey);
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic> ||
          decoded['checked_at'] is! String ||
          decoded['items'] is! List) {
        return null;
      }
      final checkedAt = DateTime.tryParse(decoded['checked_at'] as String);
      if (checkedAt == null) return null;
      return _CampaignCache(
        items: _parseCampaigns(decoded['items']),
        checkedAt: checkedAt.toUtc(),
      );
    } on Object {
      return null;
    }
  }

  Future<void> _writeCampaignCache(
    List<Campaign> incoming,
    _CampaignCache? cached,
    DateTime checkedAt,
  ) async {
    final byId = <String, Campaign>{
      if (cached != null)
        for (final campaign in cached.items) campaign.id: campaign,
    };
    for (final campaign in incoming) {
      final previous = byId[campaign.id];
      // The API can filter by query/category and excludes inactive rows, so an
      // omitted ID is not evidence that a cached campaign was deleted. The
      // PRD only permits updates when the server version is newer; for an
      // equal version, keep the cached payload unchanged.
      if (previous == null || campaign.version > previous.version) {
        byId[campaign.id] = campaign;
      }
    }
    await db.settingsDao.set(
      campaignsCacheKey,
      jsonEncode({
        'checked_at': checkedAt.toIso8601String(),
        'items': [for (final campaign in byId.values) campaign.toJson()],
      }),
      now: checkedAt,
    );
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
