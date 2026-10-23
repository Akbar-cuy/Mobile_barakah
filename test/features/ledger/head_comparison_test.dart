import 'package:barakah/features/ledger/repository/ledger_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ledger_fixtures.dart';

void main() {
  group('HeadComparison (FR-BLK-08)', () {
    test('head tersinkron sama dengan head server: match, blok pending dihitung', () {
      final r = HeadComparison.compare(
        localBlocks: kChain, // genesis dan blok 1 synced, blok 2 pending
        serverIndex: 1,
        serverHash: kBlock1.hash,
      );
      expect(r.status, HeadStatus.match);
      expect(r.pendingCount, 1);
      expect(r.localIndex, 1);
    });

    test('hash berbeda pada indeks sama: mismatch', () {
      final r = HeadComparison.compare(
        localBlocks: kChain,
        serverIndex: 1,
        serverHash: kZeroHash,
      );
      expect(r.status, HeadStatus.mismatch);
    });

    test('server lebih maju daripada perangkat: serverAhead', () {
      final r = HeadComparison.compare(
        localBlocks: [kGenesis],
        serverIndex: 1,
        serverHash: kBlock1.hash,
      );
      expect(r.status, HeadStatus.serverAhead);
    });

    test('perangkat belum punya blok tersinkron, server punya: serverAhead', () {
      final r = HeadComparison.compare(
        localBlocks: const [],
        serverIndex: 0,
        serverHash: kGenesis.hash,
      );
      expect(r.status, HeadStatus.serverAhead);
    });

    test('server kosong dan perangkat kosong: match', () {
      final r = HeadComparison.compare(localBlocks: const []);
      expect(r.status, HeadStatus.match);
    });

    test('server kosong tetapi perangkat mengaku tersinkron: mismatch', () {
      final r = HeadComparison.compare(localBlocks: [kGenesis]);
      expect(r.status, HeadStatus.mismatch);
    });

    test('perangkat lebih maju daripada server pada blok tersinkron: mismatch', () {
      final r = HeadComparison.compare(
        localBlocks: [kGenesis, kBlock1],
        serverIndex: 0,
        serverHash: kGenesis.hash,
      );
      expect(r.status, HeadStatus.mismatch);
    });
  });
}
