// M18 Saran dan Kesan (FR-FB)
import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_status.dart';

class FeedbackEntry {
  const FeedbackEntry({
    required this.id,
    required this.rating,
    required this.impression,
    required this.suggestion,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
  });

  factory FeedbackEntry.fromRow(FeedbackLocalTableData row) {
    return FeedbackEntry(
      id: row.id,
      rating: row.rating,
      impression: row.impression,
      suggestion: row.suggestion,
      createdAt: DateTime.parse(row.createdAt).toLocal(),
      updatedAt: DateTime.parse(row.updatedAt).toLocal(),
      syncState: row.syncState,
    );
  }

  final String id;
  final int rating;
  final String impression;
  final String suggestion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncState;

  bool get isSynced => syncState == SyncState.synced;

  /// Status yang tampil di riwayat (FR-FB-04).
  String get statusLabel => isSynced ? 'Terkirim' : 'Menunggu';

  FeedbackEntry copyWith({
    int? rating,
    String? impression,
    String? suggestion,
    DateTime? updatedAt,
    String? syncState,
  }) {
    return FeedbackEntry(
      id: id,
      rating: rating ?? this.rating,
      impression: impression ?? this.impression,
      suggestion: suggestion ?? this.suggestion,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
    );
  }
}