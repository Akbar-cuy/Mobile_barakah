import 'package:flutter/material.dart';

import '../models/feedback_entry.dart';
import '../repository/feedback_repository.dart';

// State untuk layar Saran dan Kesan
class FeedbackProvider extends ChangeNotifier {
  final FeedbackRepository _repository = FeedbackRepository.instance;

  bool _disposed = false;

  // ---------- State form ----------
  int rating = 0;
  String impression = '';
  String suggestion = '';
  bool submitted = false; // true setelah pengguna menekan Kirim
  bool saving = false;
  FeedbackEntry? editing; // tidak null saat mengubah kiriman

  // ---------- State riwayat ----------
  bool syncing = false;
  String? lastSubmittedId; // untuk kartu ringkasan (FR.FB.06)

  FeedbackProvider() {
    // Kirim kiriman yang menunggu setiap layar dibuka
    syncPending();
  }

  // Cegah notifyListeners dipanggil setelah provider dibuang
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  List<FeedbackEntry> get entries => _repository.entries;

  // =====================================================
  // Validasi (FR.FB.02)
  // =====================================================

  bool get showErrors => submitted;

  String? get ratingError => rating == 0 ? 'Pilih penilaian bintang.' : null;

  String? get impressionError {
    final length = impression.trim().length;
    if (length < 10) return 'Kesan minimal 10 karakter.';
    if (length > 500) return 'Kesan maksimal 500 karakter.';
    return null;
  }

  String? get suggestionError {
    final length = suggestion.trim().length;
    if (length < 10) return 'Saran minimal 10 karakter.';
    if (length > 500) return 'Saran maksimal 500 karakter.';
    return null;
  }

  // =====================================================
  // Form
  // =====================================================

  void setRating(int value) {
    rating = value;
    notifyListeners();
  }

  void setImpression(String text) {
    impression = text;
    notifyListeners();
  }

  void setSuggestion(String text) {
    suggestion = text;
    notifyListeners();
  }

  void _clearForm() {
    rating = 0;
    impression = '';
    suggestion = '';
    submitted = false;
    editing = null;
  }

  // Kirim kiriman baru, atau simpan perubahan bila sedang mengubah.
  // Mengembalikan pesan untuk snackbar, atau null bila form belum valid.
  Future<String?> submit() async {
    submitted = true;

    if (ratingError != null ||
        impressionError != null ||
        suggestionError != null) {
      notifyListeners();
      return null;
    }

    saving = true;
    notifyListeners();

    final FeedbackEntry entry;
    final String message;
    final current = editing;

    if (current == null) {
      entry = await _repository.add(
        rating: rating,
        impression: impression.trim(),
        suggestion: suggestion.trim(),
      );
      message = entry.isSynced
          ? 'Kesan dan saran terkirim'
          : 'Kesan dan saran tersimpan, menunggu koneksi';
    } else {
      entry = await _repository.update(
        current.id,
        rating: rating,
        impression: impression.trim(),
        suggestion: suggestion.trim(),
      );
      message = entry.isSynced
          ? 'Kiriman diperbarui'
          : 'Perubahan tersimpan, menunggu koneksi';
    }

    lastSubmittedId = entry.id;
    _clearForm();
    saving = false;
    notifyListeners();
    return message;
  }

  // =====================================================
  // Ubah dan hapus (FR.FB.05)
  // =====================================================

  void startEdit(FeedbackEntry entry) {
    editing = entry;
    rating = entry.rating;
    impression = entry.impression;
    suggestion = entry.suggestion;
    submitted = false;
    notifyListeners();
  }

  void cancelEdit() {
    _clearForm();
    notifyListeners();
  }

  Future<void> deleteEntry(FeedbackEntry entry) async {
    if (editing?.id == entry.id) _clearForm();
    if (lastSubmittedId == entry.id) lastSubmittedId = null;

    // Penghapusan lokal terjadi langsung, jadi tampilan bisa diperbarui
    // sebelum server membalas
    final future = _repository.delete(entry.id);
    notifyListeners();
    await future;
    notifyListeners();
  }

  // =====================================================
  // Ringkasan kiriman terakhir (FR.FB.06)
  // =====================================================

  // Diambil dari daftar supaya statusnya selalu terbaru
  FeedbackEntry? get summaryEntry {
    final id = lastSubmittedId;
    if (id == null) return null;
    for (final e in entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  void clearSummary() {
    lastSubmittedId = null;
    notifyListeners();
  }

  // =====================================================
  // Sinkronisasi
  // =====================================================

  Future<void> syncPending() async {
    syncing = true;
    notifyListeners();
    await _repository.syncPending();
    syncing = false;
    notifyListeners();
  }
}