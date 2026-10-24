import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../converter/repository/rate_repository.dart';
import '../../converter/services/currency_service.dart';
import '../models/donation_models.dart';
import '../repository/donation_repository.dart';
import '../services/zakat_calculator.dart';

// State untuk layar Zakat dan Donasi
class DonationProvider extends ChangeNotifier {
  DonationProvider({
    required DonationRepository repository,
    required RateRepository rateRepository,
  })  : _repository = repository,
        _rateRepository = rateRepository {
    _load();
  }

  final DonationRepository _repository;
  final RateRepository _rateRepository;
  final CurrencyService _currencyService = CurrencyService();
  final ZakatCalculator _calculator = ZakatCalculator();

  bool _disposed = false;
  bool _loadRunning = false;

  // ---------- Data umum ----------
  bool loading = true;
  bool saving = false;
  String? campaignsError;
  String? ratesError;
  String? submitError;
  RateData? rates;

  // ---------- Kampanye dan donasi ----------
  List<Campaign> campaigns = [];
  List<Donation> donations = [];
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
    if (_disposed || _loadRunning) return;
    _loadRunning = true;
    loading = true;
    campaignsError = null;
    notifyListeners();
    try {
      campaigns = await _repository.getCampaigns();
      if (selectedCampaign == null ||
          !campaigns.any((campaign) => campaign.id == selectedCampaign!.id)) {
        selectedCampaign = campaigns.isEmpty ? null : campaigns.first;
      }
    } catch (error) {
      campaignsError = _errorMessage(error, 'Kampanye gagal dimuat.');
    }
    try {
      rates = await _rateRepository.getRates();
      ratesError = rates == null ? 'Kurs belum tersedia.' : null;
    } catch (error) {
      ratesError = _errorMessage(error, 'Kurs gagal dimuat.');
    }
    try {
      donations = await _repository.getDonations();
    } catch (_) {
      // Riwayat tidak boleh menghalangi pengguna melihat atau membuat donasi.
    }
    loading = false;
    _loadRunning = false;
    notifyListeners();
  }

  Future<void> refresh() => _load();

  String _errorMessage(Object error, String fallback) =>
      error is ApiException ? error.message : fallback;

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

  String? get amountError {
    final basicError = _currencyService.validateAmount(amountText);
    if (basicError != null) return basicError;
    final normalized = amountText.trim().replaceAll(',', '.');
    if (!RegExp(r'^(?:0|[1-9]\d*)(?:\.\d+)?$').hasMatch(normalized)) {
      return 'Nominal harus berupa angka desimal yang valid.';
    }
    final amount = double.parse(normalized);
    if (amount > DonationRepository.maxAmountIdr) {
      return 'Nominal terlalu besar.';
    }
    if (currency == 'IDR' &&
        normalized.contains('.') &&
        normalized.split('.').last.replaceAll('0', '').isNotEmpty) {
      return 'Nominal IDR harus berupa bilangan bulat.';
    }
    if (currency != 'IDR' &&
        normalized.contains('.') &&
        normalized.split('.').last.length > 2) {
      return 'Maksimal dua angka di belakang koma.';
    }
    return null;
  }

  // Pesan galat baru ditampilkan setelah pengguna mulai mengetik
  // atau menekan konfirmasi
  bool get showAmountError => amountText.isNotEmpty || submitted;

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
    if (saving) return null;
    submitted = true;
    submitError = null;
    final amount = _currencyService.parseAmount(amountText);
    final data = rates;
    final campaign = selectedCampaign;

    if (amountError != null ||
        amount == null ||
        (currency != 'IDR' && data == null) ||
        campaign == null) {
      notifyListeners();
      return null;
    }

    final rate = currency == 'IDR'
        ? 1.0
        : _currencyService.convert(1, currency, 'IDR', data!.perUsd);
    final amountIdr = (amount * rate).roundToDouble();
    if (!rate.isFinite ||
        rate <= 0 ||
        !amountIdr.isFinite ||
        amountIdr <= 0 ||
        amountIdr > DonationRepository.maxAmountIdr) {
      submitError = 'Nominal setara rupiah berada di luar batas.';
      submitted = false;
      notifyListeners();
      return null;
    }

    saving = true;
    notifyListeners();
    try {
      final donation = await _repository.saveDonation(
        campaign: campaign,
        campaignTitle: campaign.title,
        donorAlias: donorAlias,
        amount: amount,
        currency: currency,
        amountIdr: amountIdr,
        rateUsed: rate,
      );
      donations = [...donations, donation];
      amountText = '';
      submitted = false;
      return donation;
    } catch (error) {
      submitError = _errorMessage(error, 'Donasi gagal disimpan. Coba lagi.');
      return null;
    } finally {
      saving = false;
      notifyListeners();
    }
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
    if (saving) return null;
    final result = zakatResult;
    if (result == null || !result.wajib) return null;

    final amount = result.resultIdr.roundToDouble();
    if (!amount.isFinite ||
        amount <= 0 ||
        amount > DonationRepository.maxAmountIdr) {
      submitError = 'Nominal zakat berada di luar batas.';
      notifyListeners();
      return null;
    }
    saving = true;
    submitError = null;
    notifyListeners();
    try {
      final donation = await _repository.saveDonation(
        campaign: null,
        campaignTitle: zakatType == 'maal' ? 'Zakat Maal' : 'Zakat Fitrah',
        donorAlias: donorAlias,
        amount: amount,
        currency: 'IDR',
        amountIdr: amount,
        rateUsed: 1,
      );
      donations = [...donations, donation];
      return donation;
    } catch (error) {
      submitError = _errorMessage(error, 'Donasi zakat gagal disimpan.');
      return null;
    } finally {
      saving = false;
      notifyListeners();
    }
  }
}
