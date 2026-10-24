// Kampanye donasi (PRD M11)
class Campaign {
  final String id;
  final String title;
  final String description;
  final String category; // contoh: Air, Pendidikan, Masjid
  final double targetIdr;
  final int version;

  const Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetIdr,
    required this.version,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'target_idr': targetIdr,
        'version': version,
      };
}

enum CampaignDataSource { network, cache, unavailable }

class CampaignLoadResult {
  const CampaignLoadResult({
    required this.items,
    required this.source,
    this.checkedAt,
    this.message,
  });

  final List<Campaign> items;
  final CampaignDataSource source;

  /// Last time the cache envelope was checked or updated after a valid fetch.
  final DateTime? checkedAt;

  /// Safe user-facing notice when data is unavailable or cache persistence fails.
  final String? message;
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
  final bool isSynced;

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
    this.isSynced = false,
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
