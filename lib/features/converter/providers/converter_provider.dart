import 'package:flutter/material.dart';

import '../repository/rate_repository.dart';
import '../services/currency_service.dart';
import '../services/timezone_service.dart';

// Menyimpan state layar Konversi (tab Waktu dan tab Mata Uang)
class ConverterProvider extends ChangeNotifier {
  final TimezoneService _timezoneService = TimezoneService();
  final CurrencyService _currencyService = CurrencyService();
  final RateRepository _rateRepository = RateRepository();

  // ---------- State tab Waktu ----------
  TimeOfDay time = const TimeOfDay(hour: 11, minute: 45);
  ZoneInfo fromZone = zoneList[0]; // WIB

  // ---------- State tab Mata Uang ----------
  String amountText = '100';
  String fromCurrency = 'USD';
  String toCurrency = 'IDR';
  RateData? rates;
  bool loadingRates = false;

  ConverterProvider() {
    loadRates();
  }

  // ---------- Waktu ----------
  String get timeText => _timezoneService.formatTime(time.hour, time.minute);

  List<TimeResult> get timeResults {
    return _timezoneService.convertTime(
      hour: time.hour,
      minute: time.minute,
      from: fromZone,
    );
  }

  void setTime(TimeOfDay value) {
    time = value;
    notifyListeners();
  }

  void setFromZone(ZoneInfo value) {
    fromZone = value;
    notifyListeners();
  }

  // ---------- Mata uang ----------
  Future<void> loadRates() async {
    loadingRates = true;
    notifyListeners();
    rates = await _rateRepository.getRates();
    loadingRates = false;
    notifyListeners();
  }

  String? get amountError => _currencyService.validateAmount(amountText);

  String get ratesLabel {
    if (rates == null) return '';
    return _currencyService.ratesLabel(rates!.updatedAt);
  }

  // Hasil konversi ke semua mata uang: pasangan (kode, teks hasil)
  List<MapEntry<String, String>> get currencyResults {
    final data = rates;
    final amount = _currencyService.parseAmount(amountText);
    if (data == null || amountError != null || amount == null) return [];

    final list = <MapEntry<String, String>>[];
    for (final c in currencyList) {
      final value =
          _currencyService.convert(amount, fromCurrency, c, data.perUsd);
      list.add(MapEntry(c, _currencyService.format(value, c)));
    }
    return list;
  }

  void setAmount(String text) {
    amountText = text;
    notifyListeners();
  }

  void setFromCurrency(String value) {
    fromCurrency = value;
    notifyListeners();
  }

  void setToCurrency(String value) {
    toCurrency = value;
    notifyListeners();
  }

  // Tukar posisi mata uang asal dan tujuan
  void swapCurrency() {
    final temp = fromCurrency;
    fromCurrency = toCurrency;
    toCurrency = temp;
    notifyListeners();
  }
}