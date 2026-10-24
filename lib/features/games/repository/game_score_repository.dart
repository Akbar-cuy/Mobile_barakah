import 'dart:convert';
import 'dart:math';

import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_status.dart';

class GameScoreRepository {
  GameScoreRepository({
    required this.db,
    Random? random,
  }) : _random = random ?? Random.secure();

  final AppDatabase db;
  final Random _random;

  static const _directionBestKey = 'game_score_direction_best';

  Future<int> directionBest() async {
    final raw = await db.settingsDao.get(_directionBestKey);
    if (raw == null) return 0;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map && decoded['score'] is int) {
        return decoded['score'] as int;
      }
    } on FormatException {
      return 0;
    }
    return 0;
  }

  /// Persists only a new local record. The outbox retains it for authenticated
  /// retry; the game score Edge Function accepts duplicate IDs idempotently.
  Future<bool> saveDirectionBest(int score) async {
    if (score < 0) throw ArgumentError.value(score, 'score');
    if (score <= await directionBest()) return false;
    final now = DateTime.now().toUtc();
    final id = _uuidV4(_random);
    final payload = {
      'id': id,
      'game': 'direction',
      'score': score,
      'created_at': now.toIso8601String(),
    };
    await db.transaction(() async {
      await db.settingsDao.set(
        _directionBestKey,
        jsonEncode({'score': score, 'created_at': now.toIso8601String()}),
        now: now,
      );
      await db.outboxDao.enqueue(
        entity: OutboxEntity.gameScore,
        op: OutboxOp.create,
        payload: jsonEncode(payload),
        now: now,
      );
    });
    return true;
  }

  static String _uuidV4(Random random) {
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
