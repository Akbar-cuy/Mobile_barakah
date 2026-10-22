// M18 Saran dan Kesan (FR-FB-03 sampai FR-FB-05).
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/outbox_dao.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/security/hash_utils.dart';
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
    required OutboxDao outbox,
    DateTime Function()? clock,
    String Function()? idGenerator,
  })  : _db = db,
        _outbox = outbox,
        _now = clock ?? DateTime.now,
        _newId = idGenerator ?? _uuidV4;

  final AppDatabase _db;
  final OutboxDao _outbox;
  final DateTime Function() _now;
  final String Function() _newId;

  Stream<List<FeedbackEntry>> watchAll() {
    final query = _db.select(_db.feedbackLocalTable)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query
        .watch()
        .map((rows) => rows.map(FeedbackEntry.fromRow).toList());
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

  void _validate(int rating, String impression, String suggestion) {
    if (rating < AppConstants.feedbackRatingMin ||
        rating > AppConstants.feedbackRatingMax) {
      throw ArgumentError(
        'Penilaian harus ${AppConstants.feedbackRatingMin} sampai '
        '${AppConstants.feedbackRatingMax} bintang.',
      );
    }
    for (final (name, value) in [
      ('Kesan', impression.trim()),
      ('Saran', suggestion.trim()),
    ]) {
      if (value.length < AppConstants.feedbackTextMin ||
          value.length > AppConstants.feedbackTextMax) {
        throw ArgumentError(
          '$name harus ${AppConstants.feedbackTextMin} sampai '
          '${AppConstants.feedbackTextMax} karakter.',
        );
      }
    }
  }

  /// Menulis data lokal dan outbox bersama-sama sebelum sinkronisasi berjalan.
  Future<FeedbackEntry> submit({
    required int rating,
    required String impression,
    required String suggestion,
  }) async {
    _validate(rating, impression, suggestion);
    final id = _newId();
    final now = _now();
    final stamp = DateTimeUtils.toIsoUtcSeconds(now);
    final payload = _payload(id, rating, impression, suggestion);

    await _db.transaction(() async {
      await _db.into(_db.feedbackLocalTable).insert(
            FeedbackLocalTableCompanion.insert(
              id: id,
              rating: rating,
              impression: payload['impression'] as String,
              suggestion: payload['suggestion'] as String,
              createdAt: stamp,
              updatedAt: stamp,
              syncState: const Value(SyncState.pending),
            ),
          );
      await _outbox.enqueue(
        entity: OutboxEntity.feedback,
        op: OutboxOp.create,
        payload: jsonEncode(payload),
        now: now,
      );
    });

    return FeedbackEntry(
      id: id,
      rating: rating,
      impression: payload['impression'] as String,
      suggestion: payload['suggestion'] as String,
      createdAt: now,
      updatedAt: now,
      syncState: SyncState.pending,
    );
  }

  Future<FeedbackEntry> update({
    required String id,
    required int rating,
    required String impression,
    required String suggestion,
  }) async {
    _validate(rating, impression, suggestion);
    final row = await (_db.select(_db.feedbackLocalTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) throw StateError('Kiriman tidak ditemukan.');

    final now = _now();
    final stamp = DateTimeUtils.toIsoUtcSeconds(now);
    final payload = _payload(id, rating, impression, suggestion);
    await _db.transaction(() async {
      await (_db.update(_db.feedbackLocalTable)..where((t) => t.id.equals(id)))
          .write(
        FeedbackLocalTableCompanion(
          rating: Value(rating),
          impression: Value(payload['impression'] as String),
          suggestion: Value(payload['suggestion'] as String),
          updatedAt: Value(stamp),
          syncState: const Value(SyncState.pending),
        ),
      );
      await _outbox.enqueue(
        entity: OutboxEntity.feedback,
        op: OutboxOp.update,
        payload: jsonEncode(payload),
        now: now,
      );
    });

    return FeedbackEntry(
      id: id,
      rating: rating,
      impression: payload['impression'] as String,
      suggestion: payload['suggestion'] as String,
      createdAt: DateTime.parse(row.createdAt).toLocal(),
      updatedAt: now,
      syncState: SyncState.pending,
    );
  }

  Future<void> delete(String id) async {
    final now = _now();
    await _db.transaction(() async {
      final row = await (_db.select(_db.feedbackLocalTable)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (row == null) throw StateError('Kiriman tidak ditemukan.');

      await (_db.delete(_db.feedbackLocalTable)..where((t) => t.id.equals(id)))
          .go();
      await _outbox.enqueue(
        entity: OutboxEntity.feedback,
        op: OutboxOp.delete,
        payload: jsonEncode({'id': id}),
        now: now,
      );
    });
  }

  /// Reconciles delivered feedback after the shared outbox becomes empty.
  Future<void> markPendingSynced() async {
    if (await _outbox.pendingCount() > 0) return;
    await (_db.update(_db.feedbackLocalTable)
          ..where(
              (t) => t.syncState.isIn([SyncState.pending, SyncState.failed])))
        .write(const FeedbackLocalTableCompanion(
      syncState: Value(SyncState.synced),
    ));
  }

  /// Exposes permanently exhausted feedback items as failed in local history.
  Future<void> markDeadLettersFailed() async {
    final dead = await _outbox.getDead();
    for (final item
        in dead.where((item) => item.entity == OutboxEntity.feedback)) {
      final decoded = jsonDecode(item.payload);
      if (decoded is! Map || decoded['id'] is! String) continue;
      await (_db.update(_db.feedbackLocalTable)
            ..where((t) => t.id.equals(decoded['id'] as String)))
          .write(const FeedbackLocalTableCompanion(
        syncState: Value(SyncState.failed),
      ));
    }
  }
}
