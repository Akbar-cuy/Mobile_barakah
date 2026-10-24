// M13 Fitur LLM (FR-LLM)
// Pengelola state layar Tanya Fikih Dasar: kirim pertanyaan, status memuat,
// galat dan kirim ulang, pencarian riwayat, serta hapus riwayat.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../models/chat_message.dart';
import '../repository/chat_repository.dart';

// Batas panjang pertanyaan (FR-LLM-07)
const int batasPanjangPertanyaan = 500;

// ====== STATE ======
// Semua data yang dibutuhkan layar chat ada di sini.
class ChatState {
  final List<ChatMessage> pesan; // seluruh riwayat chat
  final bool memuat; // true saat menunggu jawaban AI
  final String galat; // pesan galat, kosong bila tidak ada galat
  final String kataKunci; // kata kunci pencarian riwayat

  const ChatState({
    this.pesan = const [],
    this.memuat = false,
    this.galat = '',
    this.kataKunci = '',
  });

  // salinan state dengan sebagian nilai diganti
  // (untuk menghapus galat, isi galat dengan teks kosong '')
  ChatState salin({
    List<ChatMessage>? pesan,
    bool? memuat,
    String? galat,
    String? kataKunci,
  }) {
    return ChatState(
      pesan: pesan ?? this.pesan,
      memuat: memuat ?? this.memuat,
      galat: galat ?? this.galat,
      kataKunci: kataKunci ?? this.kataKunci,
    );
  }

  // pesan yang ditampilkan: semua pesan, atau hasil pencarian bila ada kata kunci (FR-SRC-06)
  List<ChatMessage> get pesanTampil {
    if (kataKunci.trim().isEmpty) {
      return pesan;
    }
    final kata = kataKunci.trim().toLowerCase();
    return pesan.where((p) => p.content.toLowerCase().contains(kata)).toList();
  }

  // true bila ada pertanyaan yang gagal terkirim (untuk tombol Kirim ulang)
  bool get adaYangGagal {
    return pesan.any((p) => p.dariUser && p.syncState == 'failed');
  }
}

// ====== NOTIFIER ======
class ChatNotifier extends Notifier<ChatState> {
  ChatRepository get _repo => ref.read(chatRepositoryProvider);

  @override
  ChatState build() {
    muatRiwayat(); // ambil riwayat saat provider pertama dipakai
    return const ChatState();
  }

  // ambil riwayat chat yang tersimpan
  Future<void> muatRiwayat() async {
    try {
      final riwayat = await _repo.ambilRiwayat();
      state = state.salin(pesan: riwayat);
    } catch (e) {
      state = state.salin(galat: 'Riwayat chat gagal dimuat.');
    }
  }

  // kirim pertanyaan baru
  Future<void> kirim(String teks) async {
    final isi = teks.trim();

    if (isi.isEmpty) return;
    if (state.memuat) return; // jangan kirim dua kali sekaligus

    if (isi.length > batasPanjangPertanyaan) {
      state = state.salin(
        galat: 'Pertanyaan maksimal $batasPanjangPertanyaan karakter.',
      );
      return;
    }

    final pesanUser = ChatMessage.baru('user', isi);
    state = state.salin(
      pesan: [...state.pesan, pesanUser],
      memuat: true,
      galat: '',
    );
    await _mintaJawaban(pesanUser);
  }

  // kirim ulang pertanyaan terakhir yang gagal, tanpa menggandakan pesan (FR-LLM-10)
  Future<void> kirimUlang() async {
    if (state.memuat) return;

    final gagal = state.pesan
        .where((p) => p.dariUser && p.syncState == 'failed')
        .toList();
    if (gagal.isEmpty) return;

    final pesanUser = gagal.last;
    pesanUser.syncState = 'pending';
    state = state.salin(pesan: [...state.pesan], memuat: true, galat: '');

    await _mintaJawaban(pesanUser);
  }

  // minta jawaban AI untuk satu pertanyaan
  Future<void> _mintaJawaban(ChatMessage pesanUser) async {
    try {
      await _repo.simpan(pesanUser);
      final pesanAI = await _repo.kirimPertanyaan(pesanUser);

      pesanUser.syncState = 'synced';
      await _repo.tandaiTersinkron(pesanUser);
      await _repo.simpan(pesanAI);

      state = state.salin(pesan: [...state.pesan, pesanAI], memuat: false);
    } catch (e) {
      pesanUser.syncState = 'failed';
      try {
        await _repo.simpan(pesanUser);
      } catch (_) {
        // Pertahankan galat jaringan utama pada layar.
      }
      state = state.salin(
        pesan: [...state.pesan],
        memuat: false,
        galat: e is ApiException
            ? e.message
            : 'Gagal terhubung. Periksa koneksi lalu coba lagi.',
      );
    }
  }

  // ubah kata kunci pencarian riwayat
  void cari(String kata) {
    state = state.salin(kataKunci: kata);
  }

  // hapus seluruh riwayat (FR-LLM-08)
  Future<void> hapusRiwayat() async {
    try {
      await _repo.hapusRiwayat();
      state = const ChatState();
    } catch (e) {
      state = state.salin(galat: 'Riwayat gagal dihapus.');
    }
  }

  // tutup pesan galat
  void tutupGalat() {
    state = state.salin(galat: '');
  }
}

// provider yang dipakai di layar: ref.watch(chatProvider)
final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
