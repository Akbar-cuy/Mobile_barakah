// M13 Fitur LLM (FR-LLM)

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message.dart';

class ChatRepository {
  final List<ChatMessage> _riwayat = [];

  // ambil seluruh riwayat chat
  Future<List<ChatMessage>> ambilRiwayat() async {
    // TODO: baca dari tabel chat_message (drift)
    return List.from(_riwayat);
  }

  // simpan satu pesan
  Future<void> simpan(ChatMessage pesan) async {
    // TODO: tulis ke tabel chat_message (drift) dan masukkan ke outbox
    _riwayat.add(pesan);
  }

  // kirim pertanyaan ke AI dan terima jawabannya
  Future<String> kirimPertanyaan(String pertanyaan) async {
    // TODO: panggil POST /ai/chat lewat api_client
    await Future.delayed(const Duration(seconds: 1));
    return 'Ini jawaban contoh untuk pertanyaan: "$pertanyaan"';
  }

  // hapus seluruh riwayat
  Future<void> hapusRiwayat() async {
    // TODO: hapus di drift dan panggil DELETE /ai/history
    _riwayat.clear();
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});
