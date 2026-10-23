import 'package:barakah/features/ledger/services/block_hasher.dart';
import 'package:barakah/features/ledger/services/proof_of_work.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ledger_fixtures.dart';

void main() {
  const hasher = BlockHasher();

  group('ProofOfWork', () {
    test('meets memeriksa awalan nol sesuai tingkat kesulitan', () {
      const pow = ProofOfWork(difficulty: 3);
      expect(pow.meets('000abc'), isTrue);
      expect(pow.meets('00abc0'), isFalse);
      expect(const ProofOfWork(difficulty: 1).meets('0abc'), isTrue);
    });

    test('mineSync menemukan nonce terkecil yang sama dengan referensi', () {
      final prefix = hasher.prefixFor(kBlock1, kUser);
      final result = const ProofOfWork().mineSync(prefix);
      expect(result.nonce, kBlock1.nonce);
      expect(result.hash, kBlock1.hash);
      expect(result.attempts, kBlock1.nonce + 1);
      expect(result.hash.startsWith('000'), isTrue);
    });

    test('AC-BLK-01: hasil mining berawalan "000" dan konsisten dengan BlockHasher', () {
      final prefix = hasher.prefixFor(kBlock2, kUser);
      final result = const ProofOfWork().mineSync(prefix);
      expect(result.hash.startsWith('000'), isTrue);
      expect(hasher.compute(kBlock2.copyWith(nonce: result.nonce), kUser), result.hash);
    });

    test('tingkat kesulitan dapat dikonfigurasi', () {
      final prefix = hasher.prefixFor(kGenesis.copyWith(nonce: 0), kUser);
      final easy = const ProofOfWork(difficulty: 1).mineSync(prefix);
      expect(easy.nonce, 9);
      expect(easy.hash,
          '0138dd758a0eecbeec82d5fb2639a66f2a30d16f1cdf2cdba2b05d691827e405');
      final hard = const ProofOfWork(difficulty: 4).mineSync(prefix);
      expect(hard.nonce, 89019);
      expect(hard.hash.startsWith('0000'), isTrue);
    });

    test('mine (isolate) memberi hasil sama dengan mineSync', () async {
      final prefix = hasher.prefixFor(kBlock1, kUser);
      final result = await const ProofOfWork().mine(prefix);
      expect(result.nonce, kBlock1.nonce);
      expect(result.hash, kBlock1.hash);
    });

    test('melempar StateError bila batas percobaan habis', () {
      final prefix = hasher.prefixFor(kBlock1, kUser);
      expect(
        () => const ProofOfWork(maxAttempts: 10).mineSync(prefix),
        throwsStateError,
      );
    });
  });
}
