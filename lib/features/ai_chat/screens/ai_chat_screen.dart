// M13 Fitur LLM (FR-LLM)
// Layar Tanya Fikih Dasar: kolom cari riwayat, daftar gelembung chat,
// status memuat, banner galat dengan kirim ulang, dan kolom input.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';

// Warna dari prototipe HTML
const Color _latar = Color(0xFFFBFAF6); // --bg
const Color _putih = Color(0xFFFFFFFF); // --sf
const Color _garis = Color(0xFFC9CEC9); // --ln
const Color _teks = Color(0xFF1B1F1D); // --on
const Color _teksSub = Color(0xFF4A524E); // --on2
const Color _hijau = Color(0xFF0E6B57); // --pri
const Color _hijauMuda = Color(0xFFCFEDE3); // --pc
const Color _tombol = Color(0xFF0A4F40); // --btn
const Color _merah = Color(0xFFB3261E); // --err

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _cariController = TextEditingController();
  final ScrollController _gulir = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _cariController.dispose();
    _gulir.dispose();
    super.dispose();
  }

  // gulir daftar chat ke pesan paling bawah
  void _gulirKeBawah() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_gulir.hasClients) {
        _gulir.animateTo(
          _gulir.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // kirim pertanyaan dari kolom input
  void _kirim() {
    final teks = _inputController.text;
    if (teks.trim().isEmpty) return;
    _inputController.clear();
    ref.read(chatProvider.notifier).kirim(teks);
  }

  // dialog konfirmasi hapus riwayat (AC-LLM-06)
  Future<void> _konfirmasiHapus() async {
    final hapus = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus riwayat chat?'),
          content: const Text(
            'Seluruh percakapan di perangkat ini dan di server akan dihapus.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: _merah)),
            ),
          ],
        );
      },
    );

    if (hapus == true) {
      _cariController.clear();
      ref.read(chatProvider.notifier).hapusRiwayat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);

    // gulir ke bawah setiap ada pesan baru
    ref.listen(chatProvider, (sebelum, sesudah) {
      if (sebelum == null || sebelum.pesan.length != sesudah.pesan.length) {
        _gulirKeBawah();
      }
    });

    final daftar = chat.pesanTampil;

    return Scaffold(
      backgroundColor: _latar,
      appBar: AppBar(
        backgroundColor: _latar,
        foregroundColor: _teks,
        elevation: 0,
        title: const Text(
          'Tanya Fikih Dasar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: chat.pesan.isEmpty ? null : _konfirmasiHapus,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus riwayat',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _kolomCari(),
            _bannerInfo(),
            Expanded(
              child: daftar.isEmpty
                  ? _keadaanKosong(chat.kataKunci.trim().isNotEmpty)
                  : ListView.builder(
                      controller: _gulir,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: daftar.length,
                      itemBuilder: (context, index) {
                        return ChatBubble(pesan: daftar[index]);
                      },
                    ),
            ),
            if (chat.memuat) _statusMemuat(),
            if (chat.galat.isNotEmpty) _bannerGalat(chat),
            _kolomInput(chat.memuat),
          ],
        ),
      ),
    );
  }

  // kolom cari riwayat (FR-LLM-08)
  Widget _kolomCari() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: TextField(
        controller: _cariController,
        onChanged: (kata) => ref.read(chatProvider.notifier).cari(kata),
        decoration: InputDecoration(
          hintText: 'Cari di riwayat',
          prefixIcon: const Icon(Icons.search, color: _teksSub),
          filled: true,
          fillColor: _putih,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: _garis),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: _hijau, width: 2),
          ),
        ),
      ),
    );
  }

  // pengingat bahwa jawaban bukan fatwa
  Widget _bannerInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _hijauMuda,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: _hijau),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Jawaban berupa informasi umum, bukan fatwa.',
              style: TextStyle(fontSize: 12, color: _teks),
            ),
          ),
        ],
      ),
    );
  }

  // tampilan saat belum ada chat atau hasil cari kosong (AC-SRC-03)
  Widget _keadaanKosong(bool sedangCari) {
    final judul = sedangCari ? 'Tidak ada hasil' : 'Belum ada percakapan';
    final isi = sedangCari
        ? 'Coba ubah kata kunci pencarian.'
        : 'Tanyakan sesuatu, misalnya: Apa saja rukun wudhu?';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 40, color: _teksSub),
            const SizedBox(height: 12),
            Text(
              judul,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              isi,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _teksSub),
            ),
          ],
        ),
      ),
    );
  }

  // status menunggu jawaban (FR-LLM-10)
  Widget _statusMemuat() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: _hijau),
          ),
          SizedBox(width: 10),
          Text(
            'Barakah AI sedang menjawab...',
            style: TextStyle(fontSize: 12, color: _teksSub),
          ),
        ],
      ),
    );
  }

  // pesan galat dengan tombol kirim ulang (FR-LLM-10)
  Widget _bannerGalat(ChatState chat) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE8E6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              chat.galat,
              style: const TextStyle(fontSize: 12, color: _merah),
            ),
          ),
          if (chat.adaYangGagal)
            TextButton(
              onPressed: chat.memuat
                  ? null
                  : () => ref.read(chatProvider.notifier).kirimUlang(),
              child: const Text('Kirim ulang'),
            ),
          IconButton(
            onPressed: () => ref.read(chatProvider.notifier).tutupGalat(),
            icon: const Icon(Icons.close, size: 18, color: _merah),
            tooltip: 'Tutup',
          ),
        ],
      ),
    );
  }

  // kolom input pertanyaan dan tombol Kirim
  Widget _kolomInput(bool memuat) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: _putih,
        border: Border(top: BorderSide(color: _garis)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              maxLength: batasPanjangPertanyaan,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _kirim(),
              decoration: InputDecoration(
                hintText: 'Ketik pertanyaan',
                counterText: '',
                filled: true,
                fillColor: _latar,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: _garis),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: _hijau, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: memuat ? null : _kirim,
              style: FilledButton.styleFrom(
                backgroundColor: _tombol,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              child: const Text('Kirim'),
            ),
          ),
        ],
      ),
    );
  }
}