import 'dart:async';
import 'dart:convert';

import 'package:barakah/core/database/app_database.dart';
import 'package:barakah/core/network/api_client.dart';
import 'package:barakah/core/network/api_exception.dart';
import 'package:barakah/features/converter/repository/rate_repository.dart';
import 'package:barakah/features/donation/models/donation_models.dart';
import 'package:barakah/features/donation/providers/donation_provider.dart';
import 'package:barakah/features/donation/repository/donation_repository.dart';
import 'package:barakah/features/ledger/models/block.dart';
import 'package:barakah/features/ledger/repository/ledger_repository.dart';
import 'package:barakah/core/sync/outbox_processor.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeApi implements ApiGateway {
  final calls = <(String, String, Object?)>[];
  bool failDonationOnce = false;
  Completer<void>? donationGate;
  int failCampaigns = 0;

  @override
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Duration? receiveTimeout,
  }) async {
    calls.add((method, path, body));
    if (path == '/campaigns' && failCampaigns > 0) {
      failCampaigns--;
      throw ApiException.of(ApiErrorKind.network);
    }
    if (path == '/rates') {
      return {
        'base': 'USD',
        'rates': {'USD': 1, 'IDR': 16000, 'SAR': 3.75},
        'updated_at': '2026-10-24',
      };
    }
    if (path == '/campaigns') {
      return {
        'items': [
          {
            'id': '53a875cf-0f64-4a40-a7ca-3196d61d7264',
            'title': 'Air Bersih',
            'description': 'Sumur desa',
            'category': 'Air',
            'target_idr': 50000000,
          },
        ],
      };
    }
    if (path == '/donations') {
      if (donationGate != null) await donationGate!.future;
      if (failDonationOnce) {
        failDonationOnce = false;
        throw ApiException.of(ApiErrorKind.network);
      }
      final payload = body! as Map<String, dynamic>;
      return {
        'ok': true,
        'duplicate': false,
        'donation_id': payload['id'],
        'hash': (payload['block'] as Map<String, dynamic>)['hash'],
      };
    }
    return const {};
  }
}

class _FakeLedger implements LedgerRepository {
  Block? _block;

  @override
  Future<LedgerAppendResult> appendDonation(DonationBlockInput input) async {
    final block = Block(
      index: 1,
      timestamp: input.createdAt.toUtc().toIso8601String(),
      donorAlias: input.donorAlias,
      campaign: input.campaign,
      amount: input.amount,
      currency: input.currency,
      amountIdr: input.amountIdr,
      rateUsed: input.rateUsed,
      prevHash: '0' * 64,
      nonce: 7,
      hash: 'a' * 64,
    );
    _block = block;
    final requestBody = {
      'id': input.donationId,
      'campaign': input.campaign,
      if (input.campaignId != null) 'campaign_id': input.campaignId,
      'amount': input.amount,
      'currency': input.currency,
      'amount_idr': input.amountIdr,
      'rate_used': input.rateUsed,
      'created_at': block.timestamp,
      'block': {
        'idx': block.index,
        'ts': block.timestamp,
        'donor_alias': block.donorAlias,
        'campaign': block.campaign,
        'amount': block.amount,
        'currency': block.currency,
        'amount_idr': block.amountIdr,
        'rate_used': block.rateUsed,
        'prev_hash': block.prevHash,
        'nonce': block.nonce,
        'hash': block.hash,
      },
    };
    return LedgerAppendResult(block: block, requestBody: requestBody);
  }

  @override
  Future<List<Block>> blocks() async => _block == null ? [] : [_block!];

  @override
  Future<LedgerSyncReport> reconcile() async => const LedgerSyncReport();

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;
  late _FakeApi api;
  late _FakeLedger ledger;
  late DonationRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = _FakeApi();
    ledger = _FakeLedger();
    repository = DonationRepository(db: db, api: api, ledger: ledger);
  });

  tearDown(() async => db.close());

  test('loads campaigns from authenticated API response contract', () async {
    final campaigns = await repository.getCampaigns();
    expect(api.calls.single.$1, 'GET');
    expect(api.calls.single.$2, '/campaigns');
    expect(campaigns.single.id, '53a875cf-0f64-4a40-a7ca-3196d61d7264');
    expect(campaigns.single.targetIdr, 50000000);
  });

  test('creates idempotent backend donation and stores local outbox first',
      () async {
    final donation = await _saveCampaignDonation(repository);
    final request = api.calls.singleWhere((call) => call.$2 == '/donations');
    final body = request.$3! as Map<String, dynamic>;
    expect(body['campaign_id'], '53a875cf-0f64-4a40-a7ca-3196d61d7264');
    expect(body['id'], matches(RegExp(r'^[0-9a-f-]{36}$')));
    expect(donation.isSynced, isTrue);
    expect(await db.outboxDao.pendingCount(), 0);
    expect((await repository.getDonations()).single.hash, donation.hash);
  });

  test('network retry keeps the same idempotency key in outbox', () async {
    api.failDonationOnce = true;
    final pending = await _saveCampaignDonation(repository);
    expect(pending.isSynced, isFalse);
    final queued = await db.outboxDao.getDue();
    expect(queued, hasLength(1));
    final originalId = (jsonDecode(queued.single.payload) as Map)['id'];

    final report = await OutboxProcessor(
      outbox: db.outboxDao,
      ledger: db.ledgerDao,
      api: api,
    ).run();

    expect(report.sent, 1);
    final posts = api.calls.where((call) => call.$2 == '/donations').toList();
    expect(posts, hasLength(2));
    expect((posts.last.$3 as Map)['id'], originalId);
    expect(await db.outboxDao.pendingCount(), 0);
  });

  test(
      'provider validates amount and prevents duplicate submission while saving',
      () async {
    final provider = DonationProvider(
      repository: repository,
      rateRepository: RateRepository(db: db, api: api),
    );
    addTearDown(provider.dispose);
    await _waitFor(() => !provider.loading);

    for (final value in [
      'NaN',
      'Infinity',
      '-1',
      '0',
      '1000000000000001',
      '1.5'
    ]) {
      provider.setAmount(value);
      expect(provider.amountError, isNotNull, reason: 'accepted $value');
    }

    provider.setAmount('100');
    api.donationGate = Completer<void>();
    final first = provider.confirmDonation();
    await _waitFor(() => provider.saving);
    final second = await provider.confirmDonation();
    expect(second, isNull);
    api.donationGate!.complete();
    expect(await first, isNotNull);
    expect(api.calls.where((call) => call.$2 == '/donations'), hasLength(1));
  });

  test('campaign loading failure can be retried', () async {
    api.failCampaigns = 1;
    final provider = DonationProvider(
      repository: repository,
      rateRepository: RateRepository(db: db, api: api),
    );
    addTearDown(provider.dispose);
    await _waitFor(() => !provider.loading);
    expect(provider.campaignsError, isNotNull);
    await provider.refresh();
    expect(provider.campaignsError, isNull);
    expect(provider.campaigns, hasLength(1));
  });

  test('a rejected first donation rolls back its pending block and genesis',
      () async {
    await db.ledgerDao.appendBlock(_blockRow(
      index: 0,
      campaign: 'genesis',
      amount: '0',
      amountIdr: '0',
      rate: '1',
      prevHash: '0' * 64,
      hash: 'a' * 64,
    ));
    await db.ledgerDao.appendBlock(_blockRow(
      index: 1,
      campaign: 'Air Bersih',
      amount: '100',
      amountIdr: '100',
      rate: '1',
      prevHash: 'a' * 64,
      hash: 'b' * 64,
    ));

    await db.ledgerDao.rollbackPendingDonation(idx: 1, genesisIndex: 0);

    expect(await db.ledgerDao.count(), 0);
  });
}

LedgerLocalTableCompanion _blockRow({
  required int index,
  required String campaign,
  required String amount,
  required String amountIdr,
  required String rate,
  required String prevHash,
  required String hash,
}) =>
    LedgerLocalTableCompanion.insert(
      idx: Value(index),
      timestamp: '2026-10-24T00:00:00Z',
      donorAlias: index == 0 ? 'Genesis' : 'Hamba Allah',
      campaign: campaign,
      amount: amount,
      currency: 'IDR',
      amountIdr: amountIdr,
      rateUsed: rate,
      prevHash: prevHash,
      nonce: 1,
      hash: hash,
    );

Future<Donation> _saveCampaignDonation(DonationRepository repository) =>
    repository.saveDonation(
      campaign: const Campaign(
        id: '53a875cf-0f64-4a40-a7ca-3196d61d7264',
        title: 'Air Bersih',
        description: 'Sumur desa',
        category: 'Air',
        targetIdr: 50000000,
      ),
      campaignTitle: 'Air Bersih',
      donorAlias: 'Hamba Allah',
      amount: 100,
      currency: 'IDR',
      amountIdr: 100,
      rateUsed: 1,
    );

Future<void> _waitFor(bool Function() condition) async {
  for (var i = 0; i < 100 && !condition(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  expect(condition(), isTrue, reason: 'Timed out waiting for donation state.');
}
