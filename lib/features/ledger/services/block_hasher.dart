// M12 Blockchain Sederhana (FR-BLK, AC-BLK-06)
import '../../../core/constants/app_constants.dart';
import '../../../core/security/hash_utils.dart';
import '../models/block.dart';

/// Menghitung hash blok:
///
/// ```
/// hash = SHA256( index | timestamp | user_id | donor_alias | campaign |
///                amount | currency | amount_idr | rate_used |
///                prev_hash | nonce )
/// ```
///
/// Seluruh bidang dirangkai sebagai teks apa adanya dengan pemisah "|", lalu
/// di-hash sebagai UTF-8. Server memakai rumus yang sama (FR-BLK-06), jadi
/// jangan mengubah urutan atau format bidang tanpa mengubah server.
class BlockHasher {
  const BlockHasher();

  static const String _sep = AppConstants.ledgerFieldSeparator;

  /// Bidang bebas (alias, kampanye) tidak boleh memuat pemisah karena akan
  /// membuat masukan hash ambigu. Dipakai saat blok dibuat, bukan saat
  /// verifikasi (blok yang sudah ada dihitung apa adanya).
  static String sanitize(String field) => field.replaceAll(_sep, '/').trim();

  /// Seluruh masukan hash sebelum nonce, diakhiri pemisah. Pencarian nonce
  /// (proof of work) cukup menambahkan angka nonce di belakangnya.
  String prefix({
    required int index,
    required String timestamp,
    required String userId,
    required String donorAlias,
    required String campaign,
    required String amount,
    required String currency,
    required String amountIdr,
    required String rateUsed,
    required String prevHash,
  }) {
    return [
      index,
      timestamp,
      userId,
      donorAlias,
      campaign,
      amount,
      currency,
      amountIdr,
      rateUsed,
      prevHash,
    ].join(_sep) + _sep;
  }

  String prefixFor(Block block, String userId) {
    return prefix(
      index: block.index,
      timestamp: block.timestamp,
      userId: userId,
      donorAlias: block.donorAlias,
      campaign: block.campaign,
      amount: block.amount,
      currency: block.currency,
      amountIdr: block.amountIdr,
      rateUsed: block.rateUsed,
      prevHash: block.prevHash,
    );
  }

  /// Hash heksadesimal huruf kecil sepanjang 64 karakter.
  String compute(Block block, String userId) {
    return HashUtils.sha256Hex('${prefixFor(block, userId)}${block.nonce}');
  }
}
