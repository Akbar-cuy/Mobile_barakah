import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../repository/rate_repository.dart';
import '../services/currency_service.dart';
import '../services/timezone_service.dart';

// Menyimpan state layar Konversi (tab Waktu dan tab Mata Uang)
class ConverterProvider extends ChangeNotifier {
  ConverterProvider({required RateRepository rateRepository})
      : _rateRepository = rateRepository {
    unawaited(loadRates());
  }

  final TimezoneService _timezoneService = TimezoneService();
  final CurrencyService _currencyService = CurrencyService();
  final RateRepository _rateRepository;
  bool _disposed = false;

  // ---------- State tab Waktu ----------
  TimeOfDay time = const TimeOfDay(hour: 11, minute: 45);
  ZoneInfo fromZone = zoneList[0]; // WIB

  // ---------- State tab Mata Uang ----------
  String amountText = '100';
  String fromCurrency = 'USD';
  String toCurrency = 'IDR';
  RateData? rates;
  bool loadingRates = false;
  String? ratesError;

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
    if (loadingRates || _disposed) return;
    loadingRates = true;
    ratesError = null;
    _notify();
    try {
      final loaded = await _rateRepository.getRates();
      if (loaded == null) {
        throw ApiException.of(
          ApiErrorKind.server,
          message: 'Kurs tidak tersedia saat ini. Silakan coba lagi.',
        );
      }
      rates = loaded;
    } catch (error) {
      ratesError = error is ApiException
          ? error.message
          : 'Kurs gagal dimuat. Periksa koneksi lalu coba lagi.';
    } finally {
      loadingRates = false;
      _notify();
    }
  }

  void retryRates() => unawaited(loadRates());

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  String? get amountError {
    final validation = _currencyService.validateAmount(amountText);
    if (validation != null) return validation;
    final amount = _currencyService.parseAmount(amountText)!;
    final data = rates;
    if (data == null) return null;
    for (final currency in currencyList) {
      if (!_currencyService
          .convert(amount, fromCurrency, currency, data.perUsd)
          .isFinite) {
        return 'Nominal terlalu besar untuk dikonversi.';
      }
    }
    return null;
  }

  String get ratesLabel {
    if (rates == null) return '';
    final label = _currencyService.ratesLabel(rates!.updatedAt);
    return rates!.isStale ? 'Kurs terakhir diketahui · $label' : label;
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
