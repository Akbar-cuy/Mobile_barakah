// M18 Saran dan Kesan (FR-FB-03 sampai FR-FB-05). Kirim langsung bila online,
// bila offline disimpan lokal dan dikirim lewat outbox.
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/outbox_dao.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/security/hash_utils.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/utils/date_time_utils.dart';
import '../models/feedback_entry.dart';

String _uuidV4() {
  final b = HashUtils.randomHex(16);
  final variant = '89ab'[int.parse(b[16], radix: 16) % 4];
  return '${b.substring(0, 8)}-${b.substring(8, 12)}-4${b.substring(13, 16)}-'
      '$variant${b.substring(17, 20)}-${b.substring(20, 32)}';
}

class FeedbackRepository {
  FeedbackRepository({
    required AppDatabase db,
    required ApiGateway api,
    required OutboxDao outbox,
    DateTime Function()? clock,
    String Function()? idGenerator,
  })  : _db = db,
        _api = api,
        _outbox = outbox,
        _now = clock ?? DateTime.now,
        _newId = idGenerator ?? _uuidV4;

  final AppDatabase _db;
  final ApiGateway _api;
  final OutboxDao _outbox;
  final DateTime Function() _now;
  final String Function() _newId;

  Stream<List<FeedbackEntry>> watchAll() {
    final query = _db.select(_db.feedbackLocalTable)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => rows.map(FeedbackEntry.fromRow).toList());
  }

  Map<String, dynamic> _payload(
    String id,
    int rating,
    String impression,
    String suggestion,
  ) {
    return {
      'id': id,
      'rating': rating,
      'impression': impression.trim(),
      'suggestion': suggestion.trim(),
    };
  }

  /// Mengirim ke server. True bila terkirim, false bila offline (perlu outbox).
  /// Galat lain dilempar ulang agar tampil di antarmuka.
  Future<bool> _send(Future<Map<String, dynamic>> Function() call) async {
    try {
      await call();
      return true;
    } on ApiException catch (e) {
      if (e.isConnectivity) return false;
      rethrow;
    }
  }

  Future<void> submit({
    required int rating,
    required String impression,
    required String suggestion,
  }) async {
    final id = _newId();
    final stamp = DateTimeUtils.toIsoUtcSeconds(_now());
    final payload = _payload(id, rating, impression, suggestion);

    final sent = await _send(
      () => _api.request('POST', ApiEndpoints.feedback, body: payload),
    );
    await _db.into(_db.feedbackLocalTable).insert(
          FeedbackLocalTableCompanion.insert(
            id: id,
            rating: rating,
            impression: payload['impression'] as String,
            suggestion: payload['suggestion'] as String,
            createdAt: stamp,
            updatedAt: stamp,
            syncState: Value(sent ? SyncState.synced : SyncState.pending),
          ),
        );
    if (!sent) {
      await _outbox.enqueue(
        entity: OutboxEntity.feedback,
        op: OutboxOp.create,
        payload: jsonEncode(payload),
      );
    }
  }

  Future<void> update({
    required String id,
    required int rating,
    required String impression,
    required String suggestion,
  }) async {
    final stamp = DateTimeUtils.toIsoUtcSeconds(_now());
    final payload = _payload(id, rating, impression, suggestion);

    late bool sent;
    try {
      sent = await _send(
        () => _api.request('PUT', ApiEndpoints.feedbackById(id), body: payload),
      );
    } on ApiException catch (e) {
      // Entri dibuat saat offline dan belum sampai ke server: kirim sebagai baru.
      if (e.kind != ApiErrorKind.notFound) rethrow;
      sent = await _send(
        () => _api.request('POST', ApiEndpoints.feedback, body: payload),
      );
    }

    await (_db.update(_db.feedbackLocalTable)..where((t) => t.id.equals(id))).write(
      FeedbackLocalTableCompanion(
        rating: Value(rating),
        impression: Value(payload['impression'] as String),
        suggestion: Value(payload['suggestion'] as String),
        updatedAt: Value(stamp),
        syncState: Value(sent ? SyncState.synced : SyncState.pending),
      ),
    );
    if (!sent) {
      await _outbox.enqueue(
        entity: OutboxEntity.feedback,
        op: OutboxOp.update,
        payload: jsonEncode(payload),
      );
    }
  }

  Future<void> delete(String id) async {
    var sent = true;
    try {
      sent = await _send(
        () => _api.request('DELETE', ApiEndpoints.feedbackById(id)),
      );
    } on ApiException catch (e) {
      if (e.kind != ApiErrorKind.notFound) rethrow;
    }
    await (_db.delete(_db.feedbackLocalTable)..where((t) => t.id.equals(id))).go();
    if (!sent) {
      await _outbox.enqueue(
        entity: OutboxEntity.feedback,
        op: OutboxOp.delete,
        payload: jsonEncode({'id': id}),
      );
    }
  }

  /// Outbox tidak menandai baris feedback, jadi saat antrean kosong semua entri
  /// yang masih menunggu dianggap sudah terkirim.
  Future<void> markPendingSynced() async {
    if (await _outbox.pendingCount() > 0) return;
    await (_db.update(_db.feedbackLocalTable)
          ..where((t) => t.syncState.equals(SyncState.pending)))
        .write(FeedbackLocalTableCompanion(syncState: Value(SyncState.synced)));
  }
}
