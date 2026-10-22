// M14 Notifikasi Adzan (FR-NTF-02). Menjadwalkan pengingat dari jadwal sholat.
import '../../home/models/prayer_times.dart';
import '../../home/repository/prayer_repository.dart';
import '../../home/services/location_service.dart';
import 'notification_service.dart';

class PrayerScheduler {
  PrayerScheduler({
    required this.gateway,
    required this.repository,
    required this.locations,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final NotificationGateway gateway;
  final PrayerRepository repository;
  final LocationStore locations;
  final DateTime Function() _now;

  /// Batas aman untuk iOS yang hanya menyimpan 64 notifikasi tertunda.
  static const maxScheduled = 60;

  /// Menjadwalkan ulang seluruh pengingat. Bila [days] kosong, memakai jadwal
  /// tersimpan di cache untuk lokasi terakhir. Mengembalikan jumlah yang dijadwalkan.
  Future<int> reschedule(
    NotificationSettings settings, {
    List<PrayerTimes>? days,
  }) async {
    await gateway.cancelAll();
    if (!settings.enabled || settings.prayers.isEmpty) return 0;

    var source = days;
    if (source == null) {
      final point = await locations.load();
      if (point == null) return 0;
      source = await repository.cachedDays(point);
    }

    final now = _now().toUtc();
    final ordered = [...source]..sort((a, b) => a.date.compareTo(b.date));
    var count = 0;
    for (final day in ordered) {
      for (final prayer in PrayerName.obligatory) {
        if (!settings.prayers.contains(prayer)) continue;
        final at = day.instant(prayer).subtract(Duration(minutes: settings.minutesBefore));
        if (!at.isAfter(now)) continue;
        if (count >= maxScheduled) return count;
        await gateway.schedule(
          id: count,
          title: settings.minutesBefore == 0
              ? 'Waktu ${prayer.label}'
              : 'Menjelang ${prayer.label}',
          body: settings.minutesBefore == 0
              ? 'Waktu sholat ${prayer.label} telah tiba (${day.times[prayer]}).'
              : '${prayer.label} dalam ${settings.minutesBefore} menit (${day.times[prayer]}).',
          at: at,
        );
        count++;
      }
    }
    return count;
  }
}
