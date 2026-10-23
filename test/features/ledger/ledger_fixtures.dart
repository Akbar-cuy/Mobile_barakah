// Data uji bersama untuk modul ledger. Seluruh nilai hash dihitung dengan
// implementasi referensi terpisah (Node, SHA-256) menurut rumus PRD bagian 9.12,
// bukan dengan kode yang diuji.
import 'package:barakah/core/sync/sync_status.dart';
import 'package:barakah/features/ledger/models/block.dart';

const String kUser = '11111111-2222-3333-4444-555555555555';
const String kZeroHash =
    '0000000000000000000000000000000000000000000000000000000000000000';

const Block kGenesis = Block(
  index: 0,
  timestamp: '2026-10-15T08:00:00Z',
  donorAlias: 'Genesis',
  campaign: 'genesis',
  amount: '0',
  currency: 'IDR',
  amountIdr: '0',
  rateUsed: '1',
  prevHash: kZeroHash,
  nonce: 3576,
  hash: '000f87b1644afdbff8ade6c3393cebea2775f582a60b5cd2fc3d7ff20f94b57e',
  syncState: SyncState.synced,
);

const Block kBlock1 = Block(
  index: 1,
  timestamp: '2026-10-15T08:15:00Z',
  donorAlias: 'Hamba Allah',
  campaign: 'Air Bersih Pelosok',
  amount: '100000',
  currency: 'IDR',
  amountIdr: '100000',
  rateUsed: '1',
  prevHash: '000f87b1644afdbff8ade6c3393cebea2775f582a60b5cd2fc3d7ff20f94b57e',
  nonce: 5590,
  hash: '00027ca549f357a69631ab2eee63e76e251966080e8fe7b743ec19ff934dad99',
  syncState: SyncState.synced,
);

const Block kBlock2 = Block(
  index: 2,
  timestamp: '2026-10-16T19:40:00Z',
  donorAlias: 'Siti',
  campaign: 'Beasiswa Santri Yatim',
  amount: '50.00',
  currency: 'SAR',
  amountIdr: '211500.00',
  rateUsed: '4230',
  prevHash: '00027ca549f357a69631ab2eee63e76e251966080e8fe7b743ec19ff934dad99',
  nonce: 6657,
  hash: '000e06cc17836314fb7359b0cd057156045563d7042bd51c51fc0eb0326a8e5e',
  syncState: SyncState.pending,
);

const List<Block> kChain = [kGenesis, kBlock1, kBlock2];
