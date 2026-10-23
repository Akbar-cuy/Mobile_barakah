import 'package:barakah/features/ledger/services/block_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ledger_fixtures.dart';

void main() {
  const hasher = BlockHasher();

  group('BlockHasher', () {
    test('merangkai bidang sesuai PRD 9.12 dengan pemisah "|"', () {
      expect(
        hasher.prefixFor(kBlock1, kUser),
        '1|2026-10-15T08:15:00Z|$kUser|Hamba Allah|Air Bersih Pelosok|'
        '100000|IDR|100000|1|${kGenesis.hash}|',
      );
    });

    test('hash sama dengan nilai referensi (SHA-256 independen)', () {
      expect(hasher.compute(kGenesis, kUser), kGenesis.hash);
      expect(hasher.compute(kBlock1, kUser), kBlock1.hash);
      expect(hasher.compute(kBlock2, kUser), kBlock2.hash);
    });

    test('AC-BLK-06: isi sama menghasilkan hash identik di setiap hitungan', () {
      final first = hasher.compute(kBlock1, kUser);
      for (var i = 0; i < 5; i++) {
        expect(hasher.compute(kBlock1, kUser), first);
      }
      expect(first, hasLength(64));
      expect(first, matches(RegExp(r'^[0-9a-f]{64}$')));
    });

    test('nonce 4821 pada blok 1 menghasilkan hash referensi', () {
      expect(
        hasher.compute(kBlock1.copyWith(nonce: 4821), kUser),
        '574cda289321a825d69c83380566e45b23126f2d56fcaf929b6cf8180fcb45db',
      );
    });

    test('mengubah satu bidang apa pun mengubah hash', () {
      final base = hasher.compute(kBlock1, kUser);
      expect(hasher.compute(kBlock1.copyWith(nonce: 5591), kUser), isNot(base));
      expect(hasher.compute(kBlock1.copyWith(index: 9), kUser), isNot(base));
      expect(hasher.compute(kBlock1.copyWith(prevHash: kZeroHash), kUser), isNot(base));
      expect(hasher.compute(kBlock1, '99999999-2222-3333-4444-555555555555'), isNot(base));
    });

    test('sanitize membuang pemisah agar masukan hash tidak ambigu', () {
      expect(BlockHasher.sanitize('Air|Bersih'), 'Air/Bersih');
      expect(BlockHasher.sanitize('  Siti  '), 'Siti');
    });
  });
}
