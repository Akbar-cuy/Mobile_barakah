import 'dart:math';

import '../models/feedback_entry.dart';

// Penyimpanan dan pengiriman Saran dan Kesan (PRD M18).
// Alur offline first: simpan lokal dulu (pending), lalu kirim ke server.
// Bila gagal, tetap pending dan dikirim ulang lewat syncPending().
//
// Sementara data di memori. Nanti diganti:
// - penyimpanan lokal -> tabel feedback_local (SQLite)
// - kirim -> endpoint POST, PUT, DELETE /feedback
// - syncPending() dipanggil SyncService saat koneksi pulih (M20)
class FeedbackRepository {
  FeedbackRepository._();

  // Satu instance dipakai bersama supaya riwayat tidak hilang
  // saat layar ditutup dan dibuka lagi.
  static final FeedbackRepository instance = FeedbackRepository._();

  // Hanya untuk uji: isi false untuk meniru perangkat offline
  // (kiriman jadi "Menunggu"), lalu true lagi dan sinkronkan.
  static bool serverOnline = true;

  // Terbaru di urutan pertama
  final List<FeedbackEntry> _entries = [];

  // Penghapusan yang belum sampai ke server (dihapus saat offline)
  final List<String> _pendingDeleteIds = [];

  List<FeedbackEntry> get entries => List.unmodifiable(_entries);

  // Kiriman baru (FR.FB.03)
  Future<FeedbackEntry> add({
    required int rating,
    required String impression,
    required String suggestion,
  }) async {
    final now = DateTime.now().toUtc();
    final entry = FeedbackEntry(
      id: _newId(),
      rating: rating,
      impression: impression,
      suggestion: suggestion,
      createdAt: now,
      updatedAt: now,
      syncState: FeedbackEntry.statePending,
    );
    _entries.insert(0, entry);
    return _send(entry.id);
  }

  // Ubah kiriman milik sendiri (FR.FB.05)
  Future<FeedbackEntry> update(
    String id, {
    required int rating,
    required String impression,
    required String suggestion,
  }) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index == -1) throw StateError('Kiriman tidak ditemukan');

    _entries[index] = _entries[index].copyWith(
      rating: rating,
      impression: impression,
      suggestion: suggestion,
      updatedAt: DateTime.now().toUtc(),
      syncState: FeedbackEntry.statePending,
    );
    return _send(id);
  }

  // Hapus kiriman dari lokal dan server (FR.FB.05)
  Future<void> delete(String id) async {
    // Bagian ini jalan langsung, sebelum menunggu server
    _entries.removeWhere((e) => e.id == id);

    final ok = await _sendDelete(id);
    if (!ok && !_pendingDeleteIds.contains(id)) {
      _pendingDeleteIds.add(id);
    }
  }

  // Kirim semua yang masih menunggu (dipanggil saat online lagi)
  Future<void> syncPending() async {
    for (final id in List<String>.from(_pendingDeleteIds)) {
      if (await _sendDelete(id)) _pendingDeleteIds.remove(id);
    }

    final waitingIds = _entries
        .where((e) => e.syncState != FeedbackEntry.stateSynced)
        .map((e) => e.id)
        .toList();

    for (final id in waitingIds) {
      // Bisa saja sudah dihapus pengguna selama proses berjalan
      if (_entries.indexWhere((e) => e.id == id) == -1) continue;
      await _send(id);
    }
  }

  // ---------- Bagian internal ----------

  // Coba kirim satu kiriman, lalu tandai synced bila berhasil
  Future<FeedbackEntry> _send(String id) async {
    final before = _entries.firstWhere((e) => e.id == id);
    final ok = await _sendToServer(before);

    // Daftar bisa berubah selama menunggu, jadi cari lagi
    final index = _entries.indexWhere((e) => e.id == id);
    if (index == -1) return before;

    if (ok) {
      _entries[index] =
          _entries[index].copyWith(syncState: FeedbackEntry.stateSynced);
    }
    return _entries[index];
  }

  // TODO: ganti dengan POST /feedback (baru) atau PUT /feedback/{id} (ubah).
  // Karena id dibuat di klien, pengiriman ulang tidak membuat duplikat.
  Future<bool> _sendToServer(FeedbackEntry entry) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return serverOnline;
  }

  // TODO: ganti dengan DELETE /feedback/{id}
  Future<bool> _sendDelete(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return serverOnline;
  }

  // UUID versi 4 sederhana
  String _newId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}