// Satu kiriman Saran dan Kesan (PRD M18, tabel feedback_local)
class FeedbackEntry {
  // Nilai sync_state sesuai PRD
  static const String statePending = 'pending';
  static const String stateSynced = 'synced';
  static const String stateFailed = 'failed';

  final String id; // UUID dari klien
  final int rating; // 1 sampai 5
  final String impression; // kesan
  final String suggestion; // saran
  final DateTime createdAt; // disimpan sebagai UTC
  final DateTime updatedAt; // disimpan sebagai UTC
  final String syncState;

  const FeedbackEntry({
    required this.id,
    required this.rating,
    required this.impression,
    required this.suggestion,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
  });

  bool get isSynced => syncState == stateSynced;

  // Status yang tampil di riwayat (FR.FB.04): terkirim atau menunggu
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
