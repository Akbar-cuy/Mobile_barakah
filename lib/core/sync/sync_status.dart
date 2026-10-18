// M20 Basis Data Lokal, Online, dan Sinkronisasi (FR-SYNC, FR-API)

/// Nilai kolom sync_state pada tabel lokal (PRD Tabel 12).
abstract final class SyncState {
  static const String pending = 'pending';
  static const String synced = 'synced';
  static const String failed = 'failed';
}

/// Status sinkronisasi keseluruhan untuk Beranda dan Pengaturan
/// (FR-LBS-06, FR-SYNC-07).
enum SyncStatus { synced, pending, error }

/// Jenis operasi pada antrean outbox (kolom op).
abstract final class OutboxOp {
  static const String create = 'create';
  static const String update = 'update';
  static const String delete = 'delete';
}

abstract final class OutboxEntity {
  static const String donation = 'donation';
  static const String feedback = 'feedback';
  static const String favoriteMosque = 'favorite_mosque';
  static const String tasbihLog = 'tasbih_log';
  static const String quizAttempt = 'quiz_attempt';
  static const String gameScore = 'game_score';
  static const String chatMessage = 'chat_message';
  static const String zakatCalc = 'zakat_calc';
  static const String setting = 'setting';
  static const String sessionRevoke = 'session_revoke';
}
