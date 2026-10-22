// M12 Blockchain Sederhana (FR-BLK-03, NFR-03)
import 'dart:convert';
import 'dart:isolate';

import 'package:crypto/crypto.dart';

import '../../../core/config/app_config.dart';
import '../../../core/security/hash_utils.dart';

/// Hasil pencarian nonce.
class MiningResult {
  const MiningResult({
    required this.nonce,
    required this.hash,
    required this.attempts,
  });

  final int nonce;
  final String hash;

  /// Jumlah hash yang dihitung, termasuk yang berhasil.
  final int attempts;
}

/// Proof of work ringan: hash harus diawali sejumlah digit heksadesimal nol
/// (AppConfig.powDifficulty, bawaan 3). Nilai ini harus sama dengan server.
class ProofOfWork {
  const ProofOfWork({
    this.difficulty = AppConfig.powDifficulty,
    this.maxAttempts = 50000000,
  });

  final int difficulty;

  /// Pengaman agar pencarian tidak berjalan tanpa akhir.
  final int maxAttempts;

  bool meets(String hash) => HashUtils.hasLeadingZeros(hash, difficulty);

  /// Mencari nonce di thread saat ini. Untuk uji dan alat bantu. Pemakaian dari
  /// antarmuka harus lewat [mine] agar tampilan tidak macet.
  MiningResult mineSync(String prefix) =>
      _search(prefix, difficulty, maxAttempts);

  /// Mencari nonce di isolate terpisah (FR-BLK-03). [prefix] adalah masukan
  /// hash sebelum nonce (lihat BlockHasher.prefix).
  Future<MiningResult> mine(String prefix) {
    final zeros = difficulty;
    final limit = maxAttempts;
    return Isolate.run(() => _search(prefix, zeros, limit));
  }
}

MiningResult _search(String prefix, int difficulty, int maxAttempts) {
  final zeros = '0' * difficulty;
  for (var nonce = 0; nonce < maxAttempts; nonce++) {
    final hash = sha256.convert(utf8.encode('$prefix$nonce')).toString();
    if (hash.startsWith(zeros)) {
      return MiningResult(nonce: nonce, hash: hash, attempts: nonce + 1);
    }
  }
  throw StateError('Nonce tidak ditemukan dalam $maxAttempts percobaan.');
}
