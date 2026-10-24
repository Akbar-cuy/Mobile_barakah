import 'package:barakah/core/database/app_database.dart';
import 'package:barakah/core/sync/sync_status.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('watchFailed hanya memuat item yang pernah gagal beserta galatnya', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime(2026, 10, 25, 9);
    final ok = await db.outboxDao.enqueue(
        entity: OutboxEntity.donation, op: OutboxOp.create, payload: '{}', now: now);
    final bad = await db.outboxDao.enqueue(
        entity: OutboxEntity.feedback, op: OutboxOp.create, payload: '{}', now: now);
    expect(ok, isNot(bad));
    await db.outboxDao.markFailure(bad, '404 NOT_FOUND: belum di-deploy', now: now);

    final failed = await db.outboxDao.watchFailed().first;
    expect(failed, hasLength(1));
    expect(failed.single.entity, OutboxEntity.feedback);
    expect(failed.single.lastError, contains('NOT_FOUND'));
  });
}
