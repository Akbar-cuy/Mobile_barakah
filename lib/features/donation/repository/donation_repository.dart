import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/donation_models.dart';

// Sumber data kampanye dan penyimpanan donasi.
// Sementara semuanya di memori. Nanti diganti:
// - kampanye dari endpoint /campaigns
// - donasi dan blok ke SQLite + sinkronisasi ke server (modul ledger)
class DonationRepository {
  DonationRepository._();

  // Satu instance dipakai bersama supaya riwayat tidak hilang
  // saat layar ditutup dan dibuka lagi.
  static final DonationRepository instance = DonationRepository._();

  final List<Donation> _donations = [];

  // Blok pertama memakai prev_hash berisi nol (dianggap blok genesis)
  String _lastHash = '0' * 64;

  // TODO: ambil user_id dari sesi login
  final String _userId = 'user-lokal';

  List<Donation> get donations => List.unmodifiable(_donations);

  // ---------- Kampanye ----------

  Future<List<Campaign>> getCampaigns() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      Campaign(
        id: 'bebas',
        title: 'Donasi Bebas',
        description: 'Donasi umum tanpa kampanye tertentu',
        category: 'Umum',
        targetIdr: 0,
      ),
      Campaign(
        id: 'air',
        title: 'Air Bersih Pelosok',
        description: 'Pembangunan sumur dan saluran air desa',
        category: 'Air',
        targetIdr: 50000000,
      ),
      Campaign(
        id: 'musholla',
        title: 'Renovasi Musholla',
        description: 'Perbaikan atap dan tempat wudhu musholla',
        category: 'Masjid',
        targetIdr: 30000000,
      ),
      Campaign(
        id: 'beasiswa',
        title: 'Beasiswa Santri',
        description: 'Biaya pendidikan santri kurang mampu',
        category: 'Pendidikan',
        targetIdr: 40000000,
      ),
    ];
  }

  // ---------- Donasi ----------

  // Simpan donasi sebagai blok baru (hash berantai + proof of work "000").
  // Pencarian nonce ringan (rata-rata ribuan percobaan) sehingga cukup di sini.
  // PRD meminta berjalan di isolate, bisa dipindah nanti saat modul ledger dibuat.
  Future<Donation> saveDonation({
    required String campaignTitle,
    required String donorAlias,
    required double amount,
    required String currency,
    required double amountIdr,
    required double rateUsed,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _donations.length + 1;
    final createdAt = DateTime.now().toUtc();
    final prevHash = _lastHash;

    String makeHash(int nonce) {
      final text = '$index|${createdAt.toIso8601String()}|$_userId|'
          '$donorAlias|$campaignTitle|$amount|$currency|$amountIdr|'
          '$rateUsed|$prevHash|$nonce';
      return sha256.convert(utf8.encode(text)).toString();
    }

    int nonce = 0;
    String hash = makeHash(nonce);
    while (!hash.startsWith('000')) {
      nonce++;
      hash = makeHash(nonce);
    }

    final donation = Donation(
      // TODO: pakai UUID sungguhan agar pengiriman ulang tidak duplikat
      id: createdAt.microsecondsSinceEpoch.toString(),
      campaignTitle: campaignTitle,
      donorAlias: donorAlias,
      amount: amount,
      currency: currency,
      amountIdr: amountIdr,
      rateUsed: rateUsed,
      createdAt: createdAt,
      blockIndex: index,
      prevHash: prevHash,
      nonce: nonce,
      hash: hash,
    );

    _donations.add(donation);
    _lastHash = hash;
    return donation;
  }
}
