import 'dart:convert';

import 'package:barakah/core/constants/api_endpoints.dart';
import 'package:barakah/core/constants/app_constants.dart';
import 'package:barakah/core/database/app_database.dart';
import 'package:barakah/core/database/daos/ledger_dao.dart';
import 'package:barakah/core/database/daos/outbox_dao.dart';
import 'package:barakah/core/network/api_client.dart';
import 'package:barakah/core/network/api_exception.dart';
import 'package:barakah/core/sync/outbox_processor.dart';
import 'package:barakah/core/sync/sync_status.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';

class FakeGateway implements ApiGateway {
  final calls = <({String method, String path, Object? body})>[];
  ApiException? failWith;
  String? failOnPath;

  @override
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Duration? receiveTimeout,
  }) async {
    calls.add((method: method, path: path, body: body));
    if (failWith != null && (failOnPath == null || failOnPath == path)) {
      throw failWith!;
    }
    return const {};
  }
}

void main() {
  final now = DateTime(2026, 10, 17, 10, 0);
  late AppDatabase db;
  late OutboxDao outbox;
  late LedgerDao ledger;
  late FakeGateway api;
  late OutboxProcessor processor;

  Future<int> add(String entity, Map<String, dynamic> payload,
      {String op = OutboxOp.create}) {
    return outbox.enqueue(
      entity: entity,
      op: op,
      payload: jsonEncode(payload),
      now: now,
    );
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    outbox = db.outboxDao;
    ledger = db.ledgerDao;
    api = FakeGateway();
    processor = OutboxProcessor(
      outbox: outbox,
      ledger: ledger,
      api: api,
      clock: () => now,
    );
  });

  tearDown(() => db.close());

  test('AC-SYNC-01: item terkirim lalu dihapus dari antrean', () async {
    await add(OutboxEntity.feedback, {'id': 'f1', 'rating': 5});
    final result = await processor.run();
    expect(result.sent, 1);
    expect(await outbox.pendingCount(), 0);
    expect(api.calls.single.method, 'POST');
    expect(api.calls.single.path, ApiEndpoints.feedback);
  });

  test('donasi terkirim menandai blok ledger sebagai synced', () async {
    await ledger.appendBlock(LedgerLocalTableCompanion.insert(
      idx: const Value(0),
      timestamp: '2026-10-17T08:15:00Z',
      donorAlias: 'Hamba Allah',
      campaign: 'Air Bersih Pelosok',
      amount: '100000.00',
      currency: 'IDR',
      amountIdr: '100000.00',
      rateUsed: '1',
      prevHash: AppConstants.ledgerGenesisPrevHash,
      nonce: 1,
      hash: '000${'a' * 61}',
    ));
    await add(OutboxEntity.donation, {
      'id': 'd1',
      'block': {'idx': 0},
    });
    await processor.run();
    expect(api.calls.single.path, ApiEndpoints.donations);
    expect((await ledger.getByIndex(0))?.syncState, SyncState.synced);
  });

  test('entity umum dikirim lewat /sync/push', () async {
    await add(OutboxEntity.tasbihLog, {'id': 't1', 'count': 33});
    await processor.run();
    expect(api.calls.single.path, ApiEndpoints.syncPush);
  });

  test('perubahan dan penghapusan saran memakai PUT dan DELETE', () async {
    await add(OutboxEntity.feedback, {'id': 'f1'}, op: OutboxOp.update);
    await add(OutboxEntity.feedback, {'id': 'f2'}, op: OutboxOp.delete);
    await processor.run();
    expect(api.calls.map((c) => c.method), ['PUT', 'DELETE']);
    expect(api.calls.first.path, ApiEndpoints.feedbackById('f1'));
  });

  test('server menolak: percobaan dicatat dan item sejenis dilewati', () async {
    final a = await add(OutboxEntity.donation, {'id': 'd1'});
    await add(OutboxEntity.donation, {'id': 'd2'});
    await add(OutboxEntity.feedback, {'id': 'f1'});
    api
      ..failWith = ApiException.of(ApiErrorKind.conflict)
      ..failOnPath = ApiEndpoints.donations;

    final result = await processor.run();

    expect(result.failed, 1);
    expect(result.sent, 1); // feedback tetap terkirim
    expect(api.calls.length, 2);
    final due = await outbox.getDue(now: now.add(const Duration(days: 1)));
    final failed = due.firstWhere((i) => i.id == a);
    expect(failed.attempts, 1);
  });

  test('tanpa koneksi: berhenti tanpa menambah percobaan', () async {
    final id = await add(OutboxEntity.feedback, {'id': 'f1'});
    api.failWith = ApiException.of(ApiErrorKind.network);
    final result = await processor.run();
    expect(result.offline, isTrue);
    final item = (await outbox.getDue(now: now)).firstWhere((i) => i.id == id);
    expect(item.attempts, 0);
  });

  test('sesi berakhir: berhenti tanpa menghukum item', () async {
    final id = await add(OutboxEntity.feedback, {'id': 'f1'});
    api.failWith = ApiException.of(ApiErrorKind.unauthorized);
    final result = await processor.run();
    expect(result.sessionExpired, isTrue);
    final item = (await outbox.getDue(now: now)).firstWhere((i) => i.id == id);
    expect(item.attempts, 0);
  });
}
