// M12 Blockchain Sederhana (FR-BLK-04, FR-BLK-05, AC-BLK-02, AC-BLK-03)
import '../../../core/constants/app_constants.dart';
import '../models/block.dart';
import 'block_hasher.dart';
import 'proof_of_work.dart';

/// Jenis kerusakan pertama yang ditemukan pada rantai.
enum ChainIssue {
  /// Indeks tidak berurutan dari 0 (blok hilang, ganda, atau tertukar).
  indexGap,

  /// prev_hash tidak sama dengan hash blok sebelumnya.
  prevHashMismatch,

  /// Hash tersimpan tidak sama dengan hash hasil hitung ulang.
  hashMismatch,

  /// Hash tidak memenuhi syarat proof of work.
  powNotMet,
}

class ChainVerification {
  const ChainVerification({
    required this.blockCount,
    this.firstInvalidIndex,
    this.issue,
    this.storedHash,
    this.recomputedHash,
    this.expectedPrevHash,
    this.actualPrevHash,
  });

  /// Banyak blok yang diperiksa.
  final int blockCount;

  /// Indeks blok pertama yang tidak valid, atau null bila rantai valid.
  final int? firstInvalidIndex;
  final ChainIssue? issue;

  /// Untuk hashMismatch: hash tersimpan dan hasil hitung ulang (FR-BLK-05).
  final String? storedHash;
  final String? recomputedHash;

  /// Untuk prevHashMismatch: nilai yang seharusnya dan yang tertulis.
  final String? expectedPrevHash;
  final String? actualPrevHash;

  bool get isValid => firstInvalidIndex == null;

  /// Teks ringkas untuk lencana dan lembar hasil.
  String get summary => isValid
      ? 'Rantai valid: $blockCount blok'
      : 'Rantai tidak valid pada blok $firstInvalidIndex';

  String get issueDescription {
    switch (issue) {
      case ChainIssue.indexGap:
        return 'Urutan indeks blok tidak berlanjut.';
      case ChainIssue.prevHashMismatch:
        return 'prev_hash tidak sama dengan hash blok sebelumnya.';
      case ChainIssue.hashMismatch:
        return 'Isi blok berubah: hash tersimpan berbeda dengan hasil hitung ulang.';
      case ChainIssue.powNotMet:
        return 'Hash tidak memenuhi syarat proof of work.';
      case null:
        return '';
    }
  }
}

/// Memeriksa seluruh rantai dari blok pertama: urutan indeks, sambungan
/// prev_hash, hash hasil hitung ulang, dan syarat proof of work (FR-BLK-04).
class ChainVerifier {
  const ChainVerifier({
    this.hasher = const BlockHasher(),
    this.pow = const ProofOfWork(),
  });

  final BlockHasher hasher;
  final ProofOfWork pow;

  /// [blocks] harus terurut naik menurut indeks. Rantai kosong dianggap valid.
  ChainVerification verify(List<Block> blocks, {required String userId}) {
    String? previousHash;
    for (var position = 0; position < blocks.length; position++) {
      final block = blocks[position];

      if (block.index != position + AppConstants.ledgerGenesisIndex) {
        return ChainVerification(
          blockCount: blocks.length,
          firstInvalidIndex: block.index,
          issue: ChainIssue.indexGap,
        );
      }

      final expectedPrev =
          previousHash ?? AppConstants.ledgerGenesisPrevHash;
      if (block.prevHash != expectedPrev) {
        return ChainVerification(
          blockCount: blocks.length,
          firstInvalidIndex: block.index,
          issue: ChainIssue.prevHashMismatch,
          expectedPrevHash: expectedPrev,
          actualPrevHash: block.prevHash,
        );
      }

      final recomputed = hasher.compute(block, userId);
      if (recomputed != block.hash) {
        return ChainVerification(
          blockCount: blocks.length,
          firstInvalidIndex: block.index,
          issue: ChainIssue.hashMismatch,
          storedHash: block.hash,
          recomputedHash: recomputed,
        );
      }

      if (!pow.meets(block.hash)) {
        return ChainVerification(
          blockCount: blocks.length,
          firstInvalidIndex: block.index,
          issue: ChainIssue.powNotMet,
          storedHash: block.hash,
        );
      }

      previousHash = block.hash;
    }
    return ChainVerification(blockCount: blocks.length);
  }
}
