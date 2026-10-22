import 'package:barakah/features/ledger/models/block.dart';
import 'package:barakah/features/ledger/services/chain_verifier.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ledger_fixtures.dart';

void main() {
  const verifier = ChainVerifier();

  group('ChainVerifier', () {
    test('rantai kosong dianggap valid', () {
      final r = verifier.verify(const [], userId: kUser);
      expect(r.isValid, isTrue);
      expect(r.blockCount, 0);
    });

    test('AC-BLK-02: rantai tidak diubah, hasilnya valid beserta jumlah blok', () {
      final r = verifier.verify(kChain, userId: kUser);
      expect(r.isValid, isTrue);
      expect(r.blockCount, 3);
      expect(r.summary, 'Rantai valid: 3 blok');
      expect(r.firstInvalidIndex, isNull);
    });

    test('AC-BLK-03: nilai blok ke-1 diubah, hasilnya tidak valid pada blok 1', () {
      // Ubah nominal tanpa menyentuh hash tersimpan.
      final changed = Block(
        index: kBlock1.index,
        timestamp: kBlock1.timestamp,
        donorAlias: kBlock1.donorAlias,
        campaign: kBlock1.campaign,
        amount: '900000',
        currency: kBlock1.currency,
        amountIdr: kBlock1.amountIdr,
        rateUsed: kBlock1.rateUsed,
        prevHash: kBlock1.prevHash,
        nonce: kBlock1.nonce,
        hash: kBlock1.hash,
      );
      final r = verifier.verify([kGenesis, changed, kBlock2], userId: kUser);
      expect(r.isValid, isFalse);
      expect(r.firstInvalidIndex, 1);
      expect(r.issue, ChainIssue.hashMismatch);
      expect(r.summary, 'Rantai tidak valid pada blok 1');
    });

    test('FR-BLK-05: melaporkan hash tersimpan dan hasil hitung ulang', () {
      final changed = kBlock2.copyWith(nonce: kBlock2.nonce + 1);
      final r = verifier.verify([kGenesis, kBlock1, changed], userId: kUser);
      expect(r.firstInvalidIndex, 2);
      expect(r.storedHash, kBlock2.hash);
      expect(r.recomputedHash, isNotNull);
      expect(r.recomputedHash, isNot(kBlock2.hash));
    });

    test('prev_hash tidak menyambung ke blok sebelumnya', () {
      final broken = kBlock2.copyWith(prevHash: kZeroHash);
      final r = verifier.verify([kGenesis, kBlock1, broken], userId: kUser);
      expect(r.firstInvalidIndex, 2);
      expect(r.issue, ChainIssue.prevHashMismatch);
      expect(r.expectedPrevHash, kBlock1.hash);
      expect(r.actualPrevHash, kZeroHash);
    });

    test('blok pertama harus berindeks 0 dan prev_hash nol', () {
      final r = verifier.verify([kBlock1, kBlock2], userId: kUser);
      expect(r.isValid, isFalse);
      expect(r.firstInvalidIndex, 1);
      expect(r.issue, ChainIssue.indexGap);
    });

    test('blok yang hilang di tengah terdeteksi sebagai celah indeks', () {
      final r = verifier.verify([kGenesis, kBlock2], userId: kUser);
      expect(r.firstInvalidIndex, 2);
      expect(r.issue, ChainIssue.indexGap);
    });

    test('hash benar tetapi tidak memenuhi proof of work ditolak', () {
      const noPow = Block(
        index: 0,
        timestamp: '2026-10-15T08:00:00Z',
        donorAlias: 'Genesis',
        campaign: 'genesis',
        amount: '0',
        currency: 'IDR',
        amountIdr: '0',
        rateUsed: '1',
        prevHash: kZeroHash,
        nonce: 0,
        hash: '7f01ccc31358bb39a484127002e976e3ee1e7c4d314364ff30f6e147e261f6ed',
      );
      final r = verifier.verify(const [noPow], userId: kUser);
      expect(r.firstInvalidIndex, 0);
      expect(r.issue, ChainIssue.powNotMet);
    });

    test('rantai milik akun lain gagal pada blok 0 karena user_id ikut di-hash', () {
      final r = verifier.verify(
        kChain,
        userId: '99999999-2222-3333-4444-555555555555',
      );
      expect(r.firstInvalidIndex, 0);
      expect(r.issue, ChainIssue.hashMismatch);
    });
  });
}
