// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LedgerLocalTableTable extends LedgerLocalTable
    with TableInfo<$LedgerLocalTableTable, LedgerLocalTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerLocalTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idxMeta = const VerificationMeta('idx');
  @override
  late final GeneratedColumn<int> idx = GeneratedColumn<int>(
      'idx', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<String> timestamp = GeneratedColumn<String>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _donorAliasMeta =
      const VerificationMeta('donorAlias');
  @override
  late final GeneratedColumn<String> donorAlias = GeneratedColumn<String>(
      'donor_alias', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _campaignMeta =
      const VerificationMeta('campaign');
  @override
  late final GeneratedColumn<String> campaign = GeneratedColumn<String>(
      'campaign', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
      'amount', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountIdrMeta =
      const VerificationMeta('amountIdr');
  @override
  late final GeneratedColumn<String> amountIdr = GeneratedColumn<String>(
      'amount_idr', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rateUsedMeta =
      const VerificationMeta('rateUsed');
  @override
  late final GeneratedColumn<String> rateUsed = GeneratedColumn<String>(
      'rate_used', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _prevHashMeta =
      const VerificationMeta('prevHash');
  @override
  late final GeneratedColumn<String> prevHash = GeneratedColumn<String>(
      'prev_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nonceMeta = const VerificationMeta('nonce');
  @override
  late final GeneratedColumn<int> nonce = GeneratedColumn<int>(
      'nonce', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
      'hash', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(SyncState.pending));
  @override
  List<GeneratedColumn> get $columns => [
        idx,
        timestamp,
        donorAlias,
        campaign,
        amount,
        currency,
        amountIdr,
        rateUsed,
        prevHash,
        nonce,
        hash,
        syncState
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_local';
  @override
  VerificationContext validateIntegrity(
      Insertable<LedgerLocalTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('idx')) {
      context.handle(
          _idxMeta, idx.isAcceptableOrUnknown(data['idx']!, _idxMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('donor_alias')) {
      context.handle(
          _donorAliasMeta,
          donorAlias.isAcceptableOrUnknown(
              data['donor_alias']!, _donorAliasMeta));
    } else if (isInserting) {
      context.missing(_donorAliasMeta);
    }
    if (data.containsKey('campaign')) {
      context.handle(_campaignMeta,
          campaign.isAcceptableOrUnknown(data['campaign']!, _campaignMeta));
    } else if (isInserting) {
      context.missing(_campaignMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('amount_idr')) {
      context.handle(_amountIdrMeta,
          amountIdr.isAcceptableOrUnknown(data['amount_idr']!, _amountIdrMeta));
    } else if (isInserting) {
      context.missing(_amountIdrMeta);
    }
    if (data.containsKey('rate_used')) {
      context.handle(_rateUsedMeta,
          rateUsed.isAcceptableOrUnknown(data['rate_used']!, _rateUsedMeta));
    } else if (isInserting) {
      context.missing(_rateUsedMeta);
    }
    if (data.containsKey('prev_hash')) {
      context.handle(_prevHashMeta,
          prevHash.isAcceptableOrUnknown(data['prev_hash']!, _prevHashMeta));
    } else if (isInserting) {
      context.missing(_prevHashMeta);
    }
    if (data.containsKey('nonce')) {
      context.handle(
          _nonceMeta, nonce.isAcceptableOrUnknown(data['nonce']!, _nonceMeta));
    } else if (isInserting) {
      context.missing(_nonceMeta);
    }
    if (data.containsKey('hash')) {
      context.handle(
          _hashMeta, hash.isAcceptableOrUnknown(data['hash']!, _hashMeta));
    } else if (isInserting) {
      context.missing(_hashMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idx};
  @override
  LedgerLocalTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerLocalTableData(
      idx: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}idx'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timestamp'])!,
      donorAlias: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}donor_alias'])!,
      campaign: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}campaign'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}amount'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      amountIdr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}amount_idr'])!,
      rateUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rate_used'])!,
      prevHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prev_hash'])!,
      nonce: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}nonce'])!,
      hash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hash'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $LedgerLocalTableTable createAlias(String alias) {
    return $LedgerLocalTableTable(attachedDatabase, alias);
  }
}

class LedgerLocalTableData extends DataClass
    implements Insertable<LedgerLocalTableData> {
  final int idx;
  final String timestamp;
  final String donorAlias;
  final String campaign;
  final String amount;

  /// IDR, USD, atau SAR (lihat AppCurrency.code). Divalidasi di kode.
  final String currency;
  final String amountIdr;
  final String rateUsed;
  final String prevHash;
  final int nonce;
  final String hash;

  /// SyncState.pending, synced, atau failed.
  final String syncState;
  const LedgerLocalTableData(
      {required this.idx,
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
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['idx'] = Variable<int>(idx);
    map['timestamp'] = Variable<String>(timestamp);
    map['donor_alias'] = Variable<String>(donorAlias);
    map['campaign'] = Variable<String>(campaign);
    map['amount'] = Variable<String>(amount);
    map['currency'] = Variable<String>(currency);
    map['amount_idr'] = Variable<String>(amountIdr);
    map['rate_used'] = Variable<String>(rateUsed);
    map['prev_hash'] = Variable<String>(prevHash);
    map['nonce'] = Variable<int>(nonce);
    map['hash'] = Variable<String>(hash);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  LedgerLocalTableCompanion toCompanion(bool nullToAbsent) {
    return LedgerLocalTableCompanion(
      idx: Value(idx),
      timestamp: Value(timestamp),
      donorAlias: Value(donorAlias),
      campaign: Value(campaign),
      amount: Value(amount),
      currency: Value(currency),
      amountIdr: Value(amountIdr),
      rateUsed: Value(rateUsed),
      prevHash: Value(prevHash),
      nonce: Value(nonce),
      hash: Value(hash),
      syncState: Value(syncState),
    );
  }

  factory LedgerLocalTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerLocalTableData(
      idx: serializer.fromJson<int>(json['idx']),
      timestamp: serializer.fromJson<String>(json['timestamp']),
      donorAlias: serializer.fromJson<String>(json['donorAlias']),
      campaign: serializer.fromJson<String>(json['campaign']),
      amount: serializer.fromJson<String>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      amountIdr: serializer.fromJson<String>(json['amountIdr']),
      rateUsed: serializer.fromJson<String>(json['rateUsed']),
      prevHash: serializer.fromJson<String>(json['prevHash']),
      nonce: serializer.fromJson<int>(json['nonce']),
      hash: serializer.fromJson<String>(json['hash']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idx': serializer.toJson<int>(idx),
      'timestamp': serializer.toJson<String>(timestamp),
      'donorAlias': serializer.toJson<String>(donorAlias),
      'campaign': serializer.toJson<String>(campaign),
      'amount': serializer.toJson<String>(amount),
      'currency': serializer.toJson<String>(currency),
      'amountIdr': serializer.toJson<String>(amountIdr),
      'rateUsed': serializer.toJson<String>(rateUsed),
      'prevHash': serializer.toJson<String>(prevHash),
      'nonce': serializer.toJson<int>(nonce),
      'hash': serializer.toJson<String>(hash),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  LedgerLocalTableData copyWith(
          {int? idx,
          String? timestamp,
          String? donorAlias,
          String? campaign,
          String? amount,
          String? currency,
          String? amountIdr,
          String? rateUsed,
          String? prevHash,
          int? nonce,
          String? hash,
          String? syncState}) =>
      LedgerLocalTableData(
        idx: idx ?? this.idx,
        timestamp: timestamp ?? this.timestamp,
        donorAlias: donorAlias ?? this.donorAlias,
        campaign: campaign ?? this.campaign,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        amountIdr: amountIdr ?? this.amountIdr,
        rateUsed: rateUsed ?? this.rateUsed,
        prevHash: prevHash ?? this.prevHash,
        nonce: nonce ?? this.nonce,
        hash: hash ?? this.hash,
        syncState: syncState ?? this.syncState,
      );
  LedgerLocalTableData copyWithCompanion(LedgerLocalTableCompanion data) {
    return LedgerLocalTableData(
      idx: data.idx.present ? data.idx.value : this.idx,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      donorAlias:
          data.donorAlias.present ? data.donorAlias.value : this.donorAlias,
      campaign: data.campaign.present ? data.campaign.value : this.campaign,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      amountIdr: data.amountIdr.present ? data.amountIdr.value : this.amountIdr,
      rateUsed: data.rateUsed.present ? data.rateUsed.value : this.rateUsed,
      prevHash: data.prevHash.present ? data.prevHash.value : this.prevHash,
      nonce: data.nonce.present ? data.nonce.value : this.nonce,
      hash: data.hash.present ? data.hash.value : this.hash,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerLocalTableData(')
          ..write('idx: $idx, ')
          ..write('timestamp: $timestamp, ')
          ..write('donorAlias: $donorAlias, ')
          ..write('campaign: $campaign, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('amountIdr: $amountIdr, ')
          ..write('rateUsed: $rateUsed, ')
          ..write('prevHash: $prevHash, ')
          ..write('nonce: $nonce, ')
          ..write('hash: $hash, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(idx, timestamp, donorAlias, campaign, amount,
      currency, amountIdr, rateUsed, prevHash, nonce, hash, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerLocalTableData &&
          other.idx == this.idx &&
          other.timestamp == this.timestamp &&
          other.donorAlias == this.donorAlias &&
          other.campaign == this.campaign &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.amountIdr == this.amountIdr &&
          other.rateUsed == this.rateUsed &&
          other.prevHash == this.prevHash &&
          other.nonce == this.nonce &&
          other.hash == this.hash &&
          other.syncState == this.syncState);
}

class LedgerLocalTableCompanion extends UpdateCompanion<LedgerLocalTableData> {
  final Value<int> idx;
  final Value<String> timestamp;
  final Value<String> donorAlias;
  final Value<String> campaign;
  final Value<String> amount;
  final Value<String> currency;
  final Value<String> amountIdr;
  final Value<String> rateUsed;
  final Value<String> prevHash;
  final Value<int> nonce;
  final Value<String> hash;
  final Value<String> syncState;
  const LedgerLocalTableCompanion({
    this.idx = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.donorAlias = const Value.absent(),
    this.campaign = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.amountIdr = const Value.absent(),
    this.rateUsed = const Value.absent(),
    this.prevHash = const Value.absent(),
    this.nonce = const Value.absent(),
    this.hash = const Value.absent(),
    this.syncState = const Value.absent(),
  });
  LedgerLocalTableCompanion.insert({
    this.idx = const Value.absent(),
    required String timestamp,
    required String donorAlias,
    required String campaign,
    required String amount,
    required String currency,
    required String amountIdr,
    required String rateUsed,
    required String prevHash,
    required int nonce,
    required String hash,
    this.syncState = const Value.absent(),
  })  : timestamp = Value(timestamp),
        donorAlias = Value(donorAlias),
        campaign = Value(campaign),
        amount = Value(amount),
        currency = Value(currency),
        amountIdr = Value(amountIdr),
        rateUsed = Value(rateUsed),
        prevHash = Value(prevHash),
        nonce = Value(nonce),
        hash = Value(hash);
  static Insertable<LedgerLocalTableData> custom({
    Expression<int>? idx,
    Expression<String>? timestamp,
    Expression<String>? donorAlias,
    Expression<String>? campaign,
    Expression<String>? amount,
    Expression<String>? currency,
    Expression<String>? amountIdr,
    Expression<String>? rateUsed,
    Expression<String>? prevHash,
    Expression<int>? nonce,
    Expression<String>? hash,
    Expression<String>? syncState,
  }) {
    return RawValuesInsertable({
      if (idx != null) 'idx': idx,
      if (timestamp != null) 'timestamp': timestamp,
      if (donorAlias != null) 'donor_alias': donorAlias,
      if (campaign != null) 'campaign': campaign,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (amountIdr != null) 'amount_idr': amountIdr,
      if (rateUsed != null) 'rate_used': rateUsed,
      if (prevHash != null) 'prev_hash': prevHash,
      if (nonce != null) 'nonce': nonce,
      if (hash != null) 'hash': hash,
      if (syncState != null) 'sync_state': syncState,
    });
  }

  LedgerLocalTableCompanion copyWith(
      {Value<int>? idx,
      Value<String>? timestamp,
      Value<String>? donorAlias,
      Value<String>? campaign,
      Value<String>? amount,
      Value<String>? currency,
      Value<String>? amountIdr,
      Value<String>? rateUsed,
      Value<String>? prevHash,
      Value<int>? nonce,
      Value<String>? hash,
      Value<String>? syncState}) {
    return LedgerLocalTableCompanion(
      idx: idx ?? this.idx,
      timestamp: timestamp ?? this.timestamp,
      donorAlias: donorAlias ?? this.donorAlias,
      campaign: campaign ?? this.campaign,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      amountIdr: amountIdr ?? this.amountIdr,
      rateUsed: rateUsed ?? this.rateUsed,
      prevHash: prevHash ?? this.prevHash,
      nonce: nonce ?? this.nonce,
      hash: hash ?? this.hash,
      syncState: syncState ?? this.syncState,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idx.present) {
      map['idx'] = Variable<int>(idx.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<String>(timestamp.value);
    }
    if (donorAlias.present) {
      map['donor_alias'] = Variable<String>(donorAlias.value);
    }
    if (campaign.present) {
      map['campaign'] = Variable<String>(campaign.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (amountIdr.present) {
      map['amount_idr'] = Variable<String>(amountIdr.value);
    }
    if (rateUsed.present) {
      map['rate_used'] = Variable<String>(rateUsed.value);
    }
    if (prevHash.present) {
      map['prev_hash'] = Variable<String>(prevHash.value);
    }
    if (nonce.present) {
      map['nonce'] = Variable<int>(nonce.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerLocalTableCompanion(')
          ..write('idx: $idx, ')
          ..write('timestamp: $timestamp, ')
          ..write('donorAlias: $donorAlias, ')
          ..write('campaign: $campaign, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('amountIdr: $amountIdr, ')
          ..write('rateUsed: $rateUsed, ')
          ..write('prevHash: $prevHash, ')
          ..write('nonce: $nonce, ')
          ..write('hash: $hash, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }
}

class $OutboxTableTable extends OutboxTable
    with TableInfo<$OutboxTableTable, OutboxTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
      'entity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
      'op', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nextAttemptAtMeta =
      const VerificationMeta('nextAttemptAt');
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>('next_attempt_at', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, entity, op, payload, createdAt, attempts, lastError, nextAttemptAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity')) {
      context.handle(_entityMeta,
          entity.isAcceptableOrUnknown(data['entity']!, _entityMeta));
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
          _nextAttemptAtMeta,
          nextAttemptAt.isAcceptableOrUnknown(
              data['next_attempt_at']!, _nextAttemptAtMeta));
    } else if (isInserting) {
      context.missing(_nextAttemptAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity'])!,
      op: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}op'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      nextAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_attempt_at'])!,
    );
  }

  @override
  $OutboxTableTable createAlias(String alias) {
    return $OutboxTableTable(attachedDatabase, alias);
  }
}

class OutboxTableData extends DataClass implements Insertable<OutboxTableData> {
  final int id;

  /// Lihat OutboxEntity.
  final String entity;

  /// Lihat OutboxOp.
  final String op;

  /// Isi perubahan dalam JSON.
  final String payload;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;

  /// Saat paling cepat item boleh dicoba lagi.
  final DateTime nextAttemptAt;
  const OutboxTableData(
      {required this.id,
      required this.entity,
      required this.op,
      required this.payload,
      required this.createdAt,
      required this.attempts,
      this.lastError,
      required this.nextAttemptAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity'] = Variable<String>(entity);
    map['op'] = Variable<String>(op);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    return map;
  }

  OutboxTableCompanion toCompanion(bool nullToAbsent) {
    return OutboxTableCompanion(
      id: Value(id),
      entity: Value(entity),
      op: Value(op),
      payload: Value(payload),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      nextAttemptAt: Value(nextAttemptAt),
    );
  }

  factory OutboxTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxTableData(
      id: serializer.fromJson<int>(json['id']),
      entity: serializer.fromJson<String>(json['entity']),
      op: serializer.fromJson<String>(json['op']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      nextAttemptAt: serializer.fromJson<DateTime>(json['nextAttemptAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entity': serializer.toJson<String>(entity),
      'op': serializer.toJson<String>(op),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
      'nextAttemptAt': serializer.toJson<DateTime>(nextAttemptAt),
    };
  }

  OutboxTableData copyWith(
          {int? id,
          String? entity,
          String? op,
          String? payload,
          DateTime? createdAt,
          int? attempts,
          Value<String?> lastError = const Value.absent(),
          DateTime? nextAttemptAt}) =>
      OutboxTableData(
        id: id ?? this.id,
        entity: entity ?? this.entity,
        op: op ?? this.op,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
        attempts: attempts ?? this.attempts,
        lastError: lastError.present ? lastError.value : this.lastError,
        nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      );
  OutboxTableData copyWithCompanion(OutboxTableCompanion data) {
    return OutboxTableData(
      id: data.id.present ? data.id.value : this.id,
      entity: data.entity.present ? data.entity.value : this.entity,
      op: data.op.present ? data.op.value : this.op,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxTableData(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('op: $op, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('nextAttemptAt: $nextAttemptAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, entity, op, payload, createdAt, attempts, lastError, nextAttemptAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxTableData &&
          other.id == this.id &&
          other.entity == this.entity &&
          other.op == this.op &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError &&
          other.nextAttemptAt == this.nextAttemptAt);
}

class OutboxTableCompanion extends UpdateCompanion<OutboxTableData> {
  final Value<int> id;
  final Value<String> entity;
  final Value<String> op;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<DateTime> nextAttemptAt;
  const OutboxTableCompanion({
    this.id = const Value.absent(),
    this.entity = const Value.absent(),
    this.op = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
  });
  OutboxTableCompanion.insert({
    this.id = const Value.absent(),
    required String entity,
    required String op,
    required String payload,
    required DateTime createdAt,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime nextAttemptAt,
  })  : entity = Value(entity),
        op = Value(op),
        payload = Value(payload),
        createdAt = Value(createdAt),
        nextAttemptAt = Value(nextAttemptAt);
  static Insertable<OutboxTableData> custom({
    Expression<int>? id,
    Expression<String>? entity,
    Expression<String>? op,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<DateTime>? nextAttemptAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entity != null) 'entity': entity,
      if (op != null) 'op': op,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
    });
  }

  OutboxTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? entity,
      Value<String>? op,
      Value<String>? payload,
      Value<DateTime>? createdAt,
      Value<int>? attempts,
      Value<String?>? lastError,
      Value<DateTime>? nextAttemptAt}) {
    return OutboxTableCompanion(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      op: op ?? this.op,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxTableCompanion(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('op: $op, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('nextAttemptAt: $nextAttemptAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _settingKeyMeta =
      const VerificationMeta('settingKey');
  @override
  late final GeneratedColumn<String> settingKey = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _settingValueMeta =
      const VerificationMeta('settingValue');
  @override
  late final GeneratedColumn<String> settingValue = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [settingKey, settingValue, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<SettingsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_settingKeyMeta,
          settingKey.isAcceptableOrUnknown(data['key']!, _settingKeyMeta));
    } else if (isInserting) {
      context.missing(_settingKeyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _settingValueMeta,
          settingValue.isAcceptableOrUnknown(
              data['value']!, _settingValueMeta));
    } else if (isInserting) {
      context.missing(_settingValueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {settingKey};
  @override
  SettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsTableData(
      settingKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      settingValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingsTableData extends DataClass
    implements Insertable<SettingsTableData> {
  final String settingKey;
  final String settingValue;
  final String updatedAt;
  const SettingsTableData(
      {required this.settingKey,
      required this.settingValue,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(settingKey);
    map['value'] = Variable<String>(settingValue);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      settingKey: Value(settingKey),
      settingValue: Value(settingValue),
      updatedAt: Value(updatedAt),
    );
  }

  factory SettingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsTableData(
      settingKey: serializer.fromJson<String>(json['settingKey']),
      settingValue: serializer.fromJson<String>(json['settingValue']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'settingKey': serializer.toJson<String>(settingKey),
      'settingValue': serializer.toJson<String>(settingValue),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  SettingsTableData copyWith(
          {String? settingKey, String? settingValue, String? updatedAt}) =>
      SettingsTableData(
        settingKey: settingKey ?? this.settingKey,
        settingValue: settingValue ?? this.settingValue,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SettingsTableData copyWithCompanion(SettingsTableCompanion data) {
    return SettingsTableData(
      settingKey:
          data.settingKey.present ? data.settingKey.value : this.settingKey,
      settingValue: data.settingValue.present
          ? data.settingValue.value
          : this.settingValue,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableData(')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(settingKey, settingValue, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsTableData &&
          other.settingKey == this.settingKey &&
          other.settingValue == this.settingValue &&
          other.updatedAt == this.updatedAt);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsTableData> {
  final Value<String> settingKey;
  final Value<String> settingValue;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const SettingsTableCompanion({
    this.settingKey = const Value.absent(),
    this.settingValue = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    required String settingKey,
    required String settingValue,
    required String updatedAt,
    this.rowid = const Value.absent(),
  })  : settingKey = Value(settingKey),
        settingValue = Value(settingValue),
        updatedAt = Value(updatedAt);
  static Insertable<SettingsTableData> custom({
    Expression<String>? settingKey,
    Expression<String>? settingValue,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (settingKey != null) 'key': settingKey,
      if (settingValue != null) 'value': settingValue,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsTableCompanion copyWith(
      {Value<String>? settingKey,
      Value<String>? settingValue,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return SettingsTableCompanion(
      settingKey: settingKey ?? this.settingKey,
      settingValue: settingValue ?? this.settingValue,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (settingKey.present) {
      map['key'] = Variable<String>(settingKey.value);
    }
    if (settingValue.present) {
      map['value'] = Variable<String>(settingValue.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrayerCacheTableTable extends PrayerCacheTable
    with TableInfo<$PrayerCacheTableTable, PrayerCacheTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrayerCacheTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationKeyMeta =
      const VerificationMeta('locationKey');
  @override
  late final GeneratedColumn<String> locationKey = GeneratedColumn<String>(
      'location_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
      'lon', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fajrMeta = const VerificationMeta('fajr');
  @override
  late final GeneratedColumn<String> fajr = GeneratedColumn<String>(
      'fajr', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sunriseMeta =
      const VerificationMeta('sunrise');
  @override
  late final GeneratedColumn<String> sunrise = GeneratedColumn<String>(
      'sunrise', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dhuhrMeta = const VerificationMeta('dhuhr');
  @override
  late final GeneratedColumn<String> dhuhr = GeneratedColumn<String>(
      'dhuhr', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _asrMeta = const VerificationMeta('asr');
  @override
  late final GeneratedColumn<String> asr = GeneratedColumn<String>(
      'asr', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _maghribMeta =
      const VerificationMeta('maghrib');
  @override
  late final GeneratedColumn<String> maghrib = GeneratedColumn<String>(
      'maghrib', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ishaMeta = const VerificationMeta('isha');
  @override
  late final GeneratedColumn<String> isha = GeneratedColumn<String>(
      'isha', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _utcOffsetMinutesMeta =
      const VerificationMeta('utcOffsetMinutes');
  @override
  late final GeneratedColumn<int> utcOffsetMinutes = GeneratedColumn<int>(
      'utc_offset_minutes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fetchedAtMeta =
      const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        date,
        locationKey,
        lat,
        lon,
        method,
        fajr,
        sunrise,
        dhuhr,
        asr,
        maghrib,
        isha,
        utcOffsetMinutes,
        fetchedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayer_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<PrayerCacheTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('location_key')) {
      context.handle(
          _locationKeyMeta,
          locationKey.isAcceptableOrUnknown(
              data['location_key']!, _locationKeyMeta));
    } else if (isInserting) {
      context.missing(_locationKeyMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(
          _lonMeta, lon.isAcceptableOrUnknown(data['lon']!, _lonMeta));
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('fajr')) {
      context.handle(
          _fajrMeta, fajr.isAcceptableOrUnknown(data['fajr']!, _fajrMeta));
    } else if (isInserting) {
      context.missing(_fajrMeta);
    }
    if (data.containsKey('sunrise')) {
      context.handle(_sunriseMeta,
          sunrise.isAcceptableOrUnknown(data['sunrise']!, _sunriseMeta));
    } else if (isInserting) {
      context.missing(_sunriseMeta);
    }
    if (data.containsKey('dhuhr')) {
      context.handle(
          _dhuhrMeta, dhuhr.isAcceptableOrUnknown(data['dhuhr']!, _dhuhrMeta));
    } else if (isInserting) {
      context.missing(_dhuhrMeta);
    }
    if (data.containsKey('asr')) {
      context.handle(
          _asrMeta, asr.isAcceptableOrUnknown(data['asr']!, _asrMeta));
    } else if (isInserting) {
      context.missing(_asrMeta);
    }
    if (data.containsKey('maghrib')) {
      context.handle(_maghribMeta,
          maghrib.isAcceptableOrUnknown(data['maghrib']!, _maghribMeta));
    } else if (isInserting) {
      context.missing(_maghribMeta);
    }
    if (data.containsKey('isha')) {
      context.handle(
          _ishaMeta, isha.isAcceptableOrUnknown(data['isha']!, _ishaMeta));
    } else if (isInserting) {
      context.missing(_ishaMeta);
    }
    if (data.containsKey('utc_offset_minutes')) {
      context.handle(
          _utcOffsetMinutesMeta,
          utcOffsetMinutes.isAcceptableOrUnknown(
              data['utc_offset_minutes']!, _utcOffsetMinutesMeta));
    } else if (isInserting) {
      context.missing(_utcOffsetMinutesMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date, locationKey, method};
  @override
  PrayerCacheTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerCacheTableData(
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      locationKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_key'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lon: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lon'])!,
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      fajr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fajr'])!,
      sunrise: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sunrise'])!,
      dhuhr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dhuhr'])!,
      asr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asr'])!,
      maghrib: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}maghrib'])!,
      isha: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}isha'])!,
      utcOffsetMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}utc_offset_minutes'])!,
      fetchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
    );
  }

  @override
  $PrayerCacheTableTable createAlias(String alias) {
    return $PrayerCacheTableTable(attachedDatabase, alias);
  }
}

class PrayerCacheTableData extends DataClass
    implements Insertable<PrayerCacheTableData> {
  final String date;
  final String locationKey;
  final double lat;
  final double lon;
  final String method;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final int utcOffsetMinutes;
  final DateTime fetchedAt;
  const PrayerCacheTableData(
      {required this.date,
      required this.locationKey,
      required this.lat,
      required this.lon,
      required this.method,
      required this.fajr,
      required this.sunrise,
      required this.dhuhr,
      required this.asr,
      required this.maghrib,
      required this.isha,
      required this.utcOffsetMinutes,
      required this.fetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['location_key'] = Variable<String>(locationKey);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    map['method'] = Variable<String>(method);
    map['fajr'] = Variable<String>(fajr);
    map['sunrise'] = Variable<String>(sunrise);
    map['dhuhr'] = Variable<String>(dhuhr);
    map['asr'] = Variable<String>(asr);
    map['maghrib'] = Variable<String>(maghrib);
    map['isha'] = Variable<String>(isha);
    map['utc_offset_minutes'] = Variable<int>(utcOffsetMinutes);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  PrayerCacheTableCompanion toCompanion(bool nullToAbsent) {
    return PrayerCacheTableCompanion(
      date: Value(date),
      locationKey: Value(locationKey),
      lat: Value(lat),
      lon: Value(lon),
      method: Value(method),
      fajr: Value(fajr),
      sunrise: Value(sunrise),
      dhuhr: Value(dhuhr),
      asr: Value(asr),
      maghrib: Value(maghrib),
      isha: Value(isha),
      utcOffsetMinutes: Value(utcOffsetMinutes),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory PrayerCacheTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerCacheTableData(
      date: serializer.fromJson<String>(json['date']),
      locationKey: serializer.fromJson<String>(json['locationKey']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      method: serializer.fromJson<String>(json['method']),
      fajr: serializer.fromJson<String>(json['fajr']),
      sunrise: serializer.fromJson<String>(json['sunrise']),
      dhuhr: serializer.fromJson<String>(json['dhuhr']),
      asr: serializer.fromJson<String>(json['asr']),
      maghrib: serializer.fromJson<String>(json['maghrib']),
      isha: serializer.fromJson<String>(json['isha']),
      utcOffsetMinutes: serializer.fromJson<int>(json['utcOffsetMinutes']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'locationKey': serializer.toJson<String>(locationKey),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'method': serializer.toJson<String>(method),
      'fajr': serializer.toJson<String>(fajr),
      'sunrise': serializer.toJson<String>(sunrise),
      'dhuhr': serializer.toJson<String>(dhuhr),
      'asr': serializer.toJson<String>(asr),
      'maghrib': serializer.toJson<String>(maghrib),
      'isha': serializer.toJson<String>(isha),
      'utcOffsetMinutes': serializer.toJson<int>(utcOffsetMinutes),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  PrayerCacheTableData copyWith(
          {String? date,
          String? locationKey,
          double? lat,
          double? lon,
          String? method,
          String? fajr,
          String? sunrise,
          String? dhuhr,
          String? asr,
          String? maghrib,
          String? isha,
          int? utcOffsetMinutes,
          DateTime? fetchedAt}) =>
      PrayerCacheTableData(
        date: date ?? this.date,
        locationKey: locationKey ?? this.locationKey,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
        method: method ?? this.method,
        fajr: fajr ?? this.fajr,
        sunrise: sunrise ?? this.sunrise,
        dhuhr: dhuhr ?? this.dhuhr,
        asr: asr ?? this.asr,
        maghrib: maghrib ?? this.maghrib,
        isha: isha ?? this.isha,
        utcOffsetMinutes: utcOffsetMinutes ?? this.utcOffsetMinutes,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );
  PrayerCacheTableData copyWithCompanion(PrayerCacheTableCompanion data) {
    return PrayerCacheTableData(
      date: data.date.present ? data.date.value : this.date,
      locationKey:
          data.locationKey.present ? data.locationKey.value : this.locationKey,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      method: data.method.present ? data.method.value : this.method,
      fajr: data.fajr.present ? data.fajr.value : this.fajr,
      sunrise: data.sunrise.present ? data.sunrise.value : this.sunrise,
      dhuhr: data.dhuhr.present ? data.dhuhr.value : this.dhuhr,
      asr: data.asr.present ? data.asr.value : this.asr,
      maghrib: data.maghrib.present ? data.maghrib.value : this.maghrib,
      isha: data.isha.present ? data.isha.value : this.isha,
      utcOffsetMinutes: data.utcOffsetMinutes.present
          ? data.utcOffsetMinutes.value
          : this.utcOffsetMinutes,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerCacheTableData(')
          ..write('date: $date, ')
          ..write('locationKey: $locationKey, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('method: $method, ')
          ..write('fajr: $fajr, ')
          ..write('sunrise: $sunrise, ')
          ..write('dhuhr: $dhuhr, ')
          ..write('asr: $asr, ')
          ..write('maghrib: $maghrib, ')
          ..write('isha: $isha, ')
          ..write('utcOffsetMinutes: $utcOffsetMinutes, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, locationKey, lat, lon, method, fajr,
      sunrise, dhuhr, asr, maghrib, isha, utcOffsetMinutes, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerCacheTableData &&
          other.date == this.date &&
          other.locationKey == this.locationKey &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.method == this.method &&
          other.fajr == this.fajr &&
          other.sunrise == this.sunrise &&
          other.dhuhr == this.dhuhr &&
          other.asr == this.asr &&
          other.maghrib == this.maghrib &&
          other.isha == this.isha &&
          other.utcOffsetMinutes == this.utcOffsetMinutes &&
          other.fetchedAt == this.fetchedAt);
}

class PrayerCacheTableCompanion extends UpdateCompanion<PrayerCacheTableData> {
  final Value<String> date;
  final Value<String> locationKey;
  final Value<double> lat;
  final Value<double> lon;
  final Value<String> method;
  final Value<String> fajr;
  final Value<String> sunrise;
  final Value<String> dhuhr;
  final Value<String> asr;
  final Value<String> maghrib;
  final Value<String> isha;
  final Value<int> utcOffsetMinutes;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const PrayerCacheTableCompanion({
    this.date = const Value.absent(),
    this.locationKey = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.method = const Value.absent(),
    this.fajr = const Value.absent(),
    this.sunrise = const Value.absent(),
    this.dhuhr = const Value.absent(),
    this.asr = const Value.absent(),
    this.maghrib = const Value.absent(),
    this.isha = const Value.absent(),
    this.utcOffsetMinutes = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrayerCacheTableCompanion.insert({
    required String date,
    required String locationKey,
    required double lat,
    required double lon,
    required String method,
    required String fajr,
    required String sunrise,
    required String dhuhr,
    required String asr,
    required String maghrib,
    required String isha,
    required int utcOffsetMinutes,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  })  : date = Value(date),
        locationKey = Value(locationKey),
        lat = Value(lat),
        lon = Value(lon),
        method = Value(method),
        fajr = Value(fajr),
        sunrise = Value(sunrise),
        dhuhr = Value(dhuhr),
        asr = Value(asr),
        maghrib = Value(maghrib),
        isha = Value(isha),
        utcOffsetMinutes = Value(utcOffsetMinutes),
        fetchedAt = Value(fetchedAt);
  static Insertable<PrayerCacheTableData> custom({
    Expression<String>? date,
    Expression<String>? locationKey,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<String>? method,
    Expression<String>? fajr,
    Expression<String>? sunrise,
    Expression<String>? dhuhr,
    Expression<String>? asr,
    Expression<String>? maghrib,
    Expression<String>? isha,
    Expression<int>? utcOffsetMinutes,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (locationKey != null) 'location_key': locationKey,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (method != null) 'method': method,
      if (fajr != null) 'fajr': fajr,
      if (sunrise != null) 'sunrise': sunrise,
      if (dhuhr != null) 'dhuhr': dhuhr,
      if (asr != null) 'asr': asr,
      if (maghrib != null) 'maghrib': maghrib,
      if (isha != null) 'isha': isha,
      if (utcOffsetMinutes != null) 'utc_offset_minutes': utcOffsetMinutes,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrayerCacheTableCompanion copyWith(
      {Value<String>? date,
      Value<String>? locationKey,
      Value<double>? lat,
      Value<double>? lon,
      Value<String>? method,
      Value<String>? fajr,
      Value<String>? sunrise,
      Value<String>? dhuhr,
      Value<String>? asr,
      Value<String>? maghrib,
      Value<String>? isha,
      Value<int>? utcOffsetMinutes,
      Value<DateTime>? fetchedAt,
      Value<int>? rowid}) {
    return PrayerCacheTableCompanion(
      date: date ?? this.date,
      locationKey: locationKey ?? this.locationKey,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      method: method ?? this.method,
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      utcOffsetMinutes: utcOffsetMinutes ?? this.utcOffsetMinutes,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (locationKey.present) {
      map['location_key'] = Variable<String>(locationKey.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (fajr.present) {
      map['fajr'] = Variable<String>(fajr.value);
    }
    if (sunrise.present) {
      map['sunrise'] = Variable<String>(sunrise.value);
    }
    if (dhuhr.present) {
      map['dhuhr'] = Variable<String>(dhuhr.value);
    }
    if (asr.present) {
      map['asr'] = Variable<String>(asr.value);
    }
    if (maghrib.present) {
      map['maghrib'] = Variable<String>(maghrib.value);
    }
    if (isha.present) {
      map['isha'] = Variable<String>(isha.value);
    }
    if (utcOffsetMinutes.present) {
      map['utc_offset_minutes'] = Variable<int>(utcOffsetMinutes.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayerCacheTableCompanion(')
          ..write('date: $date, ')
          ..write('locationKey: $locationKey, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('method: $method, ')
          ..write('fajr: $fajr, ')
          ..write('sunrise: $sunrise, ')
          ..write('dhuhr: $dhuhr, ')
          ..write('asr: $asr, ')
          ..write('maghrib: $maghrib, ')
          ..write('isha: $isha, ')
          ..write('utcOffsetMinutes: $utcOffsetMinutes, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RateCacheTableTable extends RateCacheTable
    with TableInfo<$RateCacheTableTable, RateCacheTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RateCacheTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _baseMeta = const VerificationMeta('base');
  @override
  late final GeneratedColumn<String> base = GeneratedColumn<String>(
      'base', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quoteMeta = const VerificationMeta('quote');
  @override
  late final GeneratedColumn<String> quote = GeneratedColumn<String>(
      'quote', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
      'rate', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _fetchedAtMeta =
      const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [base, quote, rate, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rate_cache';
  @override
  VerificationContext validateIntegrity(Insertable<RateCacheTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('base')) {
      context.handle(
          _baseMeta, base.isAcceptableOrUnknown(data['base']!, _baseMeta));
    } else if (isInserting) {
      context.missing(_baseMeta);
    }
    if (data.containsKey('quote')) {
      context.handle(
          _quoteMeta, quote.isAcceptableOrUnknown(data['quote']!, _quoteMeta));
    } else if (isInserting) {
      context.missing(_quoteMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
          _rateMeta, rate.isAcceptableOrUnknown(data['rate']!, _rateMeta));
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {base, quote};
  @override
  RateCacheTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RateCacheTableData(
      base: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}base'])!,
      quote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quote'])!,
      rate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rate'])!,
      fetchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
    );
  }

  @override
  $RateCacheTableTable createAlias(String alias) {
    return $RateCacheTableTable(attachedDatabase, alias);
  }
}

class RateCacheTableData extends DataClass
    implements Insertable<RateCacheTableData> {
  final String base;
  final String quote;
  final double rate;
  final DateTime fetchedAt;
  const RateCacheTableData(
      {required this.base,
      required this.quote,
      required this.rate,
      required this.fetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['base'] = Variable<String>(base);
    map['quote'] = Variable<String>(quote);
    map['rate'] = Variable<double>(rate);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  RateCacheTableCompanion toCompanion(bool nullToAbsent) {
    return RateCacheTableCompanion(
      base: Value(base),
      quote: Value(quote),
      rate: Value(rate),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory RateCacheTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RateCacheTableData(
      base: serializer.fromJson<String>(json['base']),
      quote: serializer.fromJson<String>(json['quote']),
      rate: serializer.fromJson<double>(json['rate']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'base': serializer.toJson<String>(base),
      'quote': serializer.toJson<String>(quote),
      'rate': serializer.toJson<double>(rate),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  RateCacheTableData copyWith(
          {String? base, String? quote, double? rate, DateTime? fetchedAt}) =>
      RateCacheTableData(
        base: base ?? this.base,
        quote: quote ?? this.quote,
        rate: rate ?? this.rate,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );
  RateCacheTableData copyWithCompanion(RateCacheTableCompanion data) {
    return RateCacheTableData(
      base: data.base.present ? data.base.value : this.base,
      quote: data.quote.present ? data.quote.value : this.quote,
      rate: data.rate.present ? data.rate.value : this.rate,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RateCacheTableData(')
          ..write('base: $base, ')
          ..write('quote: $quote, ')
          ..write('rate: $rate, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(base, quote, rate, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RateCacheTableData &&
          other.base == this.base &&
          other.quote == this.quote &&
          other.rate == this.rate &&
          other.fetchedAt == this.fetchedAt);
}

class RateCacheTableCompanion extends UpdateCompanion<RateCacheTableData> {
  final Value<String> base;
  final Value<String> quote;
  final Value<double> rate;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const RateCacheTableCompanion({
    this.base = const Value.absent(),
    this.quote = const Value.absent(),
    this.rate = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RateCacheTableCompanion.insert({
    required String base,
    required String quote,
    required double rate,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  })  : base = Value(base),
        quote = Value(quote),
        rate = Value(rate),
        fetchedAt = Value(fetchedAt);
  static Insertable<RateCacheTableData> custom({
    Expression<String>? base,
    Expression<String>? quote,
    Expression<double>? rate,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (base != null) 'base': base,
      if (quote != null) 'quote': quote,
      if (rate != null) 'rate': rate,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RateCacheTableCompanion copyWith(
      {Value<String>? base,
      Value<String>? quote,
      Value<double>? rate,
      Value<DateTime>? fetchedAt,
      Value<int>? rowid}) {
    return RateCacheTableCompanion(
      base: base ?? this.base,
      quote: quote ?? this.quote,
      rate: rate ?? this.rate,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (base.present) {
      map['base'] = Variable<String>(base.value);
    }
    if (quote.present) {
      map['quote'] = Variable<String>(quote.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RateCacheTableCompanion(')
          ..write('base: $base, ')
          ..write('quote: $quote, ')
          ..write('rate: $rate, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DonationLocalTableTable extends DonationLocalTable
    with TableInfo<$DonationLocalTableTable, DonationLocalTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DonationLocalTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _campaignMeta =
      const VerificationMeta('campaign');
  @override
  late final GeneratedColumn<String> campaign = GeneratedColumn<String>(
      'campaign', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
      'amount', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountIdrMeta =
      const VerificationMeta('amountIdr');
  @override
  late final GeneratedColumn<String> amountIdr = GeneratedColumn<String>(
      'amount_idr', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rateUsedMeta =
      const VerificationMeta('rateUsed');
  @override
  late final GeneratedColumn<String> rateUsed = GeneratedColumn<String>(
      'rate_used', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(SyncState.pending));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        campaign,
        amount,
        currency,
        amountIdr,
        rateUsed,
        createdAt,
        syncState
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'donation_local';
  @override
  VerificationContext validateIntegrity(
      Insertable<DonationLocalTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('campaign')) {
      context.handle(_campaignMeta,
          campaign.isAcceptableOrUnknown(data['campaign']!, _campaignMeta));
    } else if (isInserting) {
      context.missing(_campaignMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('amount_idr')) {
      context.handle(_amountIdrMeta,
          amountIdr.isAcceptableOrUnknown(data['amount_idr']!, _amountIdrMeta));
    } else if (isInserting) {
      context.missing(_amountIdrMeta);
    }
    if (data.containsKey('rate_used')) {
      context.handle(_rateUsedMeta,
          rateUsed.isAcceptableOrUnknown(data['rate_used']!, _rateUsedMeta));
    } else if (isInserting) {
      context.missing(_rateUsedMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DonationLocalTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DonationLocalTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      campaign: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}campaign'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}amount'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      amountIdr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}amount_idr'])!,
      rateUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rate_used'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $DonationLocalTableTable createAlias(String alias) {
    return $DonationLocalTableTable(attachedDatabase, alias);
  }
}

class DonationLocalTableData extends DataClass
    implements Insertable<DonationLocalTableData> {
  final String id;
  final String campaign;
  final String amount;
  final String currency;
  final String amountIdr;
  final String rateUsed;
  final String createdAt;
  final String syncState;
  const DonationLocalTableData(
      {required this.id,
      required this.campaign,
      required this.amount,
      required this.currency,
      required this.amountIdr,
      required this.rateUsed,
      required this.createdAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['campaign'] = Variable<String>(campaign);
    map['amount'] = Variable<String>(amount);
    map['currency'] = Variable<String>(currency);
    map['amount_idr'] = Variable<String>(amountIdr);
    map['rate_used'] = Variable<String>(rateUsed);
    map['created_at'] = Variable<String>(createdAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  DonationLocalTableCompanion toCompanion(bool nullToAbsent) {
    return DonationLocalTableCompanion(
      id: Value(id),
      campaign: Value(campaign),
      amount: Value(amount),
      currency: Value(currency),
      amountIdr: Value(amountIdr),
      rateUsed: Value(rateUsed),
      createdAt: Value(createdAt),
      syncState: Value(syncState),
    );
  }

  factory DonationLocalTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DonationLocalTableData(
      id: serializer.fromJson<String>(json['id']),
      campaign: serializer.fromJson<String>(json['campaign']),
      amount: serializer.fromJson<String>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      amountIdr: serializer.fromJson<String>(json['amountIdr']),
      rateUsed: serializer.fromJson<String>(json['rateUsed']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'campaign': serializer.toJson<String>(campaign),
      'amount': serializer.toJson<String>(amount),
      'currency': serializer.toJson<String>(currency),
      'amountIdr': serializer.toJson<String>(amountIdr),
      'rateUsed': serializer.toJson<String>(rateUsed),
      'createdAt': serializer.toJson<String>(createdAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  DonationLocalTableData copyWith(
          {String? id,
          String? campaign,
          String? amount,
          String? currency,
          String? amountIdr,
          String? rateUsed,
          String? createdAt,
          String? syncState}) =>
      DonationLocalTableData(
        id: id ?? this.id,
        campaign: campaign ?? this.campaign,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        amountIdr: amountIdr ?? this.amountIdr,
        rateUsed: rateUsed ?? this.rateUsed,
        createdAt: createdAt ?? this.createdAt,
        syncState: syncState ?? this.syncState,
      );
  DonationLocalTableData copyWithCompanion(DonationLocalTableCompanion data) {
    return DonationLocalTableData(
      id: data.id.present ? data.id.value : this.id,
      campaign: data.campaign.present ? data.campaign.value : this.campaign,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      amountIdr: data.amountIdr.present ? data.amountIdr.value : this.amountIdr,
      rateUsed: data.rateUsed.present ? data.rateUsed.value : this.rateUsed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DonationLocalTableData(')
          ..write('id: $id, ')
          ..write('campaign: $campaign, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('amountIdr: $amountIdr, ')
          ..write('rateUsed: $rateUsed, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, campaign, amount, currency, amountIdr,
      rateUsed, createdAt, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DonationLocalTableData &&
          other.id == this.id &&
          other.campaign == this.campaign &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.amountIdr == this.amountIdr &&
          other.rateUsed == this.rateUsed &&
          other.createdAt == this.createdAt &&
          other.syncState == this.syncState);
}

class DonationLocalTableCompanion
    extends UpdateCompanion<DonationLocalTableData> {
  final Value<String> id;
  final Value<String> campaign;
  final Value<String> amount;
  final Value<String> currency;
  final Value<String> amountIdr;
  final Value<String> rateUsed;
  final Value<String> createdAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const DonationLocalTableCompanion({
    this.id = const Value.absent(),
    this.campaign = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.amountIdr = const Value.absent(),
    this.rateUsed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DonationLocalTableCompanion.insert({
    required String id,
    required String campaign,
    required String amount,
    required String currency,
    required String amountIdr,
    required String rateUsed,
    required String createdAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        campaign = Value(campaign),
        amount = Value(amount),
        currency = Value(currency),
        amountIdr = Value(amountIdr),
        rateUsed = Value(rateUsed),
        createdAt = Value(createdAt);
  static Insertable<DonationLocalTableData> custom({
    Expression<String>? id,
    Expression<String>? campaign,
    Expression<String>? amount,
    Expression<String>? currency,
    Expression<String>? amountIdr,
    Expression<String>? rateUsed,
    Expression<String>? createdAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (campaign != null) 'campaign': campaign,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (amountIdr != null) 'amount_idr': amountIdr,
      if (rateUsed != null) 'rate_used': rateUsed,
      if (createdAt != null) 'created_at': createdAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DonationLocalTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? campaign,
      Value<String>? amount,
      Value<String>? currency,
      Value<String>? amountIdr,
      Value<String>? rateUsed,
      Value<String>? createdAt,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return DonationLocalTableCompanion(
      id: id ?? this.id,
      campaign: campaign ?? this.campaign,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      amountIdr: amountIdr ?? this.amountIdr,
      rateUsed: rateUsed ?? this.rateUsed,
      createdAt: createdAt ?? this.createdAt,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (campaign.present) {
      map['campaign'] = Variable<String>(campaign.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (amountIdr.present) {
      map['amount_idr'] = Variable<String>(amountIdr.value);
    }
    if (rateUsed.present) {
      map['rate_used'] = Variable<String>(rateUsed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DonationLocalTableCompanion(')
          ..write('id: $id, ')
          ..write('campaign: $campaign, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('amountIdr: $amountIdr, ')
          ..write('rateUsed: $rateUsed, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasbihLogTableTable extends TasbihLogTable
    with TableInfo<$TasbihLogTableTable, TasbihLogTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasbihLogTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<int> target = GeneratedColumn<int>(
      'target', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
      'count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(SyncState.pending));
  @override
  List<GeneratedColumn> get $columns => [id, date, target, count, syncState];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasbih_log';
  @override
  VerificationContext validateIntegrity(Insertable<TasbihLogTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('target')) {
      context.handle(_targetMeta,
          target.isAcceptableOrUnknown(data['target']!, _targetMeta));
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
          _countMeta, count.isAcceptableOrUnknown(data['count']!, _countMeta));
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TasbihLogTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TasbihLogTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      target: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target'])!,
      count: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}count'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $TasbihLogTableTable createAlias(String alias) {
    return $TasbihLogTableTable(attachedDatabase, alias);
  }
}

class TasbihLogTableData extends DataClass
    implements Insertable<TasbihLogTableData> {
  final String id;
  final String date;
  final int target;
  final int count;
  final String syncState;
  const TasbihLogTableData(
      {required this.id,
      required this.date,
      required this.target,
      required this.count,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<String>(date);
    map['target'] = Variable<int>(target);
    map['count'] = Variable<int>(count);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  TasbihLogTableCompanion toCompanion(bool nullToAbsent) {
    return TasbihLogTableCompanion(
      id: Value(id),
      date: Value(date),
      target: Value(target),
      count: Value(count),
      syncState: Value(syncState),
    );
  }

  factory TasbihLogTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TasbihLogTableData(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      target: serializer.fromJson<int>(json['target']),
      count: serializer.fromJson<int>(json['count']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<String>(date),
      'target': serializer.toJson<int>(target),
      'count': serializer.toJson<int>(count),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  TasbihLogTableData copyWith(
          {String? id,
          String? date,
          int? target,
          int? count,
          String? syncState}) =>
      TasbihLogTableData(
        id: id ?? this.id,
        date: date ?? this.date,
        target: target ?? this.target,
        count: count ?? this.count,
        syncState: syncState ?? this.syncState,
      );
  TasbihLogTableData copyWithCompanion(TasbihLogTableCompanion data) {
    return TasbihLogTableData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      target: data.target.present ? data.target.value : this.target,
      count: data.count.present ? data.count.value : this.count,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TasbihLogTableData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('target: $target, ')
          ..write('count: $count, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, target, count, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TasbihLogTableData &&
          other.id == this.id &&
          other.date == this.date &&
          other.target == this.target &&
          other.count == this.count &&
          other.syncState == this.syncState);
}

class TasbihLogTableCompanion extends UpdateCompanion<TasbihLogTableData> {
  final Value<String> id;
  final Value<String> date;
  final Value<int> target;
  final Value<int> count;
  final Value<String> syncState;
  final Value<int> rowid;
  const TasbihLogTableCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.target = const Value.absent(),
    this.count = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasbihLogTableCompanion.insert({
    required String id,
    required String date,
    required int target,
    required int count,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date),
        target = Value(target),
        count = Value(count);
  static Insertable<TasbihLogTableData> custom({
    Expression<String>? id,
    Expression<String>? date,
    Expression<int>? target,
    Expression<int>? count,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (target != null) 'target': target,
      if (count != null) 'count': count,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasbihLogTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? date,
      Value<int>? target,
      Value<int>? count,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return TasbihLogTableCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      target: target ?? this.target,
      count: count ?? this.count,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (target.present) {
      map['target'] = Variable<int>(target.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasbihLogTableCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('target: $target, ')
          ..write('count: $count, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuizAttemptTableTable extends QuizAttemptTable
    with TableInfo<$QuizAttemptTableTable, QuizAttemptTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizAttemptTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
      'score', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _correctMeta =
      const VerificationMeta('correct');
  @override
  late final GeneratedColumn<int> correct = GeneratedColumn<int>(
      'correct', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
      'total', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _avgTimeSecondsMeta =
      const VerificationMeta('avgTimeSeconds');
  @override
  late final GeneratedColumn<double> avgTimeSeconds = GeneratedColumn<double>(
      'avg_time_seconds', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(SyncState.pending));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        category,
        score,
        correct,
        total,
        avgTimeSeconds,
        createdAt,
        syncState
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_attempt';
  @override
  VerificationContext validateIntegrity(
      Insertable<QuizAttemptTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('correct')) {
      context.handle(_correctMeta,
          correct.isAcceptableOrUnknown(data['correct']!, _correctMeta));
    } else if (isInserting) {
      context.missing(_correctMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('avg_time_seconds')) {
      context.handle(
          _avgTimeSecondsMeta,
          avgTimeSeconds.isAcceptableOrUnknown(
              data['avg_time_seconds']!, _avgTimeSecondsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuizAttemptTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizAttemptTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}score'])!,
      correct: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}correct'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total'])!,
      avgTimeSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}avg_time_seconds']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $QuizAttemptTableTable createAlias(String alias) {
    return $QuizAttemptTableTable(attachedDatabase, alias);
  }
}

class QuizAttemptTableData extends DataClass
    implements Insertable<QuizAttemptTableData> {
  final String id;
  final String category;
  final int score;
  final int correct;
  final int total;
  final double? avgTimeSeconds;
  final String createdAt;
  final String syncState;
  const QuizAttemptTableData(
      {required this.id,
      required this.category,
      required this.score,
      required this.correct,
      required this.total,
      this.avgTimeSeconds,
      required this.createdAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category'] = Variable<String>(category);
    map['score'] = Variable<int>(score);
    map['correct'] = Variable<int>(correct);
    map['total'] = Variable<int>(total);
    if (!nullToAbsent || avgTimeSeconds != null) {
      map['avg_time_seconds'] = Variable<double>(avgTimeSeconds);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  QuizAttemptTableCompanion toCompanion(bool nullToAbsent) {
    return QuizAttemptTableCompanion(
      id: Value(id),
      category: Value(category),
      score: Value(score),
      correct: Value(correct),
      total: Value(total),
      avgTimeSeconds: avgTimeSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(avgTimeSeconds),
      createdAt: Value(createdAt),
      syncState: Value(syncState),
    );
  }

  factory QuizAttemptTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizAttemptTableData(
      id: serializer.fromJson<String>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      score: serializer.fromJson<int>(json['score']),
      correct: serializer.fromJson<int>(json['correct']),
      total: serializer.fromJson<int>(json['total']),
      avgTimeSeconds: serializer.fromJson<double?>(json['avgTimeSeconds']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'category': serializer.toJson<String>(category),
      'score': serializer.toJson<int>(score),
      'correct': serializer.toJson<int>(correct),
      'total': serializer.toJson<int>(total),
      'avgTimeSeconds': serializer.toJson<double?>(avgTimeSeconds),
      'createdAt': serializer.toJson<String>(createdAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  QuizAttemptTableData copyWith(
          {String? id,
          String? category,
          int? score,
          int? correct,
          int? total,
          Value<double?> avgTimeSeconds = const Value.absent(),
          String? createdAt,
          String? syncState}) =>
      QuizAttemptTableData(
        id: id ?? this.id,
        category: category ?? this.category,
        score: score ?? this.score,
        correct: correct ?? this.correct,
        total: total ?? this.total,
        avgTimeSeconds:
            avgTimeSeconds.present ? avgTimeSeconds.value : this.avgTimeSeconds,
        createdAt: createdAt ?? this.createdAt,
        syncState: syncState ?? this.syncState,
      );
  QuizAttemptTableData copyWithCompanion(QuizAttemptTableCompanion data) {
    return QuizAttemptTableData(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      score: data.score.present ? data.score.value : this.score,
      correct: data.correct.present ? data.correct.value : this.correct,
      total: data.total.present ? data.total.value : this.total,
      avgTimeSeconds: data.avgTimeSeconds.present
          ? data.avgTimeSeconds.value
          : this.avgTimeSeconds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizAttemptTableData(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('score: $score, ')
          ..write('correct: $correct, ')
          ..write('total: $total, ')
          ..write('avgTimeSeconds: $avgTimeSeconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, category, score, correct, total,
      avgTimeSeconds, createdAt, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizAttemptTableData &&
          other.id == this.id &&
          other.category == this.category &&
          other.score == this.score &&
          other.correct == this.correct &&
          other.total == this.total &&
          other.avgTimeSeconds == this.avgTimeSeconds &&
          other.createdAt == this.createdAt &&
          other.syncState == this.syncState);
}

class QuizAttemptTableCompanion extends UpdateCompanion<QuizAttemptTableData> {
  final Value<String> id;
  final Value<String> category;
  final Value<int> score;
  final Value<int> correct;
  final Value<int> total;
  final Value<double?> avgTimeSeconds;
  final Value<String> createdAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const QuizAttemptTableCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.score = const Value.absent(),
    this.correct = const Value.absent(),
    this.total = const Value.absent(),
    this.avgTimeSeconds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuizAttemptTableCompanion.insert({
    required String id,
    required String category,
    required int score,
    required int correct,
    required int total,
    this.avgTimeSeconds = const Value.absent(),
    required String createdAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        category = Value(category),
        score = Value(score),
        correct = Value(correct),
        total = Value(total),
        createdAt = Value(createdAt);
  static Insertable<QuizAttemptTableData> custom({
    Expression<String>? id,
    Expression<String>? category,
    Expression<int>? score,
    Expression<int>? correct,
    Expression<int>? total,
    Expression<double>? avgTimeSeconds,
    Expression<String>? createdAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (score != null) 'score': score,
      if (correct != null) 'correct': correct,
      if (total != null) 'total': total,
      if (avgTimeSeconds != null) 'avg_time_seconds': avgTimeSeconds,
      if (createdAt != null) 'created_at': createdAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuizAttemptTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? category,
      Value<int>? score,
      Value<int>? correct,
      Value<int>? total,
      Value<double?>? avgTimeSeconds,
      Value<String>? createdAt,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return QuizAttemptTableCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      score: score ?? this.score,
      correct: correct ?? this.correct,
      total: total ?? this.total,
      avgTimeSeconds: avgTimeSeconds ?? this.avgTimeSeconds,
      createdAt: createdAt ?? this.createdAt,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (correct.present) {
      map['correct'] = Variable<int>(correct.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (avgTimeSeconds.present) {
      map['avg_time_seconds'] = Variable<double>(avgTimeSeconds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizAttemptTableCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('score: $score, ')
          ..write('correct: $correct, ')
          ..write('total: $total, ')
          ..write('avgTimeSeconds: $avgTimeSeconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuizQuestionTableTable extends QuizQuestionTable
    with TableInfo<$QuizQuestionTableTable, QuizQuestionTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizQuestionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _questionMeta =
      const VerificationMeta('question');
  @override
  late final GeneratedColumn<String> question = GeneratedColumn<String>(
      'question', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _optionsMeta =
      const VerificationMeta('options');
  @override
  late final GeneratedColumn<String> options = GeneratedColumn<String>(
      'options', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _answerIndexMeta =
      const VerificationMeta('answerIndex');
  @override
  late final GeneratedColumn<int> answerIndex = GeneratedColumn<int>(
      'answer_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _explanationMeta =
      const VerificationMeta('explanation');
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
      'explanation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        category,
        difficulty,
        question,
        options,
        answerIndex,
        explanation,
        version
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_question';
  @override
  VerificationContext validateIntegrity(
      Insertable<QuizQuestionTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('question')) {
      context.handle(_questionMeta,
          question.isAcceptableOrUnknown(data['question']!, _questionMeta));
    } else if (isInserting) {
      context.missing(_questionMeta);
    }
    if (data.containsKey('options')) {
      context.handle(_optionsMeta,
          options.isAcceptableOrUnknown(data['options']!, _optionsMeta));
    } else if (isInserting) {
      context.missing(_optionsMeta);
    }
    if (data.containsKey('answer_index')) {
      context.handle(
          _answerIndexMeta,
          answerIndex.isAcceptableOrUnknown(
              data['answer_index']!, _answerIndexMeta));
    } else if (isInserting) {
      context.missing(_answerIndexMeta);
    }
    if (data.containsKey('explanation')) {
      context.handle(
          _explanationMeta,
          explanation.isAcceptableOrUnknown(
              data['explanation']!, _explanationMeta));
    } else if (isInserting) {
      context.missing(_explanationMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuizQuestionTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizQuestionTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}difficulty'])!,
      question: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question'])!,
      options: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}options'])!,
      answerIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}answer_index'])!,
      explanation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}explanation'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
    );
  }

  @override
  $QuizQuestionTableTable createAlias(String alias) {
    return $QuizQuestionTableTable(attachedDatabase, alias);
  }
}

class QuizQuestionTableData extends DataClass
    implements Insertable<QuizQuestionTableData> {
  final String id;
  final String category;
  final int difficulty;
  final String question;
  final String options;
  final int answerIndex;
  final String explanation;
  final int version;
  const QuizQuestionTableData(
      {required this.id,
      required this.category,
      required this.difficulty,
      required this.question,
      required this.options,
      required this.answerIndex,
      required this.explanation,
      required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category'] = Variable<String>(category);
    map['difficulty'] = Variable<int>(difficulty);
    map['question'] = Variable<String>(question);
    map['options'] = Variable<String>(options);
    map['answer_index'] = Variable<int>(answerIndex);
    map['explanation'] = Variable<String>(explanation);
    map['version'] = Variable<int>(version);
    return map;
  }

  QuizQuestionTableCompanion toCompanion(bool nullToAbsent) {
    return QuizQuestionTableCompanion(
      id: Value(id),
      category: Value(category),
      difficulty: Value(difficulty),
      question: Value(question),
      options: Value(options),
      answerIndex: Value(answerIndex),
      explanation: Value(explanation),
      version: Value(version),
    );
  }

  factory QuizQuestionTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizQuestionTableData(
      id: serializer.fromJson<String>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      question: serializer.fromJson<String>(json['question']),
      options: serializer.fromJson<String>(json['options']),
      answerIndex: serializer.fromJson<int>(json['answerIndex']),
      explanation: serializer.fromJson<String>(json['explanation']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'category': serializer.toJson<String>(category),
      'difficulty': serializer.toJson<int>(difficulty),
      'question': serializer.toJson<String>(question),
      'options': serializer.toJson<String>(options),
      'answerIndex': serializer.toJson<int>(answerIndex),
      'explanation': serializer.toJson<String>(explanation),
      'version': serializer.toJson<int>(version),
    };
  }

  QuizQuestionTableData copyWith(
          {String? id,
          String? category,
          int? difficulty,
          String? question,
          String? options,
          int? answerIndex,
          String? explanation,
          int? version}) =>
      QuizQuestionTableData(
        id: id ?? this.id,
        category: category ?? this.category,
        difficulty: difficulty ?? this.difficulty,
        question: question ?? this.question,
        options: options ?? this.options,
        answerIndex: answerIndex ?? this.answerIndex,
        explanation: explanation ?? this.explanation,
        version: version ?? this.version,
      );
  QuizQuestionTableData copyWithCompanion(QuizQuestionTableCompanion data) {
    return QuizQuestionTableData(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      question: data.question.present ? data.question.value : this.question,
      options: data.options.present ? data.options.value : this.options,
      answerIndex:
          data.answerIndex.present ? data.answerIndex.value : this.answerIndex,
      explanation:
          data.explanation.present ? data.explanation.value : this.explanation,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizQuestionTableData(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty, ')
          ..write('question: $question, ')
          ..write('options: $options, ')
          ..write('answerIndex: $answerIndex, ')
          ..write('explanation: $explanation, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, category, difficulty, question, options,
      answerIndex, explanation, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizQuestionTableData &&
          other.id == this.id &&
          other.category == this.category &&
          other.difficulty == this.difficulty &&
          other.question == this.question &&
          other.options == this.options &&
          other.answerIndex == this.answerIndex &&
          other.explanation == this.explanation &&
          other.version == this.version);
}

class QuizQuestionTableCompanion
    extends UpdateCompanion<QuizQuestionTableData> {
  final Value<String> id;
  final Value<String> category;
  final Value<int> difficulty;
  final Value<String> question;
  final Value<String> options;
  final Value<int> answerIndex;
  final Value<String> explanation;
  final Value<int> version;
  final Value<int> rowid;
  const QuizQuestionTableCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.question = const Value.absent(),
    this.options = const Value.absent(),
    this.answerIndex = const Value.absent(),
    this.explanation = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuizQuestionTableCompanion.insert({
    required String id,
    required String category,
    required int difficulty,
    required String question,
    required String options,
    required int answerIndex,
    required String explanation,
    required int version,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        category = Value(category),
        difficulty = Value(difficulty),
        question = Value(question),
        options = Value(options),
        answerIndex = Value(answerIndex),
        explanation = Value(explanation),
        version = Value(version);
  static Insertable<QuizQuestionTableData> custom({
    Expression<String>? id,
    Expression<String>? category,
    Expression<int>? difficulty,
    Expression<String>? question,
    Expression<String>? options,
    Expression<int>? answerIndex,
    Expression<String>? explanation,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (difficulty != null) 'difficulty': difficulty,
      if (question != null) 'question': question,
      if (options != null) 'options': options,
      if (answerIndex != null) 'answer_index': answerIndex,
      if (explanation != null) 'explanation': explanation,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuizQuestionTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? category,
      Value<int>? difficulty,
      Value<String>? question,
      Value<String>? options,
      Value<int>? answerIndex,
      Value<String>? explanation,
      Value<int>? version,
      Value<int>? rowid}) {
    return QuizQuestionTableCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      question: question ?? this.question,
      options: options ?? this.options,
      answerIndex: answerIndex ?? this.answerIndex,
      explanation: explanation ?? this.explanation,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (question.present) {
      map['question'] = Variable<String>(question.value);
    }
    if (options.present) {
      map['options'] = Variable<String>(options.value);
    }
    if (answerIndex.present) {
      map['answer_index'] = Variable<int>(answerIndex.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizQuestionTableCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('difficulty: $difficulty, ')
          ..write('question: $question, ')
          ..write('options: $options, ')
          ..write('answerIndex: $answerIndex, ')
          ..write('explanation: $explanation, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessageTableTable extends ChatMessageTable
    with TableInfo<$ChatMessageTableTable, ChatMessageTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessageTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(SyncState.pending));
  @override
  List<GeneratedColumn> get $columns =>
      [id, role, content, createdAt, syncState];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_message';
  @override
  VerificationContext validateIntegrity(
      Insertable<ChatMessageTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessageTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessageTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $ChatMessageTableTable createAlias(String alias) {
    return $ChatMessageTableTable(attachedDatabase, alias);
  }
}

class ChatMessageTableData extends DataClass
    implements Insertable<ChatMessageTableData> {
  final String id;
  final String role;
  final String content;
  final String createdAt;
  final String syncState;
  const ChatMessageTableData(
      {required this.id,
      required this.role,
      required this.content,
      required this.createdAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<String>(createdAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  ChatMessageTableCompanion toCompanion(bool nullToAbsent) {
    return ChatMessageTableCompanion(
      id: Value(id),
      role: Value(role),
      content: Value(content),
      createdAt: Value(createdAt),
      syncState: Value(syncState),
    );
  }

  factory ChatMessageTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessageTableData(
      id: serializer.fromJson<String>(json['id']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<String>(createdAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  ChatMessageTableData copyWith(
          {String? id,
          String? role,
          String? content,
          String? createdAt,
          String? syncState}) =>
      ChatMessageTableData(
        id: id ?? this.id,
        role: role ?? this.role,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
        syncState: syncState ?? this.syncState,
      );
  ChatMessageTableData copyWithCompanion(ChatMessageTableCompanion data) {
    return ChatMessageTableData(
      id: data.id.present ? data.id.value : this.id,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageTableData(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, role, content, createdAt, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageTableData &&
          other.id == this.id &&
          other.role == this.role &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.syncState == this.syncState);
}

class ChatMessageTableCompanion extends UpdateCompanion<ChatMessageTableData> {
  final Value<String> id;
  final Value<String> role;
  final Value<String> content;
  final Value<String> createdAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const ChatMessageTableCompanion({
    this.id = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessageTableCompanion.insert({
    required String id,
    required String role,
    required String content,
    required String createdAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        role = Value(role),
        content = Value(content),
        createdAt = Value(createdAt);
  static Insertable<ChatMessageTableData> custom({
    Expression<String>? id,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? createdAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessageTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? role,
      Value<String>? content,
      Value<String>? createdAt,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return ChatMessageTableCompanion(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageTableCompanion(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeedbackLocalTableTable extends FeedbackLocalTable
    with TableInfo<$FeedbackLocalTableTable, FeedbackLocalTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedbackLocalTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
      'rating', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _impressionMeta =
      const VerificationMeta('impression');
  @override
  late final GeneratedColumn<String> impression = GeneratedColumn<String>(
      'impression', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _suggestionMeta =
      const VerificationMeta('suggestion');
  @override
  late final GeneratedColumn<String> suggestion = GeneratedColumn<String>(
      'suggestion', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(SyncState.pending));
  @override
  List<GeneratedColumn> get $columns =>
      [id, rating, impression, suggestion, createdAt, updatedAt, syncState];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feedback_local';
  @override
  VerificationContext validateIntegrity(
      Insertable<FeedbackLocalTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('impression')) {
      context.handle(
          _impressionMeta,
          impression.isAcceptableOrUnknown(
              data['impression']!, _impressionMeta));
    } else if (isInserting) {
      context.missing(_impressionMeta);
    }
    if (data.containsKey('suggestion')) {
      context.handle(
          _suggestionMeta,
          suggestion.isAcceptableOrUnknown(
              data['suggestion']!, _suggestionMeta));
    } else if (isInserting) {
      context.missing(_suggestionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedbackLocalTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedbackLocalTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rating'])!,
      impression: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}impression'])!,
      suggestion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}suggestion'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $FeedbackLocalTableTable createAlias(String alias) {
    return $FeedbackLocalTableTable(attachedDatabase, alias);
  }
}

class FeedbackLocalTableData extends DataClass
    implements Insertable<FeedbackLocalTableData> {
  final String id;
  final int rating;
  final String impression;
  final String suggestion;
  final String createdAt;
  final String updatedAt;
  final String syncState;
  const FeedbackLocalTableData(
      {required this.id,
      required this.rating,
      required this.impression,
      required this.suggestion,
      required this.createdAt,
      required this.updatedAt,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['rating'] = Variable<int>(rating);
    map['impression'] = Variable<String>(impression);
    map['suggestion'] = Variable<String>(suggestion);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  FeedbackLocalTableCompanion toCompanion(bool nullToAbsent) {
    return FeedbackLocalTableCompanion(
      id: Value(id),
      rating: Value(rating),
      impression: Value(impression),
      suggestion: Value(suggestion),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncState: Value(syncState),
    );
  }

  factory FeedbackLocalTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedbackLocalTableData(
      id: serializer.fromJson<String>(json['id']),
      rating: serializer.fromJson<int>(json['rating']),
      impression: serializer.fromJson<String>(json['impression']),
      suggestion: serializer.fromJson<String>(json['suggestion']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'rating': serializer.toJson<int>(rating),
      'impression': serializer.toJson<String>(impression),
      'suggestion': serializer.toJson<String>(suggestion),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  FeedbackLocalTableData copyWith(
          {String? id,
          int? rating,
          String? impression,
          String? suggestion,
          String? createdAt,
          String? updatedAt,
          String? syncState}) =>
      FeedbackLocalTableData(
        id: id ?? this.id,
        rating: rating ?? this.rating,
        impression: impression ?? this.impression,
        suggestion: suggestion ?? this.suggestion,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
      );
  FeedbackLocalTableData copyWithCompanion(FeedbackLocalTableCompanion data) {
    return FeedbackLocalTableData(
      id: data.id.present ? data.id.value : this.id,
      rating: data.rating.present ? data.rating.value : this.rating,
      impression:
          data.impression.present ? data.impression.value : this.impression,
      suggestion:
          data.suggestion.present ? data.suggestion.value : this.suggestion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedbackLocalTableData(')
          ..write('id: $id, ')
          ..write('rating: $rating, ')
          ..write('impression: $impression, ')
          ..write('suggestion: $suggestion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, rating, impression, suggestion, createdAt, updatedAt, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedbackLocalTableData &&
          other.id == this.id &&
          other.rating == this.rating &&
          other.impression == this.impression &&
          other.suggestion == this.suggestion &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncState == this.syncState);
}

class FeedbackLocalTableCompanion
    extends UpdateCompanion<FeedbackLocalTableData> {
  final Value<String> id;
  final Value<int> rating;
  final Value<String> impression;
  final Value<String> suggestion;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> syncState;
  final Value<int> rowid;
  const FeedbackLocalTableCompanion({
    this.id = const Value.absent(),
    this.rating = const Value.absent(),
    this.impression = const Value.absent(),
    this.suggestion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedbackLocalTableCompanion.insert({
    required String id,
    required int rating,
    required String impression,
    required String suggestion,
    required String createdAt,
    required String updatedAt,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        rating = Value(rating),
        impression = Value(impression),
        suggestion = Value(suggestion),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<FeedbackLocalTableData> custom({
    Expression<String>? id,
    Expression<int>? rating,
    Expression<String>? impression,
    Expression<String>? suggestion,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rating != null) 'rating': rating,
      if (impression != null) 'impression': impression,
      if (suggestion != null) 'suggestion': suggestion,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedbackLocalTableCompanion copyWith(
      {Value<String>? id,
      Value<int>? rating,
      Value<String>? impression,
      Value<String>? suggestion,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return FeedbackLocalTableCompanion(
      id: id ?? this.id,
      rating: rating ?? this.rating,
      impression: impression ?? this.impression,
      suggestion: suggestion ?? this.suggestion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (impression.present) {
      map['impression'] = Variable<String>(impression.value);
    }
    if (suggestion.present) {
      map['suggestion'] = Variable<String>(suggestion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedbackLocalTableCompanion(')
          ..write('id: $id, ')
          ..write('rating: $rating, ')
          ..write('impression: $impression, ')
          ..write('suggestion: $suggestion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoriteMosqueTableTable extends FavoriteMosqueTable
    with TableInfo<$FavoriteMosqueTableTable, FavoriteMosqueTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteMosqueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _osmIdMeta = const VerificationMeta('osmId');
  @override
  late final GeneratedColumn<String> osmId = GeneratedColumn<String>(
      'osm_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
      'lon', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(SyncState.pending));
  @override
  List<GeneratedColumn> get $columns => [id, osmId, name, lat, lon, syncState];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_mosque';
  @override
  VerificationContext validateIntegrity(
      Insertable<FavoriteMosqueTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('osm_id')) {
      context.handle(
          _osmIdMeta, osmId.isAcceptableOrUnknown(data['osm_id']!, _osmIdMeta));
    } else if (isInserting) {
      context.missing(_osmIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(
          _lonMeta, lon.isAcceptableOrUnknown(data['lon']!, _lonMeta));
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavoriteMosqueTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteMosqueTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      osmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}osm_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lon: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lon'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $FavoriteMosqueTableTable createAlias(String alias) {
    return $FavoriteMosqueTableTable(attachedDatabase, alias);
  }
}

class FavoriteMosqueTableData extends DataClass
    implements Insertable<FavoriteMosqueTableData> {
  final String id;
  final String osmId;
  final String name;
  final double lat;
  final double lon;
  final String syncState;
  const FavoriteMosqueTableData(
      {required this.id,
      required this.osmId,
      required this.name,
      required this.lat,
      required this.lon,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['osm_id'] = Variable<String>(osmId);
    map['name'] = Variable<String>(name);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  FavoriteMosqueTableCompanion toCompanion(bool nullToAbsent) {
    return FavoriteMosqueTableCompanion(
      id: Value(id),
      osmId: Value(osmId),
      name: Value(name),
      lat: Value(lat),
      lon: Value(lon),
      syncState: Value(syncState),
    );
  }

  factory FavoriteMosqueTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteMosqueTableData(
      id: serializer.fromJson<String>(json['id']),
      osmId: serializer.fromJson<String>(json['osmId']),
      name: serializer.fromJson<String>(json['name']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'osmId': serializer.toJson<String>(osmId),
      'name': serializer.toJson<String>(name),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  FavoriteMosqueTableData copyWith(
          {String? id,
          String? osmId,
          String? name,
          double? lat,
          double? lon,
          String? syncState}) =>
      FavoriteMosqueTableData(
        id: id ?? this.id,
        osmId: osmId ?? this.osmId,
        name: name ?? this.name,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
        syncState: syncState ?? this.syncState,
      );
  FavoriteMosqueTableData copyWithCompanion(FavoriteMosqueTableCompanion data) {
    return FavoriteMosqueTableData(
      id: data.id.present ? data.id.value : this.id,
      osmId: data.osmId.present ? data.osmId.value : this.osmId,
      name: data.name.present ? data.name.value : this.name,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteMosqueTableData(')
          ..write('id: $id, ')
          ..write('osmId: $osmId, ')
          ..write('name: $name, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, osmId, name, lat, lon, syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteMosqueTableData &&
          other.id == this.id &&
          other.osmId == this.osmId &&
          other.name == this.name &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.syncState == this.syncState);
}

class FavoriteMosqueTableCompanion
    extends UpdateCompanion<FavoriteMosqueTableData> {
  final Value<String> id;
  final Value<String> osmId;
  final Value<String> name;
  final Value<double> lat;
  final Value<double> lon;
  final Value<String> syncState;
  final Value<int> rowid;
  const FavoriteMosqueTableCompanion({
    this.id = const Value.absent(),
    this.osmId = const Value.absent(),
    this.name = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoriteMosqueTableCompanion.insert({
    required String id,
    required String osmId,
    required String name,
    required double lat,
    required double lon,
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        osmId = Value(osmId),
        name = Value(name),
        lat = Value(lat),
        lon = Value(lon);
  static Insertable<FavoriteMosqueTableData> custom({
    Expression<String>? id,
    Expression<String>? osmId,
    Expression<String>? name,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (osmId != null) 'osm_id': osmId,
      if (name != null) 'name': name,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoriteMosqueTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? osmId,
      Value<String>? name,
      Value<double>? lat,
      Value<double>? lon,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return FavoriteMosqueTableCompanion(
      id: id ?? this.id,
      osmId: osmId ?? this.osmId,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (osmId.present) {
      map['osm_id'] = Variable<String>(osmId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteMosqueTableCompanion(')
          ..write('id: $id, ')
          ..write('osmId: $osmId, ')
          ..write('name: $name, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LedgerLocalTableTable ledgerLocalTable =
      $LedgerLocalTableTable(this);
  late final $OutboxTableTable outboxTable = $OutboxTableTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final $PrayerCacheTableTable prayerCacheTable =
      $PrayerCacheTableTable(this);
  late final $RateCacheTableTable rateCacheTable = $RateCacheTableTable(this);
  late final $DonationLocalTableTable donationLocalTable =
      $DonationLocalTableTable(this);
  late final $TasbihLogTableTable tasbihLogTable = $TasbihLogTableTable(this);
  late final $QuizAttemptTableTable quizAttemptTable =
      $QuizAttemptTableTable(this);
  late final $QuizQuestionTableTable quizQuestionTable =
      $QuizQuestionTableTable(this);
  late final $ChatMessageTableTable chatMessageTable =
      $ChatMessageTableTable(this);
  late final $FeedbackLocalTableTable feedbackLocalTable =
      $FeedbackLocalTableTable(this);
  late final $FavoriteMosqueTableTable favoriteMosqueTable =
      $FavoriteMosqueTableTable(this);
  late final LedgerDao ledgerDao = LedgerDao(this as AppDatabase);
  late final OutboxDao outboxDao = OutboxDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final PrayerCacheDao prayerCacheDao =
      PrayerCacheDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        ledgerLocalTable,
        outboxTable,
        settingsTable,
        prayerCacheTable,
        rateCacheTable,
        donationLocalTable,
        tasbihLogTable,
        quizAttemptTable,
        quizQuestionTable,
        chatMessageTable,
        feedbackLocalTable,
        favoriteMosqueTable
      ];
}

typedef $$LedgerLocalTableTableCreateCompanionBuilder
    = LedgerLocalTableCompanion Function({
  Value<int> idx,
  required String timestamp,
  required String donorAlias,
  required String campaign,
  required String amount,
  required String currency,
  required String amountIdr,
  required String rateUsed,
  required String prevHash,
  required int nonce,
  required String hash,
  Value<String> syncState,
});
typedef $$LedgerLocalTableTableUpdateCompanionBuilder
    = LedgerLocalTableCompanion Function({
  Value<int> idx,
  Value<String> timestamp,
  Value<String> donorAlias,
  Value<String> campaign,
  Value<String> amount,
  Value<String> currency,
  Value<String> amountIdr,
  Value<String> rateUsed,
  Value<String> prevHash,
  Value<int> nonce,
  Value<String> hash,
  Value<String> syncState,
});

class $$LedgerLocalTableTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerLocalTableTable> {
  $$LedgerLocalTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get idx => $composableBuilder(
      column: $table.idx, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get donorAlias => $composableBuilder(
      column: $table.donorAlias, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get campaign => $composableBuilder(
      column: $table.campaign, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get amountIdr => $composableBuilder(
      column: $table.amountIdr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rateUsed => $composableBuilder(
      column: $table.rateUsed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prevHash => $composableBuilder(
      column: $table.prevHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nonce => $composableBuilder(
      column: $table.nonce, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hash => $composableBuilder(
      column: $table.hash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));
}

class $$LedgerLocalTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerLocalTableTable> {
  $$LedgerLocalTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get idx => $composableBuilder(
      column: $table.idx, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get donorAlias => $composableBuilder(
      column: $table.donorAlias, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get campaign => $composableBuilder(
      column: $table.campaign, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get amountIdr => $composableBuilder(
      column: $table.amountIdr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rateUsed => $composableBuilder(
      column: $table.rateUsed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prevHash => $composableBuilder(
      column: $table.prevHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nonce => $composableBuilder(
      column: $table.nonce, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hash => $composableBuilder(
      column: $table.hash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));
}

class $$LedgerLocalTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerLocalTableTable> {
  $$LedgerLocalTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get idx =>
      $composableBuilder(column: $table.idx, builder: (column) => column);

  GeneratedColumn<String> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get donorAlias => $composableBuilder(
      column: $table.donorAlias, builder: (column) => column);

  GeneratedColumn<String> get campaign =>
      $composableBuilder(column: $table.campaign, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get amountIdr =>
      $composableBuilder(column: $table.amountIdr, builder: (column) => column);

  GeneratedColumn<String> get rateUsed =>
      $composableBuilder(column: $table.rateUsed, builder: (column) => column);

  GeneratedColumn<String> get prevHash =>
      $composableBuilder(column: $table.prevHash, builder: (column) => column);

  GeneratedColumn<int> get nonce =>
      $composableBuilder(column: $table.nonce, builder: (column) => column);

  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$LedgerLocalTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LedgerLocalTableTable,
    LedgerLocalTableData,
    $$LedgerLocalTableTableFilterComposer,
    $$LedgerLocalTableTableOrderingComposer,
    $$LedgerLocalTableTableAnnotationComposer,
    $$LedgerLocalTableTableCreateCompanionBuilder,
    $$LedgerLocalTableTableUpdateCompanionBuilder,
    (
      LedgerLocalTableData,
      BaseReferences<_$AppDatabase, $LedgerLocalTableTable,
          LedgerLocalTableData>
    ),
    LedgerLocalTableData,
    PrefetchHooks Function()> {
  $$LedgerLocalTableTableTableManager(
      _$AppDatabase db, $LedgerLocalTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerLocalTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerLocalTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerLocalTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> idx = const Value.absent(),
            Value<String> timestamp = const Value.absent(),
            Value<String> donorAlias = const Value.absent(),
            Value<String> campaign = const Value.absent(),
            Value<String> amount = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String> amountIdr = const Value.absent(),
            Value<String> rateUsed = const Value.absent(),
            Value<String> prevHash = const Value.absent(),
            Value<int> nonce = const Value.absent(),
            Value<String> hash = const Value.absent(),
            Value<String> syncState = const Value.absent(),
          }) =>
              LedgerLocalTableCompanion(
            idx: idx,
            timestamp: timestamp,
            donorAlias: donorAlias,
            campaign: campaign,
            amount: amount,
            currency: currency,
            amountIdr: amountIdr,
            rateUsed: rateUsed,
            prevHash: prevHash,
            nonce: nonce,
            hash: hash,
            syncState: syncState,
          ),
          createCompanionCallback: ({
            Value<int> idx = const Value.absent(),
            required String timestamp,
            required String donorAlias,
            required String campaign,
            required String amount,
            required String currency,
            required String amountIdr,
            required String rateUsed,
            required String prevHash,
            required int nonce,
            required String hash,
            Value<String> syncState = const Value.absent(),
          }) =>
              LedgerLocalTableCompanion.insert(
            idx: idx,
            timestamp: timestamp,
            donorAlias: donorAlias,
            campaign: campaign,
            amount: amount,
            currency: currency,
            amountIdr: amountIdr,
            rateUsed: rateUsed,
            prevHash: prevHash,
            nonce: nonce,
            hash: hash,
            syncState: syncState,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$LedgerLocalTableTable, LedgerLocalTableData>(
                        table),
                    BaseReferences<_$AppDatabase, $LedgerLocalTableTable,
                        LedgerLocalTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LedgerLocalTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LedgerLocalTableTable,
    LedgerLocalTableData,
    $$LedgerLocalTableTableFilterComposer,
    $$LedgerLocalTableTableOrderingComposer,
    $$LedgerLocalTableTableAnnotationComposer,
    $$LedgerLocalTableTableCreateCompanionBuilder,
    $$LedgerLocalTableTableUpdateCompanionBuilder,
    (
      LedgerLocalTableData,
      BaseReferences<_$AppDatabase, $LedgerLocalTableTable,
          LedgerLocalTableData>
    ),
    LedgerLocalTableData,
    PrefetchHooks Function()>;
typedef $$OutboxTableTableCreateCompanionBuilder = OutboxTableCompanion
    Function({
  Value<int> id,
  required String entity,
  required String op,
  required String payload,
  required DateTime createdAt,
  Value<int> attempts,
  Value<String?> lastError,
  required DateTime nextAttemptAt,
});
typedef $$OutboxTableTableUpdateCompanionBuilder = OutboxTableCompanion
    Function({
  Value<int> id,
  Value<String> entity,
  Value<String> op,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<int> attempts,
  Value<String?> lastError,
  Value<DateTime> nextAttemptAt,
});

class $$OutboxTableTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTableTable> {
  $$OutboxTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get op => $composableBuilder(
      column: $table.op, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => ColumnFilters(column));
}

class $$OutboxTableTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTableTable> {
  $$OutboxTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get op => $composableBuilder(
      column: $table.op, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt,
      builder: (column) => ColumnOrderings(column));
}

class $$OutboxTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTableTable> {
  $$OutboxTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
      column: $table.nextAttemptAt, builder: (column) => column);
}

class $$OutboxTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutboxTableTable,
    OutboxTableData,
    $$OutboxTableTableFilterComposer,
    $$OutboxTableTableOrderingComposer,
    $$OutboxTableTableAnnotationComposer,
    $$OutboxTableTableCreateCompanionBuilder,
    $$OutboxTableTableUpdateCompanionBuilder,
    (
      OutboxTableData,
      BaseReferences<_$AppDatabase, $OutboxTableTable, OutboxTableData>
    ),
    OutboxTableData,
    PrefetchHooks Function()> {
  $$OutboxTableTableTableManager(_$AppDatabase db, $OutboxTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> entity = const Value.absent(),
            Value<String> op = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime> nextAttemptAt = const Value.absent(),
          }) =>
              OutboxTableCompanion(
            id: id,
            entity: entity,
            op: op,
            payload: payload,
            createdAt: createdAt,
            attempts: attempts,
            lastError: lastError,
            nextAttemptAt: nextAttemptAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String entity,
            required String op,
            required String payload,
            required DateTime createdAt,
            Value<int> attempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            required DateTime nextAttemptAt,
          }) =>
              OutboxTableCompanion.insert(
            id: id,
            entity: entity,
            op: op,
            payload: payload,
            createdAt: createdAt,
            attempts: attempts,
            lastError: lastError,
            nextAttemptAt: nextAttemptAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$OutboxTableTable, OutboxTableData>(table),
                    BaseReferences<_$AppDatabase, $OutboxTableTable,
                        OutboxTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutboxTableTable,
    OutboxTableData,
    $$OutboxTableTableFilterComposer,
    $$OutboxTableTableOrderingComposer,
    $$OutboxTableTableAnnotationComposer,
    $$OutboxTableTableCreateCompanionBuilder,
    $$OutboxTableTableUpdateCompanionBuilder,
    (
      OutboxTableData,
      BaseReferences<_$AppDatabase, $OutboxTableTable, OutboxTableData>
    ),
    OutboxTableData,
    PrefetchHooks Function()>;
typedef $$SettingsTableTableCreateCompanionBuilder = SettingsTableCompanion
    Function({
  required String settingKey,
  required String settingValue,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$SettingsTableTableUpdateCompanionBuilder = SettingsTableCompanion
    Function({
  Value<String> settingKey,
  Value<String> settingValue,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get settingKey => $composableBuilder(
      column: $table.settingKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get settingValue => $composableBuilder(
      column: $table.settingValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get settingKey => $composableBuilder(
      column: $table.settingKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get settingValue => $composableBuilder(
      column: $table.settingValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get settingKey => $composableBuilder(
      column: $table.settingKey, builder: (column) => column);

  GeneratedColumn<String> get settingValue => $composableBuilder(
      column: $table.settingValue, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTableTable,
    SettingsTableData,
    $$SettingsTableTableFilterComposer,
    $$SettingsTableTableOrderingComposer,
    $$SettingsTableTableAnnotationComposer,
    $$SettingsTableTableCreateCompanionBuilder,
    $$SettingsTableTableUpdateCompanionBuilder,
    (
      SettingsTableData,
      BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>
    ),
    SettingsTableData,
    PrefetchHooks Function()> {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> settingKey = const Value.absent(),
            Value<String> settingValue = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsTableCompanion(
            settingKey: settingKey,
            settingValue: settingValue,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String settingKey,
            required String settingValue,
            required String updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsTableCompanion.insert(
            settingKey: settingKey,
            settingValue: settingValue,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SettingsTableTable, SettingsTableData>(table),
                    BaseReferences<_$AppDatabase, $SettingsTableTable,
                        SettingsTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTableTable,
    SettingsTableData,
    $$SettingsTableTableFilterComposer,
    $$SettingsTableTableOrderingComposer,
    $$SettingsTableTableAnnotationComposer,
    $$SettingsTableTableCreateCompanionBuilder,
    $$SettingsTableTableUpdateCompanionBuilder,
    (
      SettingsTableData,
      BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>
    ),
    SettingsTableData,
    PrefetchHooks Function()>;
typedef $$PrayerCacheTableTableCreateCompanionBuilder
    = PrayerCacheTableCompanion Function({
  required String date,
  required String locationKey,
  required double lat,
  required double lon,
  required String method,
  required String fajr,
  required String sunrise,
  required String dhuhr,
  required String asr,
  required String maghrib,
  required String isha,
  required int utcOffsetMinutes,
  required DateTime fetchedAt,
  Value<int> rowid,
});
typedef $$PrayerCacheTableTableUpdateCompanionBuilder
    = PrayerCacheTableCompanion Function({
  Value<String> date,
  Value<String> locationKey,
  Value<double> lat,
  Value<double> lon,
  Value<String> method,
  Value<String> fajr,
  Value<String> sunrise,
  Value<String> dhuhr,
  Value<String> asr,
  Value<String> maghrib,
  Value<String> isha,
  Value<int> utcOffsetMinutes,
  Value<DateTime> fetchedAt,
  Value<int> rowid,
});

class $$PrayerCacheTableTableFilterComposer
    extends Composer<_$AppDatabase, $PrayerCacheTableTable> {
  $$PrayerCacheTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationKey => $composableBuilder(
      column: $table.locationKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lon => $composableBuilder(
      column: $table.lon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fajr => $composableBuilder(
      column: $table.fajr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sunrise => $composableBuilder(
      column: $table.sunrise, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dhuhr => $composableBuilder(
      column: $table.dhuhr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get asr => $composableBuilder(
      column: $table.asr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get maghrib => $composableBuilder(
      column: $table.maghrib, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get isha => $composableBuilder(
      column: $table.isha, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get utcOffsetMinutes => $composableBuilder(
      column: $table.utcOffsetMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnFilters(column));
}

class $$PrayerCacheTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PrayerCacheTableTable> {
  $$PrayerCacheTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationKey => $composableBuilder(
      column: $table.locationKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lon => $composableBuilder(
      column: $table.lon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fajr => $composableBuilder(
      column: $table.fajr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sunrise => $composableBuilder(
      column: $table.sunrise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dhuhr => $composableBuilder(
      column: $table.dhuhr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get asr => $composableBuilder(
      column: $table.asr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get maghrib => $composableBuilder(
      column: $table.maghrib, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get isha => $composableBuilder(
      column: $table.isha, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get utcOffsetMinutes => $composableBuilder(
      column: $table.utcOffsetMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnOrderings(column));
}

class $$PrayerCacheTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrayerCacheTableTable> {
  $$PrayerCacheTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get locationKey => $composableBuilder(
      column: $table.locationKey, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get fajr =>
      $composableBuilder(column: $table.fajr, builder: (column) => column);

  GeneratedColumn<String> get sunrise =>
      $composableBuilder(column: $table.sunrise, builder: (column) => column);

  GeneratedColumn<String> get dhuhr =>
      $composableBuilder(column: $table.dhuhr, builder: (column) => column);

  GeneratedColumn<String> get asr =>
      $composableBuilder(column: $table.asr, builder: (column) => column);

  GeneratedColumn<String> get maghrib =>
      $composableBuilder(column: $table.maghrib, builder: (column) => column);

  GeneratedColumn<String> get isha =>
      $composableBuilder(column: $table.isha, builder: (column) => column);

  GeneratedColumn<int> get utcOffsetMinutes => $composableBuilder(
      column: $table.utcOffsetMinutes, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$PrayerCacheTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PrayerCacheTableTable,
    PrayerCacheTableData,
    $$PrayerCacheTableTableFilterComposer,
    $$PrayerCacheTableTableOrderingComposer,
    $$PrayerCacheTableTableAnnotationComposer,
    $$PrayerCacheTableTableCreateCompanionBuilder,
    $$PrayerCacheTableTableUpdateCompanionBuilder,
    (
      PrayerCacheTableData,
      BaseReferences<_$AppDatabase, $PrayerCacheTableTable,
          PrayerCacheTableData>
    ),
    PrayerCacheTableData,
    PrefetchHooks Function()> {
  $$PrayerCacheTableTableTableManager(
      _$AppDatabase db, $PrayerCacheTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrayerCacheTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrayerCacheTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrayerCacheTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> date = const Value.absent(),
            Value<String> locationKey = const Value.absent(),
            Value<double> lat = const Value.absent(),
            Value<double> lon = const Value.absent(),
            Value<String> method = const Value.absent(),
            Value<String> fajr = const Value.absent(),
            Value<String> sunrise = const Value.absent(),
            Value<String> dhuhr = const Value.absent(),
            Value<String> asr = const Value.absent(),
            Value<String> maghrib = const Value.absent(),
            Value<String> isha = const Value.absent(),
            Value<int> utcOffsetMinutes = const Value.absent(),
            Value<DateTime> fetchedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PrayerCacheTableCompanion(
            date: date,
            locationKey: locationKey,
            lat: lat,
            lon: lon,
            method: method,
            fajr: fajr,
            sunrise: sunrise,
            dhuhr: dhuhr,
            asr: asr,
            maghrib: maghrib,
            isha: isha,
            utcOffsetMinutes: utcOffsetMinutes,
            fetchedAt: fetchedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String date,
            required String locationKey,
            required double lat,
            required double lon,
            required String method,
            required String fajr,
            required String sunrise,
            required String dhuhr,
            required String asr,
            required String maghrib,
            required String isha,
            required int utcOffsetMinutes,
            required DateTime fetchedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PrayerCacheTableCompanion.insert(
            date: date,
            locationKey: locationKey,
            lat: lat,
            lon: lon,
            method: method,
            fajr: fajr,
            sunrise: sunrise,
            dhuhr: dhuhr,
            asr: asr,
            maghrib: maghrib,
            isha: isha,
            utcOffsetMinutes: utcOffsetMinutes,
            fetchedAt: fetchedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PrayerCacheTableTable, PrayerCacheTableData>(
                        table),
                    BaseReferences<_$AppDatabase, $PrayerCacheTableTable,
                        PrayerCacheTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PrayerCacheTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PrayerCacheTableTable,
    PrayerCacheTableData,
    $$PrayerCacheTableTableFilterComposer,
    $$PrayerCacheTableTableOrderingComposer,
    $$PrayerCacheTableTableAnnotationComposer,
    $$PrayerCacheTableTableCreateCompanionBuilder,
    $$PrayerCacheTableTableUpdateCompanionBuilder,
    (
      PrayerCacheTableData,
      BaseReferences<_$AppDatabase, $PrayerCacheTableTable,
          PrayerCacheTableData>
    ),
    PrayerCacheTableData,
    PrefetchHooks Function()>;
typedef $$RateCacheTableTableCreateCompanionBuilder = RateCacheTableCompanion
    Function({
  required String base,
  required String quote,
  required double rate,
  required DateTime fetchedAt,
  Value<int> rowid,
});
typedef $$RateCacheTableTableUpdateCompanionBuilder = RateCacheTableCompanion
    Function({
  Value<String> base,
  Value<String> quote,
  Value<double> rate,
  Value<DateTime> fetchedAt,
  Value<int> rowid,
});

class $$RateCacheTableTableFilterComposer
    extends Composer<_$AppDatabase, $RateCacheTableTable> {
  $$RateCacheTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get base => $composableBuilder(
      column: $table.base, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quote => $composableBuilder(
      column: $table.quote, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rate => $composableBuilder(
      column: $table.rate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnFilters(column));
}

class $$RateCacheTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RateCacheTableTable> {
  $$RateCacheTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get base => $composableBuilder(
      column: $table.base, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quote => $composableBuilder(
      column: $table.quote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rate => $composableBuilder(
      column: $table.rate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnOrderings(column));
}

class $$RateCacheTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RateCacheTableTable> {
  $$RateCacheTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get base =>
      $composableBuilder(column: $table.base, builder: (column) => column);

  GeneratedColumn<String> get quote =>
      $composableBuilder(column: $table.quote, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$RateCacheTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RateCacheTableTable,
    RateCacheTableData,
    $$RateCacheTableTableFilterComposer,
    $$RateCacheTableTableOrderingComposer,
    $$RateCacheTableTableAnnotationComposer,
    $$RateCacheTableTableCreateCompanionBuilder,
    $$RateCacheTableTableUpdateCompanionBuilder,
    (
      RateCacheTableData,
      BaseReferences<_$AppDatabase, $RateCacheTableTable, RateCacheTableData>
    ),
    RateCacheTableData,
    PrefetchHooks Function()> {
  $$RateCacheTableTableTableManager(
      _$AppDatabase db, $RateCacheTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RateCacheTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RateCacheTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RateCacheTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> base = const Value.absent(),
            Value<String> quote = const Value.absent(),
            Value<double> rate = const Value.absent(),
            Value<DateTime> fetchedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RateCacheTableCompanion(
            base: base,
            quote: quote,
            rate: rate,
            fetchedAt: fetchedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String base,
            required String quote,
            required double rate,
            required DateTime fetchedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              RateCacheTableCompanion.insert(
            base: base,
            quote: quote,
            rate: rate,
            fetchedAt: fetchedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$RateCacheTableTable, RateCacheTableData>(
                        table),
                    BaseReferences<_$AppDatabase, $RateCacheTableTable,
                        RateCacheTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RateCacheTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RateCacheTableTable,
    RateCacheTableData,
    $$RateCacheTableTableFilterComposer,
    $$RateCacheTableTableOrderingComposer,
    $$RateCacheTableTableAnnotationComposer,
    $$RateCacheTableTableCreateCompanionBuilder,
    $$RateCacheTableTableUpdateCompanionBuilder,
    (
      RateCacheTableData,
      BaseReferences<_$AppDatabase, $RateCacheTableTable, RateCacheTableData>
    ),
    RateCacheTableData,
    PrefetchHooks Function()>;
typedef $$DonationLocalTableTableCreateCompanionBuilder
    = DonationLocalTableCompanion Function({
  required String id,
  required String campaign,
  required String amount,
  required String currency,
  required String amountIdr,
  required String rateUsed,
  required String createdAt,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$DonationLocalTableTableUpdateCompanionBuilder
    = DonationLocalTableCompanion Function({
  Value<String> id,
  Value<String> campaign,
  Value<String> amount,
  Value<String> currency,
  Value<String> amountIdr,
  Value<String> rateUsed,
  Value<String> createdAt,
  Value<String> syncState,
  Value<int> rowid,
});

class $$DonationLocalTableTableFilterComposer
    extends Composer<_$AppDatabase, $DonationLocalTableTable> {
  $$DonationLocalTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get campaign => $composableBuilder(
      column: $table.campaign, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get amountIdr => $composableBuilder(
      column: $table.amountIdr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rateUsed => $composableBuilder(
      column: $table.rateUsed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));
}

class $$DonationLocalTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DonationLocalTableTable> {
  $$DonationLocalTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get campaign => $composableBuilder(
      column: $table.campaign, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get amountIdr => $composableBuilder(
      column: $table.amountIdr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rateUsed => $composableBuilder(
      column: $table.rateUsed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));
}

class $$DonationLocalTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DonationLocalTableTable> {
  $$DonationLocalTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get campaign =>
      $composableBuilder(column: $table.campaign, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get amountIdr =>
      $composableBuilder(column: $table.amountIdr, builder: (column) => column);

  GeneratedColumn<String> get rateUsed =>
      $composableBuilder(column: $table.rateUsed, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$DonationLocalTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DonationLocalTableTable,
    DonationLocalTableData,
    $$DonationLocalTableTableFilterComposer,
    $$DonationLocalTableTableOrderingComposer,
    $$DonationLocalTableTableAnnotationComposer,
    $$DonationLocalTableTableCreateCompanionBuilder,
    $$DonationLocalTableTableUpdateCompanionBuilder,
    (
      DonationLocalTableData,
      BaseReferences<_$AppDatabase, $DonationLocalTableTable,
          DonationLocalTableData>
    ),
    DonationLocalTableData,
    PrefetchHooks Function()> {
  $$DonationLocalTableTableTableManager(
      _$AppDatabase db, $DonationLocalTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DonationLocalTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DonationLocalTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DonationLocalTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> campaign = const Value.absent(),
            Value<String> amount = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String> amountIdr = const Value.absent(),
            Value<String> rateUsed = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DonationLocalTableCompanion(
            id: id,
            campaign: campaign,
            amount: amount,
            currency: currency,
            amountIdr: amountIdr,
            rateUsed: rateUsed,
            createdAt: createdAt,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String campaign,
            required String amount,
            required String currency,
            required String amountIdr,
            required String rateUsed,
            required String createdAt,
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DonationLocalTableCompanion.insert(
            id: id,
            campaign: campaign,
            amount: amount,
            currency: currency,
            amountIdr: amountIdr,
            rateUsed: rateUsed,
            createdAt: createdAt,
            syncState: syncState,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$DonationLocalTableTable,
                        DonationLocalTableData>(table),
                    BaseReferences<_$AppDatabase, $DonationLocalTableTable,
                        DonationLocalTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DonationLocalTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DonationLocalTableTable,
    DonationLocalTableData,
    $$DonationLocalTableTableFilterComposer,
    $$DonationLocalTableTableOrderingComposer,
    $$DonationLocalTableTableAnnotationComposer,
    $$DonationLocalTableTableCreateCompanionBuilder,
    $$DonationLocalTableTableUpdateCompanionBuilder,
    (
      DonationLocalTableData,
      BaseReferences<_$AppDatabase, $DonationLocalTableTable,
          DonationLocalTableData>
    ),
    DonationLocalTableData,
    PrefetchHooks Function()>;
typedef $$TasbihLogTableTableCreateCompanionBuilder = TasbihLogTableCompanion
    Function({
  required String id,
  required String date,
  required int target,
  required int count,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$TasbihLogTableTableUpdateCompanionBuilder = TasbihLogTableCompanion
    Function({
  Value<String> id,
  Value<String> date,
  Value<int> target,
  Value<int> count,
  Value<String> syncState,
  Value<int> rowid,
});

class $$TasbihLogTableTableFilterComposer
    extends Composer<_$AppDatabase, $TasbihLogTableTable> {
  $$TasbihLogTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get target => $composableBuilder(
      column: $table.target, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get count => $composableBuilder(
      column: $table.count, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));
}

class $$TasbihLogTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TasbihLogTableTable> {
  $$TasbihLogTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get target => $composableBuilder(
      column: $table.target, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get count => $composableBuilder(
      column: $table.count, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));
}

class $$TasbihLogTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasbihLogTableTable> {
  $$TasbihLogTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$TasbihLogTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasbihLogTableTable,
    TasbihLogTableData,
    $$TasbihLogTableTableFilterComposer,
    $$TasbihLogTableTableOrderingComposer,
    $$TasbihLogTableTableAnnotationComposer,
    $$TasbihLogTableTableCreateCompanionBuilder,
    $$TasbihLogTableTableUpdateCompanionBuilder,
    (
      TasbihLogTableData,
      BaseReferences<_$AppDatabase, $TasbihLogTableTable, TasbihLogTableData>
    ),
    TasbihLogTableData,
    PrefetchHooks Function()> {
  $$TasbihLogTableTableTableManager(
      _$AppDatabase db, $TasbihLogTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasbihLogTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasbihLogTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasbihLogTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<int> target = const Value.absent(),
            Value<int> count = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasbihLogTableCompanion(
            id: id,
            date: date,
            target: target,
            count: count,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String date,
            required int target,
            required int count,
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasbihLogTableCompanion.insert(
            id: id,
            date: date,
            target: target,
            count: count,
            syncState: syncState,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$TasbihLogTableTable, TasbihLogTableData>(
                        table),
                    BaseReferences<_$AppDatabase, $TasbihLogTableTable,
                        TasbihLogTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TasbihLogTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasbihLogTableTable,
    TasbihLogTableData,
    $$TasbihLogTableTableFilterComposer,
    $$TasbihLogTableTableOrderingComposer,
    $$TasbihLogTableTableAnnotationComposer,
    $$TasbihLogTableTableCreateCompanionBuilder,
    $$TasbihLogTableTableUpdateCompanionBuilder,
    (
      TasbihLogTableData,
      BaseReferences<_$AppDatabase, $TasbihLogTableTable, TasbihLogTableData>
    ),
    TasbihLogTableData,
    PrefetchHooks Function()>;
typedef $$QuizAttemptTableTableCreateCompanionBuilder
    = QuizAttemptTableCompanion Function({
  required String id,
  required String category,
  required int score,
  required int correct,
  required int total,
  Value<double?> avgTimeSeconds,
  required String createdAt,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$QuizAttemptTableTableUpdateCompanionBuilder
    = QuizAttemptTableCompanion Function({
  Value<String> id,
  Value<String> category,
  Value<int> score,
  Value<int> correct,
  Value<int> total,
  Value<double?> avgTimeSeconds,
  Value<String> createdAt,
  Value<String> syncState,
  Value<int> rowid,
});

class $$QuizAttemptTableTableFilterComposer
    extends Composer<_$AppDatabase, $QuizAttemptTableTable> {
  $$QuizAttemptTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get correct => $composableBuilder(
      column: $table.correct, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get avgTimeSeconds => $composableBuilder(
      column: $table.avgTimeSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));
}

class $$QuizAttemptTableTableOrderingComposer
    extends Composer<_$AppDatabase, $QuizAttemptTableTable> {
  $$QuizAttemptTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get correct => $composableBuilder(
      column: $table.correct, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get avgTimeSeconds => $composableBuilder(
      column: $table.avgTimeSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));
}

class $$QuizAttemptTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuizAttemptTableTable> {
  $$QuizAttemptTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<double> get avgTimeSeconds => $composableBuilder(
      column: $table.avgTimeSeconds, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$QuizAttemptTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuizAttemptTableTable,
    QuizAttemptTableData,
    $$QuizAttemptTableTableFilterComposer,
    $$QuizAttemptTableTableOrderingComposer,
    $$QuizAttemptTableTableAnnotationComposer,
    $$QuizAttemptTableTableCreateCompanionBuilder,
    $$QuizAttemptTableTableUpdateCompanionBuilder,
    (
      QuizAttemptTableData,
      BaseReferences<_$AppDatabase, $QuizAttemptTableTable,
          QuizAttemptTableData>
    ),
    QuizAttemptTableData,
    PrefetchHooks Function()> {
  $$QuizAttemptTableTableTableManager(
      _$AppDatabase db, $QuizAttemptTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuizAttemptTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuizAttemptTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuizAttemptTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<int> score = const Value.absent(),
            Value<int> correct = const Value.absent(),
            Value<int> total = const Value.absent(),
            Value<double?> avgTimeSeconds = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuizAttemptTableCompanion(
            id: id,
            category: category,
            score: score,
            correct: correct,
            total: total,
            avgTimeSeconds: avgTimeSeconds,
            createdAt: createdAt,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String category,
            required int score,
            required int correct,
            required int total,
            Value<double?> avgTimeSeconds = const Value.absent(),
            required String createdAt,
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuizAttemptTableCompanion.insert(
            id: id,
            category: category,
            score: score,
            correct: correct,
            total: total,
            avgTimeSeconds: avgTimeSeconds,
            createdAt: createdAt,
            syncState: syncState,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$QuizAttemptTableTable, QuizAttemptTableData>(
                        table),
                    BaseReferences<_$AppDatabase, $QuizAttemptTableTable,
                        QuizAttemptTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QuizAttemptTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuizAttemptTableTable,
    QuizAttemptTableData,
    $$QuizAttemptTableTableFilterComposer,
    $$QuizAttemptTableTableOrderingComposer,
    $$QuizAttemptTableTableAnnotationComposer,
    $$QuizAttemptTableTableCreateCompanionBuilder,
    $$QuizAttemptTableTableUpdateCompanionBuilder,
    (
      QuizAttemptTableData,
      BaseReferences<_$AppDatabase, $QuizAttemptTableTable,
          QuizAttemptTableData>
    ),
    QuizAttemptTableData,
    PrefetchHooks Function()>;
typedef $$QuizQuestionTableTableCreateCompanionBuilder
    = QuizQuestionTableCompanion Function({
  required String id,
  required String category,
  required int difficulty,
  required String question,
  required String options,
  required int answerIndex,
  required String explanation,
  required int version,
  Value<int> rowid,
});
typedef $$QuizQuestionTableTableUpdateCompanionBuilder
    = QuizQuestionTableCompanion Function({
  Value<String> id,
  Value<String> category,
  Value<int> difficulty,
  Value<String> question,
  Value<String> options,
  Value<int> answerIndex,
  Value<String> explanation,
  Value<int> version,
  Value<int> rowid,
});

class $$QuizQuestionTableTableFilterComposer
    extends Composer<_$AppDatabase, $QuizQuestionTableTable> {
  $$QuizQuestionTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get question => $composableBuilder(
      column: $table.question, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get options => $composableBuilder(
      column: $table.options, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get answerIndex => $composableBuilder(
      column: $table.answerIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));
}

class $$QuizQuestionTableTableOrderingComposer
    extends Composer<_$AppDatabase, $QuizQuestionTableTable> {
  $$QuizQuestionTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get question => $composableBuilder(
      column: $table.question, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get options => $composableBuilder(
      column: $table.options, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get answerIndex => $composableBuilder(
      column: $table.answerIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));
}

class $$QuizQuestionTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuizQuestionTableTable> {
  $$QuizQuestionTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<String> get question =>
      $composableBuilder(column: $table.question, builder: (column) => column);

  GeneratedColumn<String> get options =>
      $composableBuilder(column: $table.options, builder: (column) => column);

  GeneratedColumn<int> get answerIndex => $composableBuilder(
      column: $table.answerIndex, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$QuizQuestionTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuizQuestionTableTable,
    QuizQuestionTableData,
    $$QuizQuestionTableTableFilterComposer,
    $$QuizQuestionTableTableOrderingComposer,
    $$QuizQuestionTableTableAnnotationComposer,
    $$QuizQuestionTableTableCreateCompanionBuilder,
    $$QuizQuestionTableTableUpdateCompanionBuilder,
    (
      QuizQuestionTableData,
      BaseReferences<_$AppDatabase, $QuizQuestionTableTable,
          QuizQuestionTableData>
    ),
    QuizQuestionTableData,
    PrefetchHooks Function()> {
  $$QuizQuestionTableTableTableManager(
      _$AppDatabase db, $QuizQuestionTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuizQuestionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuizQuestionTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuizQuestionTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<int> difficulty = const Value.absent(),
            Value<String> question = const Value.absent(),
            Value<String> options = const Value.absent(),
            Value<int> answerIndex = const Value.absent(),
            Value<String> explanation = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuizQuestionTableCompanion(
            id: id,
            category: category,
            difficulty: difficulty,
            question: question,
            options: options,
            answerIndex: answerIndex,
            explanation: explanation,
            version: version,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String category,
            required int difficulty,
            required String question,
            required String options,
            required int answerIndex,
            required String explanation,
            required int version,
            Value<int> rowid = const Value.absent(),
          }) =>
              QuizQuestionTableCompanion.insert(
            id: id,
            category: category,
            difficulty: difficulty,
            question: question,
            options: options,
            answerIndex: answerIndex,
            explanation: explanation,
            version: version,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$QuizQuestionTableTable, QuizQuestionTableData>(
                        table),
                    BaseReferences<_$AppDatabase, $QuizQuestionTableTable,
                        QuizQuestionTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QuizQuestionTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuizQuestionTableTable,
    QuizQuestionTableData,
    $$QuizQuestionTableTableFilterComposer,
    $$QuizQuestionTableTableOrderingComposer,
    $$QuizQuestionTableTableAnnotationComposer,
    $$QuizQuestionTableTableCreateCompanionBuilder,
    $$QuizQuestionTableTableUpdateCompanionBuilder,
    (
      QuizQuestionTableData,
      BaseReferences<_$AppDatabase, $QuizQuestionTableTable,
          QuizQuestionTableData>
    ),
    QuizQuestionTableData,
    PrefetchHooks Function()>;
typedef $$ChatMessageTableTableCreateCompanionBuilder
    = ChatMessageTableCompanion Function({
  required String id,
  required String role,
  required String content,
  required String createdAt,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$ChatMessageTableTableUpdateCompanionBuilder
    = ChatMessageTableCompanion Function({
  Value<String> id,
  Value<String> role,
  Value<String> content,
  Value<String> createdAt,
  Value<String> syncState,
  Value<int> rowid,
});

class $$ChatMessageTableTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessageTableTable> {
  $$ChatMessageTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));
}

class $$ChatMessageTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessageTableTable> {
  $$ChatMessageTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));
}

class $$ChatMessageTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessageTableTable> {
  $$ChatMessageTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$ChatMessageTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatMessageTableTable,
    ChatMessageTableData,
    $$ChatMessageTableTableFilterComposer,
    $$ChatMessageTableTableOrderingComposer,
    $$ChatMessageTableTableAnnotationComposer,
    $$ChatMessageTableTableCreateCompanionBuilder,
    $$ChatMessageTableTableUpdateCompanionBuilder,
    (
      ChatMessageTableData,
      BaseReferences<_$AppDatabase, $ChatMessageTableTable,
          ChatMessageTableData>
    ),
    ChatMessageTableData,
    PrefetchHooks Function()> {
  $$ChatMessageTableTableTableManager(
      _$AppDatabase db, $ChatMessageTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessageTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessageTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessageTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatMessageTableCompanion(
            id: id,
            role: role,
            content: content,
            createdAt: createdAt,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String role,
            required String content,
            required String createdAt,
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatMessageTableCompanion.insert(
            id: id,
            role: role,
            content: content,
            createdAt: createdAt,
            syncState: syncState,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ChatMessageTableTable, ChatMessageTableData>(
                        table),
                    BaseReferences<_$AppDatabase, $ChatMessageTableTable,
                        ChatMessageTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatMessageTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatMessageTableTable,
    ChatMessageTableData,
    $$ChatMessageTableTableFilterComposer,
    $$ChatMessageTableTableOrderingComposer,
    $$ChatMessageTableTableAnnotationComposer,
    $$ChatMessageTableTableCreateCompanionBuilder,
    $$ChatMessageTableTableUpdateCompanionBuilder,
    (
      ChatMessageTableData,
      BaseReferences<_$AppDatabase, $ChatMessageTableTable,
          ChatMessageTableData>
    ),
    ChatMessageTableData,
    PrefetchHooks Function()>;
typedef $$FeedbackLocalTableTableCreateCompanionBuilder
    = FeedbackLocalTableCompanion Function({
  required String id,
  required int rating,
  required String impression,
  required String suggestion,
  required String createdAt,
  required String updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$FeedbackLocalTableTableUpdateCompanionBuilder
    = FeedbackLocalTableCompanion Function({
  Value<String> id,
  Value<int> rating,
  Value<String> impression,
  Value<String> suggestion,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> syncState,
  Value<int> rowid,
});

class $$FeedbackLocalTableTableFilterComposer
    extends Composer<_$AppDatabase, $FeedbackLocalTableTable> {
  $$FeedbackLocalTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get impression => $composableBuilder(
      column: $table.impression, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get suggestion => $composableBuilder(
      column: $table.suggestion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));
}

class $$FeedbackLocalTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FeedbackLocalTableTable> {
  $$FeedbackLocalTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get impression => $composableBuilder(
      column: $table.impression, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get suggestion => $composableBuilder(
      column: $table.suggestion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));
}

class $$FeedbackLocalTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeedbackLocalTableTable> {
  $$FeedbackLocalTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get impression => $composableBuilder(
      column: $table.impression, builder: (column) => column);

  GeneratedColumn<String> get suggestion => $composableBuilder(
      column: $table.suggestion, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$FeedbackLocalTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FeedbackLocalTableTable,
    FeedbackLocalTableData,
    $$FeedbackLocalTableTableFilterComposer,
    $$FeedbackLocalTableTableOrderingComposer,
    $$FeedbackLocalTableTableAnnotationComposer,
    $$FeedbackLocalTableTableCreateCompanionBuilder,
    $$FeedbackLocalTableTableUpdateCompanionBuilder,
    (
      FeedbackLocalTableData,
      BaseReferences<_$AppDatabase, $FeedbackLocalTableTable,
          FeedbackLocalTableData>
    ),
    FeedbackLocalTableData,
    PrefetchHooks Function()> {
  $$FeedbackLocalTableTableTableManager(
      _$AppDatabase db, $FeedbackLocalTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedbackLocalTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedbackLocalTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedbackLocalTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> rating = const Value.absent(),
            Value<String> impression = const Value.absent(),
            Value<String> suggestion = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FeedbackLocalTableCompanion(
            id: id,
            rating: rating,
            impression: impression,
            suggestion: suggestion,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int rating,
            required String impression,
            required String suggestion,
            required String createdAt,
            required String updatedAt,
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FeedbackLocalTableCompanion.insert(
            id: id,
            rating: rating,
            impression: impression,
            suggestion: suggestion,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: syncState,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$FeedbackLocalTableTable,
                        FeedbackLocalTableData>(table),
                    BaseReferences<_$AppDatabase, $FeedbackLocalTableTable,
                        FeedbackLocalTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FeedbackLocalTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FeedbackLocalTableTable,
    FeedbackLocalTableData,
    $$FeedbackLocalTableTableFilterComposer,
    $$FeedbackLocalTableTableOrderingComposer,
    $$FeedbackLocalTableTableAnnotationComposer,
    $$FeedbackLocalTableTableCreateCompanionBuilder,
    $$FeedbackLocalTableTableUpdateCompanionBuilder,
    (
      FeedbackLocalTableData,
      BaseReferences<_$AppDatabase, $FeedbackLocalTableTable,
          FeedbackLocalTableData>
    ),
    FeedbackLocalTableData,
    PrefetchHooks Function()>;
typedef $$FavoriteMosqueTableTableCreateCompanionBuilder
    = FavoriteMosqueTableCompanion Function({
  required String id,
  required String osmId,
  required String name,
  required double lat,
  required double lon,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$FavoriteMosqueTableTableUpdateCompanionBuilder
    = FavoriteMosqueTableCompanion Function({
  Value<String> id,
  Value<String> osmId,
  Value<String> name,
  Value<double> lat,
  Value<double> lon,
  Value<String> syncState,
  Value<int> rowid,
});

class $$FavoriteMosqueTableTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteMosqueTableTable> {
  $$FavoriteMosqueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get osmId => $composableBuilder(
      column: $table.osmId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lon => $composableBuilder(
      column: $table.lon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));
}

class $$FavoriteMosqueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteMosqueTableTable> {
  $$FavoriteMosqueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get osmId => $composableBuilder(
      column: $table.osmId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lon => $composableBuilder(
      column: $table.lon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));
}

class $$FavoriteMosqueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteMosqueTableTable> {
  $$FavoriteMosqueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get osmId =>
      $composableBuilder(column: $table.osmId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$FavoriteMosqueTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FavoriteMosqueTableTable,
    FavoriteMosqueTableData,
    $$FavoriteMosqueTableTableFilterComposer,
    $$FavoriteMosqueTableTableOrderingComposer,
    $$FavoriteMosqueTableTableAnnotationComposer,
    $$FavoriteMosqueTableTableCreateCompanionBuilder,
    $$FavoriteMosqueTableTableUpdateCompanionBuilder,
    (
      FavoriteMosqueTableData,
      BaseReferences<_$AppDatabase, $FavoriteMosqueTableTable,
          FavoriteMosqueTableData>
    ),
    FavoriteMosqueTableData,
    PrefetchHooks Function()> {
  $$FavoriteMosqueTableTableTableManager(
      _$AppDatabase db, $FavoriteMosqueTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteMosqueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteMosqueTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteMosqueTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> osmId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> lat = const Value.absent(),
            Value<double> lon = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FavoriteMosqueTableCompanion(
            id: id,
            osmId: osmId,
            name: name,
            lat: lat,
            lon: lon,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String osmId,
            required String name,
            required double lat,
            required double lon,
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FavoriteMosqueTableCompanion.insert(
            id: id,
            osmId: osmId,
            name: name,
            lat: lat,
            lon: lon,
            syncState: syncState,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$FavoriteMosqueTableTable,
                        FavoriteMosqueTableData>(table),
                    BaseReferences<_$AppDatabase, $FavoriteMosqueTableTable,
                        FavoriteMosqueTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FavoriteMosqueTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FavoriteMosqueTableTable,
    FavoriteMosqueTableData,
    $$FavoriteMosqueTableTableFilterComposer,
    $$FavoriteMosqueTableTableOrderingComposer,
    $$FavoriteMosqueTableTableAnnotationComposer,
    $$FavoriteMosqueTableTableCreateCompanionBuilder,
    $$FavoriteMosqueTableTableUpdateCompanionBuilder,
    (
      FavoriteMosqueTableData,
      BaseReferences<_$AppDatabase, $FavoriteMosqueTableTable,
          FavoriteMosqueTableData>
    ),
    FavoriteMosqueTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LedgerLocalTableTableTableManager get ledgerLocalTable =>
      $$LedgerLocalTableTableTableManager(_db, _db.ledgerLocalTable);
  $$OutboxTableTableTableManager get outboxTable =>
      $$OutboxTableTableTableManager(_db, _db.outboxTable);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
  $$PrayerCacheTableTableTableManager get prayerCacheTable =>
      $$PrayerCacheTableTableTableManager(_db, _db.prayerCacheTable);
  $$RateCacheTableTableTableManager get rateCacheTable =>
      $$RateCacheTableTableTableManager(_db, _db.rateCacheTable);
  $$DonationLocalTableTableTableManager get donationLocalTable =>
      $$DonationLocalTableTableTableManager(_db, _db.donationLocalTable);
  $$TasbihLogTableTableTableManager get tasbihLogTable =>
      $$TasbihLogTableTableTableManager(_db, _db.tasbihLogTable);
  $$QuizAttemptTableTableTableManager get quizAttemptTable =>
      $$QuizAttemptTableTableTableManager(_db, _db.quizAttemptTable);
  $$QuizQuestionTableTableTableManager get quizQuestionTable =>
      $$QuizQuestionTableTableTableManager(_db, _db.quizQuestionTable);
  $$ChatMessageTableTableTableManager get chatMessageTable =>
      $$ChatMessageTableTableTableManager(_db, _db.chatMessageTable);
  $$FeedbackLocalTableTableTableManager get feedbackLocalTable =>
      $$FeedbackLocalTableTableTableManager(_db, _db.feedbackLocalTable);
  $$FavoriteMosqueTableTableTableManager get favoriteMosqueTable =>
      $$FavoriteMosqueTableTableTableManager(_db, _db.favoriteMosqueTable);
}
