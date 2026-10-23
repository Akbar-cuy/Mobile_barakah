// M12 Blockchain Sederhana (FR-BLK)
import '../../../core/constants/app_constants.dart';
import '../../../core/database/daos/ledger_dao.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/utils/formatters.dart';

/// Satu blok pada rantai donasi milik pengguna (PRD bagian 9.12).
///
/// Nilai uang disimpan sebagai teks desimal kanonik, persis seperti yang
/// di-hash, supaya hasil hash identik di perangkat dan di server (AC-BLK-06).
/// [timestamp] juga teks ISO 8601 UTC apa adanya, bukan DateTime.
class Block {
  const Block({
    required this.index,
    required this.timestamp,
    required this.donorAlias,
    required this.campaign,
    required this.amount,
    required this.currency,
    required this.amountIdr,
    required this.rateUsed,
    required this.prevHash,
    required this.nonce,
    required this.hash,
    this.syncState = SyncState.pending,
  });

  factory Block.fromRow(LedgerBlockRow row) {
    return Block(
      index: row.idx,
      timestamp: row.timestamp,
      donorAlias: row.donorAlias,
      campaign: row.campaign,
      amount: row.amount,
      currency: row.currency,
      amountIdr: row.amountIdr,
      rateUsed: row.rateUsed,
      prevHash: row.prevHash,
      nonce: row.nonce,
      hash: row.hash,
      syncState: row.syncState,
    );
  }

  /// Dari JSON server (GET /ledger) atau berkas ekspor. Kunci mengikuti
  /// kolom tabel ledger_blocks di server: idx, ts, donor_alias, dan seterusnya.
  factory Block.fromJson(
    Map<String, dynamic> json, {
    String syncState = SyncState.synced,
  }) {
    String text(String key) => json[key].toString();
    return Block(
      index: (json['idx'] as num).toInt(),
      timestamp: text('ts'),
      donorAlias: text('donor_alias'),
      campaign: text('campaign'),
      amount: text('amount'),
      currency: text('currency'),
      amountIdr: text('amount_idr'),
      rateUsed: text('rate_used'),
      prevHash: text('prev_hash'),
      nonce: (json['nonce'] as num).toInt(),
      hash: text('hash'),
      syncState: syncState,
    );
  }

  final int index;
  final String timestamp;
  final String donorAlias;
  final String campaign;
  final String amount;

  /// IDR, USD, atau SAR.
  final String currency;
  final String amountIdr;
  final String rateUsed;
  final String prevHash;
  final int nonce;
  final String hash;

  /// SyncState.pending, synced, atau failed. Bukan bagian dari hash.
  final String syncState;

  bool get isGenesis => index == AppConstants.ledgerGenesisIndex;

  bool get isSynced => syncState == SyncState.synced;

  /// Delapan karakter awal hash untuk daftar blok (FR-BLK-10).
  String get shortHash => _short(hash);

  String get shortPrevHash => _short(prevHash);

  static String _short(String s) => s.length <= 8 ? s : s.substring(0, 8);

  /// Waktu blok pada zona perangkat. Null bila teks waktu rusak.
  DateTime? get time => DateTime.tryParse(timestamp)?.toLocal();

  /// Nominal asli untuk tampilan, misalnya "Rp100.000" atau "SAR 50,00".
  String get displayAmount => _display(amount, currency);

  String get displayAmountIdr => _display(amountIdr, 'IDR');

  static String _display(String raw, String code) {
    final currency = AppCurrency.tryParse(code);
    final value = double.tryParse(raw);
    if (currency == null || value == null) return '$code $raw';
    return Formatters.currency(value, currency);
  }

  /// Bentuk JSON untuk API dan ekspor. Kunci mengikuti server.
  Map<String, dynamic> toJson() => {
        'idx': index,
        'ts': timestamp,
        'donor_alias': donorAlias,
        'campaign': campaign,
        'amount': amount,
        'currency': currency,
        'amount_idr': amountIdr,
        'rate_used': rateUsed,
        'prev_hash': prevHash,
        'nonce': nonce,
        'hash': hash,
      };

  Block copyWith({
    int? index,
    String? prevHash,
    int? nonce,
    String? hash,
    String? syncState,
  }) {
    return Block(
      index: index ?? this.index,
      timestamp: timestamp,
      donorAlias: donorAlias,
      campaign: campaign,
      amount: amount,
      currency: currency,
      amountIdr: amountIdr,
      rateUsed: rateUsed,
      prevHash: prevHash ?? this.prevHash,
      nonce: nonce ?? this.nonce,
      hash: hash ?? this.hash,
      syncState: syncState ?? this.syncState,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Block &&
      other.index == index &&
      other.hash == hash &&
      other.syncState == syncState;

  @override
  int get hashCode => Object.hash(index, hash, syncState);

  @override
  String toString() => 'Block(#$index, $shortHash, $syncState)';
}
