import '../models/donation_models.dart';

// Perhitungan zakat maal dan zakat fitrah (PRD FR.ZKT.01 dan FR.ZKT.02)
class ZakatCalculator {
  static const double nisabGoldGram = 85; // nisab setara 85 gram emas
  static const double maalRate = 0.025; // 2,5 persen

  // Dua nilai ini bisa diubah pengguna di layar Zakat.
  // Angka bawaan hanya CONTOH, perlu disesuaikan dengan harga emas
  // dan ketetapan nilai fitrah yang berlaku.
  double goldPricePerGramIdr;
  double fitrahPerPersonIdr;

  ZakatCalculator({
    this.goldPricePerGramIdr = 1500000,
    this.fitrahPerPersonIdr = 45000,
  });

  double get nisabIdr => nisabGoldGram * goldPricePerGramIdr;

  // Zakat maal: 2,5% dari harta bila harta mencapai nisab
  ZakatResult calculateMaal(double wealthIdr) {
    final wajib = wealthIdr >= nisabIdr;
    return ZakatResult(
      type: 'maal',
      inputIdr: wealthIdr,
      nisabIdr: nisabIdr,
      resultIdr: wajib ? wealthIdr * maalRate : 0,
      wajib: wajib,
    );
  }

  // Zakat fitrah: jumlah jiwa x nilai per jiwa
  ZakatResult calculateFitrah(int persons) {
    final total = persons * fitrahPerPersonIdr;
    return ZakatResult(
      type: 'fitrah',
      inputIdr: total,
      nisabIdr: 0,
      resultIdr: total,
      wajib: persons > 0,
    );
  }
}
