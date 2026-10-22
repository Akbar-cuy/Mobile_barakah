// Provider untuk menyimpan state halaman Beranda.
// Setiap kali data berubah, kita panggil notifyListeners()
// supaya layar ikut diperbarui.

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/prayer_times.dart';
import '../repository/prayer_repository.dart';
import '../services/prayer_time_service.dart';

class HomeProvider extends ChangeNotifier {
  final PrayerRepository _repository = PrayerRepository();
  final PrayerTimeService _service = PrayerTimeService();

  // ----- Data yang dibaca oleh layar -----
  bool isLoading = false;
  String? errorMessage;
  PrayerTimes? times;
  String selectedZone = 'WIB';
  NextPrayer? nextPrayer;
  String countdown = '00:00:00';

  Timer? _timer;

  // Daftar nama zona untuk chip: WIB, WITA, WIT, London
  List<String> get zoneNames => _service.zones.keys.toList();

  // Apakah zona yang dipilih berbeda dari zona perangkat?
  bool get isOtherZone => _service.isOtherZone(selectedZone);

  // ----- Fungsi yang dipanggil oleh layar -----

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      times = await _repository.getTodayTimes();
      _startTimer();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    isLoading = false;
    notifyListeners();
  }

  void changeZone(String zone) {
    selectedZone = zone;
    notifyListeners();
  }

  // Mengubah jam sesuai zona yang dipilih.
  String showTime(String time) {
    return _service.convertZone(time, selectedZone);
  }

  // ----- Hitung mundur -----

  void _startTimer() {
    _timer?.cancel();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
      notifyListeners();
    });
  }

  void _updateCountdown() {
    if (times == null) return;

    nextPrayer = _service.getNextPrayer(times!);
    Duration diff = nextPrayer!.time.difference(DateTime.now());

    String hours = diff.inHours.toString().padLeft(2, '0');
    String minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    countdown = '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}