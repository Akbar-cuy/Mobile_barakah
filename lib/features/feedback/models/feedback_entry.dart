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
    required this.synced,
  });

  factory FeedbackEntry.fromRow(FeedbackLocalTableData row) {
    return FeedbackEntry(
      id: row.id,
      rating: row.rating,
      impression: row.impression,
      suggestion: row.suggestion,
      createdAt: DateTime.parse(row.createdAt).toLocal(),
      updatedAt: DateTime.parse(row.updatedAt).toLocal(),
      synced: row.syncState == SyncState.synced,
    );
  }

  final String id;
  final int rating;
  final String impression;
  final String suggestion;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// False selama masih menunggu dikirim ke server.
  final bool synced;
}
