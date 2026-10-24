// Kampanye donasi (PRD M11)
class Campaign {
  final String id;
  final String title;
  final String description;
  final String category; // contoh: Air, Pendidikan, Masjid
  final double targetIdr;

  const Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetIdr,
  });
}

// Donasi yang sudah dikonfirmasi, lengkap dengan data blok ledger (PRD M12)
class Donation {
  final String id;
  final String campaignTitle;
  final String donorAlias;
  final double amount; // nominal dalam mata uang input
  final String currency; // IDR, USD, atau SAR
  final double amountIdr; // padanan dalam rupiah
  final double rateUsed; // kurs ke IDR yang dipakai
  final DateTime createdAt; // disimpan sebagai UTC

  // Data blok
  final int blockIndex;
  final String prevHash;
  final int nonce;
  final String hash;

  const Donation({
    required this.id,
    required this.campaignTitle,
    required this.donorAlias,
    required this.amount,
    required this.currency,
    required this.amountIdr,
    required this.rateUsed,
    required this.createdAt,
    required this.blockIndex,
    required this.prevHash,
    required this.nonce,
    required this.hash,
  });
}

// Hasil perhitungan zakat (PRD M11)
class ZakatResult {
  final String type; // 'maal' atau 'fitrah'
  final double inputIdr; // harta (maal) atau total nilai fitrah, dalam rupiah
  final double nisabIdr; // 0 untuk fitrah
  final double resultIdr; // zakat yang harus dibayar
  final bool wajib; // false kalau belum mencapai nisab

  const ZakatResult({
    required this.type,
    required this.inputIdr,
    required this.nisabIdr,
    required this.resultIdr,
    required this.wajib,
  });
}
