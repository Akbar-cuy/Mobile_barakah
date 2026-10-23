// M8 Tasbih Digital (FR-TSB-05)
import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_status.dart';

/// Satu sesi dzikir yang tersimpan. Satu baris per sesi, bukan per hari.
class TasbihLog {
  const TasbihLog({
    required this.id,
    required this.date,
    required this.target,
    required this.count,
    this.syncState = SyncState.pending,
    this.source = 'app',
  });

  factory TasbihLog.fromRow(TasbihLogTableData row) {
    return TasbihLog(
      id: row.id,
      date: row.date,
      target: row.target,
      count: row.count,
      syncState: row.syncState,
    );
  }

  /// Dari server (GET /sync/pull). Kolom tanggal di server bernama log_date.
  factory TasbihLog.fromJson(Map<String, dynamic> json) {
    return TasbihLog(
      id: json['id'].toString(),
      date: (json['log_date'] ?? json['date']).toString().substring(0, 10),
      target: (json['target'] as num).toInt(),
      count: (json['count'] as num).toInt(),
      syncState: SyncState.synced,
      source: json['source']?.toString() ?? 'app',
    );
  }

  /// Tanggal lokal yyyy-MM-dd.
  final String date;
  final String id;
  final int target;
  final int count;
  final String syncState;

  /// app atau iot (hitungan dari tasbih fisik ESP32, M21).
  final String source;

  bool get isCompleted => count >= target;

  bool get isSynced => syncState == SyncState.synced;

  /// Isi outbox (entity tasbih_log) untuk /sync/push. Kunci mengikuti kolom
  /// tabel tasbih_logs di server.
  Map<String, dynamic> toPayload() => {
        'id': id,
        'log_date': date,
        'target': target,
        'count': count,
        'source': source,
      };
}

/// Total hitungan dzikir pada satu hari.
class DailyDhikr {
  const DailyDhikr({required this.date, required this.total, required this.sessions});

  final String date;
  final int total;
  final int sessions;
}
