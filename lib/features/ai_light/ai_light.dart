// M14 Fitur AI Ringan (FR-AI)
// Satu file untuk seluruh AI ringan yang berjalan di perangkat (tanpa LLM):
//   1) AdaptiveQuizEngine   : rekomendasi kuis adaptif memakai EWMA (FR-AI-01, FR-AI-02)
//   2) DhikrTargetPredictor : prediksi target dzikir harian (FR-AI-03)
//   3) AiLightNotifier      : penghubung ke layar, bisa dimatikan (FR-AI-05)
// Semua hitungan di perangkat dan tidak mengirim data ke luar (FR-AI-06).
// Setiap rekomendasi punya alasan singkat yang bisa dibaca pengguna (FR-AI-04).

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ====== DATA MASUKAN ======
// Satu sesi kuis yang sudah selesai (sesuai tabel quiz_attempt di PRD).
class HasilKuis {
  final String kategori;
  final int benar;
  final int total;
  final DateTime waktu;

  const HasilKuis({
    required this.kategori,
    required this.benar,
    required this.total,
    required this.waktu,
  });

  // akurasi 0.0 sampai 1.0
  double get akurasi {
    if (total == 0) return 0;
    return benar / total;
  }
}

// Jumlah dzikir pada satu hari (sesuai tabel tasbih_log di PRD).
class DzikirHarian {
  final DateTime tanggal;
  final int jumlah;

  const DzikirHarian({required this.tanggal, required this.jumlah});
}

// ====== HASIL REKOMENDASI ======
// Komposisi 10 soal untuk satu sesi kuis.
class KomposisiSoal {
  final int mudah;
  final int sedang;
  final int sulit;
  final String alasan;

  const KomposisiSoal({
    required this.mudah,
    required this.sedang,
    required this.sulit,
    required this.alasan,
  });
}

// Kategori kuis yang disarankan untuk dimainkan berikutnya.
class KategoriSaran {
  final String kategori;
  final String alasan;

  const KategoriSaran({required this.kategori, required this.alasan});
}

// Target dzikir yang disarankan untuk hari ini.
class PrediksiDzikir {
  final int target;
  final bool adaPrediksi; // false bila riwayat kurang dan memakai target bawaan
  final String alasan;

  const PrediksiDzikir({
    required this.target,
    required this.adaPrediksi,
    required this.alasan,
  });
}

// ====== 1. KUIS ADAPTIF (EWMA) ======
class AdaptiveQuizEngine {
  const AdaptiveQuizEngine();

  // Kategori kuis (FR-GAME-01)
  static const List<String> daftarKategori = [
    'Rukun Islam dan Iman',
    'Sejarah Nabi',
    'Fikih Dasar',
    'Umum',
  ];

  static const int jumlahSesi = 10; // sesi terakhir yang dipakai
  static const double alpha = 0.3; // bobot sesi terbaru pada EWMA

  // Akurasi tertimbang eksponensial pada maksimal 10 sesi terakhir.
  // Sesi yang lebih baru punya bobot lebih besar. Hasil null bila belum pernah main.
  double? hitungEwma(String kategori, List<HasilKuis> riwayat) {
    final sesi =
        riwayat.where((h) => h.kategori == kategori && h.total > 0).toList();
    if (sesi.isEmpty) return null;

    sesi.sort((a, b) => a.waktu.compareTo(b.waktu)); // lama ke baru
    final terakhir =
        sesi.length > jumlahSesi ? sesi.sublist(sesi.length - jumlahSesi) : sesi;

    double ewma = terakhir.first.akurasi;
    for (int i = 1; i < terakhir.length; i++) {
      ewma = alpha * terakhir[i].akurasi + (1 - alpha) * ewma;
    }
    return ewma;
  }

  // Komposisi 10 soal: akurasi tinggi menaikkan soal sulit, akurasi rendah menurunkannya.
  KomposisiSoal komposisiSoal(String kategori, List<HasilKuis> riwayat) {
    final ewma = hitungEwma(kategori, riwayat);

    if (ewma == null) {
      return KomposisiSoal(
        mudah: 3,
        sedang: 4,
        sulit: 3,
        alasan: 'Belum ada riwayat di $kategori, memakai komposisi seimbang.',
      );
    }

    final persen = (ewma * 100).round();

    if (ewma >= 0.8) {
      return KomposisiSoal(
        mudah: 1,
        sedang: 3,
        sulit: 6,
        alasan: 'Akurasi Anda pada $kategori $persen persen, soal sulit ditambah.',
      );
    }
    if (ewma < 0.5) {
      return KomposisiSoal(
        mudah: 6,
        sedang: 3,
        sulit: 1,
        alasan:
            'Akurasi Anda pada $kategori $persen persen, soal mudah ditambah.',
      );
    }
    return KomposisiSoal(
      mudah: 3,
      sedang: 4,
      sulit: 3,
      alasan: 'Akurasi Anda pada $kategori $persen persen, komposisi seimbang.',
    );
  }

  // Berapa hari sejak kategori ini terakhir dimainkan (0 bila belum pernah).
  int hariSejakMain(
    String kategori,
    List<HasilKuis> riwayat,
    DateTime sekarang,
  ) {
    DateTime? terakhir;
    for (final h in riwayat) {
      if (h.kategori != kategori) continue;
      if (terakhir == null || h.waktu.isAfter(terakhir)) {
        terakhir = h.waktu;
      }
    }
    if (terakhir == null) return 0;
    return sekarang.difference(terakhir).inDays;
  }

  // Kategori yang disarankan: yang belum pernah dimainkan, lalu yang akurasinya
  // paling rendah dan paling lama tidak dimainkan.
  KategoriSaran kategoriBerikutnya(List<HasilKuis> riwayat, DateTime sekarang) {
    // 1) kategori yang belum pernah dimainkan didahulukan
    for (final k in daftarKategori) {
      final pernah = riwayat.any((h) => h.kategori == k);
      if (!pernah) {
        return KategoriSaran(
          kategori: k,
          alasan: 'Anda belum pernah memainkan $k.',
        );
      }
    }

    // 2) semua sudah pernah dimainkan: pilih skor prioritas tertinggi
    String terbaik = daftarKategori.first;
    double skorTerbaik = -1;
    String alasanTerbaik = '';

    for (final k in daftarKategori) {
      final ewma = hitungEwma(k, riwayat) ?? 0.5;
      final hari = hariSejakMain(k, riwayat, sekarang);
      final hariDipakai = hari > 14 ? 14 : hari;

      // makin rendah akurasi dan makin lama tidak dimainkan, makin tinggi skornya
      final skor = (1 - ewma) + (hariDipakai / 14) * 0.5;

      if (skor > skorTerbaik) {
        skorTerbaik = skor;
        terbaik = k;
        if (ewma < 0.7) {
          alasanTerbaik = 'Akurasi Anda pada $k ${(ewma * 100).round()} persen.';
        } else {
          alasanTerbaik = 'Sudah $hari hari Anda tidak memainkan $k.';
        }
      }
    }

    return KategoriSaran(kategori: terbaik, alasan: alasanTerbaik);
  }
}

// ====== 2. PREDIKSI TARGET DZIKIR ======
class DhikrTargetPredictor {
  const DhikrTargetPredictor();

  static const int targetBawaan = 33;
  static const int minimalHari = 3; // kurang dari ini: tidak ada prediksi
  static const int maksimalHari = 14; // riwayat yang dipakai

  // Rata-rata dzikir per hari pada maksimal 14 hari terakhir yang ada datanya.
  PrediksiDzikir prediksi(List<DzikirHarian> riwayat) {
    // jumlahkan dzikir per hari
    final perHari = <DateTime, int>{};
    for (final d in riwayat) {
      final hari = DateTime(d.tanggal.year, d.tanggal.month, d.tanggal.day);
      perHari[hari] = (perHari[hari] ?? 0) + d.jumlah;
    }

    if (perHari.length < minimalHari) {
      return PrediksiDzikir(
        target: targetBawaan,
        adaPrediksi: false,
        alasan:
            'Riwayat dzikir baru ${perHari.length} hari, memakai target bawaan $targetBawaan.',
      );
    }

    // ambil hari-hari terbaru
    final urut = perHari.keys.toList();
    urut.sort((a, b) => b.compareTo(a)); // baru ke lama
    final dipakai =
        urut.length > maksimalHari ? urut.sublist(0, maksimalHari) : urut;

    int total = 0;
    for (final hari in dipakai) {
      total += perHari[hari] ?? 0;
    }
    final target = (total / dipakai.length).round();

    if (target < 1) {
      return PrediksiDzikir(
        target: targetBawaan,
        adaPrediksi: false,
        alasan: 'Belum ada dzikir tercatat, memakai target bawaan $targetBawaan.',
      );
    }

    return PrediksiDzikir(
      target: target,
      adaPrediksi: true,
      alasan: 'Rata-rata ${dipakai.length} hari terakhir: $target dzikir per hari.',
    );
  }
}

// ====== 3. PROVIDER UNTUK LAYAR ======
class AiLightState {
  final bool aktif; // false bila pengguna mematikan rekomendasi (FR-AI-05)
  final KategoriSaran? kategori;
  final KomposisiSoal? soal;
  final PrediksiDzikir? dzikir;

  const AiLightState({
    this.aktif = true,
    this.kategori,
    this.soal,
    this.dzikir,
  });
}

class AiLightNotifier extends Notifier<AiLightState> {
  final AdaptiveQuizEngine _mesinKuis = const AdaptiveQuizEngine();
  final DhikrTargetPredictor _prediktor = const DhikrTargetPredictor();

  @override
  AiLightState build() {
    return const AiLightState();
  }

  // Hitung ulang semua rekomendasi dari riwayat terbaru.
  // Panggil saat layar Kuis atau Tasbih dibuka.
  void hitung({
    required List<HasilKuis> riwayatKuis,
    required List<DzikirHarian> riwayatDzikir,
  }) {
    if (!state.aktif) return;

    final saran = _mesinKuis.kategoriBerikutnya(riwayatKuis, DateTime.now());
    final soal = _mesinKuis.komposisiSoal(saran.kategori, riwayatKuis);
    final dzikir = _prediktor.prediksi(riwayatDzikir);

    state = AiLightState(
      aktif: true,
      kategori: saran,
      soal: soal,
      dzikir: dzikir,
    );
  }

  // Nyalakan atau matikan rekomendasi. Saat dimatikan, hasil lama dikosongkan.
  void atur(bool aktif) {
    state = AiLightState(aktif: aktif);
  }
}

// dipakai di layar: ref.watch(aiLightProvider)
final aiLightProvider = NotifierProvider<AiLightNotifier, AiLightState>(
  AiLightNotifier.new,
);