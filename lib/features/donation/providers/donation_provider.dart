import 'package:flutter/material.dart';

import '../../converter/repository/rate_repository.dart';
import '../../converter/services/currency_service.dart';
import '../models/donation_models.dart';
import '../repository/donation_repository.dart';
import '../services/zakat_calculator.dart';

// State untuk layar Zakat dan Donasi
class DonationProvider extends ChangeNotifier {
  final DonationRepository _repository = DonationRepository.instance;
  final RateRepository _rateRepository = RateRepository();
  final CurrencyService _currencyService = CurrencyService();
  final ZakatCalculator _calculator = ZakatCalculator();

  bool _disposed = false;

  // ---------- Data umum ----------
  bool loading = true;
  bool saving = false;
  RateData? rates;

  // ---------- Kampanye dan donasi ----------
  List<Campaign> campaigns = [];
  String searchText = '';
  String category = 'Semua';
  Campaign? selectedCampaign;

  String amountText = '';
  String currency = 'IDR';
  String donorAlias = 'Hamba Allah';
  bool submitted = false; // true setelah pengguna menekan konfirmasi

  // ---------- Zakat ----------
  String zakatType = 'maal'; // 'maal' atau 'fitrah'
  String zakatInputText = '';
  String zakatCurrency = 'IDR';
  ZakatResult? zakatResult;
  String? zakatError;

  DonationProvider() {
    _load();
  }

  // Cegah notifyListeners dipanggil setelah provider dibuang
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> _load() async {
    campaigns = await _repository.getCampaigns();
    rates = await _rateRepository.getRates();
    if (campaigns.isNotEmpty) selectedCampaign = campaigns.first;
    loading = false;
    notifyListeners();
  }

  String formatMoney(double value, String currencyCode) {
    return _currencyService.format(value, currencyCode);
  }

  // =====================================================
  // Kampanye
  // =====================================================

  List<String> get categories {
    final set = <String>{};
    for (final c in campaigns) {
      set.add(c.category);
    }
    return ['Semua', ...set];
  }

  List<Campaign> get filteredCampaigns {
    final q = searchText.trim().toLowerCase();
    return campaigns.where((c) {
      final matchCategory = category == 'Semua' || c.category == category;
      final matchText = q.isEmpty ||
          c.title.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q);
      return matchCategory && matchText;
    }).toList();
  }

  void setSearch(String text) {
    searchText = text;
    notifyListeners();
  }

  void setCategory(String value) {
    category = value;
    notifyListeners();
  }

  void selectCampaign(Campaign campaign) {
    selectedCampaign = campaign;
    notifyListeners();
  }

  // =====================================================
  // Donasi
  // =====================================================

  String? get amountError => _currencyService.validateAmount(amountText);

  // Pesan galat baru ditampilkan setelah pengguna mulai mengetik
  // atau menekan konfirmasi
  bool get showAmountError => amountText.isNotEmpty || submitted;

  List<Donation> get donations => _repository.donations;

  // Padanan nominal pada dua mata uang lain
  List<MapEntry<String, String>> get equivalents {
    final amount = _currencyService.parseAmount(amountText);
    final data = rates;
    if (amount == null || amountError != null || data == null) return [];

    final list = <MapEntry<String, String>>[];
    for (final c in currencyList) {
      if (c == currency) continue;
      final value = _currencyService.convert(amount, currency, c, data.perUsd);
      list.add(MapEntry(c, _currencyService.format(value, c)));
    }
    return list;
  }

  void setAmount(String text) {
    amountText = text;
    notifyListeners();
  }

  void setCurrency(String value) {
    currency = value;
    notifyListeners();
  }

  void setAlias(String text) {
    donorAlias = text.trim().isEmpty ? 'Hamba Allah' : text.trim();
    notifyListeners();
  }

  // Konfirmasi donasi. Mengembalikan donasi bila berhasil, null bila gagal.
  Future<Donation?> confirmDonation() async {
    submitted = true;
    final amount = _currencyService.parseAmount(amountText);
    final data = rates;
    final campaign = selectedCampaign;

    if (amountError != null ||
        amount == null ||
        data == null ||
        campaign == null) {
      notifyListeners();
      return null;
    }

    saving = true;
    notifyListeners();

    final rate = currency == 'IDR'
        ? 1.0
        : _currencyService.convert(1, currency, 'IDR', data.perUsd);

    final donation = await _repository.saveDonation(
      campaignTitle: campaign.title,
      donorAlias: donorAlias,
      amount: amount,
      currency: currency,
      amountIdr: amount * rate,
      rateUsed: rate,
    );

    saving = false;
    submitted = false;
    amountText = '';
    notifyListeners();
    return donation;
  }

  // =====================================================
  // Zakat
  // =====================================================

  double get goldPricePerGram => _calculator.goldPricePerGramIdr;
  double get fitrahPerPerson => _calculator.fitrahPerPersonIdr;

  String get nisabText => _currencyService.format(_calculator.nisabIdr, 'IDR');

  void setZakatType(String type) {
    zakatType = type;
    zakatInputText = '';
    zakatResult = null;
    zakatError = null;
    notifyListeners();
  }

  void setZakatInput(String text) {
    zakatInputText = text;
    zakatResult = null;
    zakatError = null;
    notifyListeners();
  }

  void setZakatCurrency(String value) {
    zakatCurrency = value;
    zakatResult = null;
    notifyListeners();
  }

  // Ubah harga emas per gram (rupiah)
  void setGoldPrice(String text) {
    final value = double.tryParse(text.trim());
    if (value != null && value > 0) {
      _calculator.goldPricePerGramIdr = value;
      zakatResult = null;
      notifyListeners();
    }
  }

  // Ubah nilai zakat fitrah per jiwa (rupiah)
  void setFitrahValue(String text) {
    final value = double.tryParse(text.trim());
    if (value != null && value > 0) {
      _calculator.fitrahPerPersonIdr = value;
      zakatResult = null;
      notifyListeners();
    }
  }

  void calculateZakat() {
    zakatResult = null;
    zakatError = null;
    final data = rates;

    if (data == null) {
      zakatError = 'Kurs belum tersedia. Coba lagi sebentar.';
      notifyListeners();
      return;
    }

    if (zakatType == 'maal') {
      final error = _currencyService.validateAmount(zakatInputText);
      final wealth = _currencyService.parseAmount(zakatInputText);
      if (error != null || wealth == null) {
        zakatError = error;
        notifyListeners();
        return;
      }
      final wealthIdr = zakatCurrency == 'IDR'
          ? wealth
          : _currencyService.convert(wealth, zakatCurrency, 'IDR', data.perUsd);
      zakatResult = _calculator.calculateMaal(wealthIdr);
    } else {
      final persons = int.tryParse(zakatInputText.trim());
      if (persons == null || persons <= 0) {
        zakatError = 'Jumlah jiwa harus berupa angka lebih dari nol.';
        notifyListeners();
        return;
      }
      zakatResult = _calculator.calculateFitrah(persons);
    }
    notifyListeners();
  }

  // Hasil zakat dalam tiga mata uang. Mata uang input tampil paling atas.
  List<MapEntry<String, String>> get zakatAmounts {
    final result = zakatResult;
    final data = rates;
    if (result == null || data == null || !result.wajib) return [];

    final base = zakatType == 'maal' ? zakatCurrency : 'IDR';
    final order = [base, ...currencyList.where((c) => c != base)];

    final list = <MapEntry<String, String>>[];
    for (final c in order) {
      final value = c == 'IDR'
          ? result.resultIdr
          : _currencyService.convert(result.resultIdr, 'IDR', c, data.perUsd);
      list.add(MapEntry(c, _currencyService.format(value, c)));
    }
    return list;
  }

  // Bayar zakat (simulasi): dicatat sebagai donasi dalam rupiah
  Future<Donation?> donateZakat() async {
    final result = zakatResult;
    if (result == null || !result.wajib) return null;

    saving = true;
    notifyListeners();

    final amount = result.resultIdr.roundToDouble();
    final donation = await _repository.saveDonation(
      campaignTitle: zakatType == 'maal' ? 'Zakat Maal' : 'Zakat Fitrah',
      donorAlias: donorAlias,
      amount: amount,
      currency: 'IDR',
      amountIdr: amount,
      rateUsed: 1,
    );

    saving = false;
    notifyListeners();
    return donation;
  }
}