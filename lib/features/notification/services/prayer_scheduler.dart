// M16 Notifikasi (FR-NTF-01..05). Logika murni: tanpa plugin, mudah diuji.
import '../../../core/config/app_config.dart';
import 'notification_prefs.dart';

/// Satu hari jadwal dari cache. Waktu berupa "HH:mm" atau "HH.mm" waktu
/// setempat lokasi, [utcOffsetMinutes] selisih zona lokasi terhadap UTC.
class PrayerDay {
  const PrayerDay({
    required this.date,
    required this.times,
    required this.utcOffsetMinutes,
  });

  /// yyyy-MM-dd
  final String date;
  final Map<PrayerSlot, String> times;
  final int utcOffsetMinutes;
}

enum PlannedKind { adhan, reminder, dhikr }

class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.when,
    required this.kind,
    required this.title,
    required this.body,
    this.slot,
  });

  final int id;

  /// Saat tampil, dalam UTC.
  final DateTime when;
  final PlannedKind kind;
  final String title;
  final String body;
  final PrayerSlot? slot;
}

abstract final class PrayerScheduler {
  /// Memetakan jadwal 7 hari ke daftar notifikasi mendatang. Notifikasi yang
  /// waktunya sudah lewat dibuang. Hasil diurutkan menurut waktu dan dibatasi
  /// [maxItems] (batas notifikasi terjadwal di iOS 64).
  static List<PlannedNotification> plan({
    required List<PrayerDay> days,
    required NotificationPrefs prefs,
    required DateTime now,
    int maxItems = 60,
  }) {
    final out = <PlannedNotification>[];
    final nowUtc = now.toUtc();

    for (final day in days) {
      final base = _parseDate(day.date);
      if (base == null) continue;
      final dayIndex = base.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

      for (final slot in PrayerSlot.values) {
        if (!prefs.isOn(slot)) continue;
        final hm = parseTime(day.times[slot]);
        if (hm == null) continue;
        final utc = base
            .add(Duration(hours: hm.$1, minutes: hm.$2))
            .subtract(Duration(minutes: day.utcOffsetMinutes));
        final id = notificationId(dayIndex, slot.index, 0);
        out.add(PlannedNotification(
          id: id,
          when: utc,
          kind: PlannedKind.adhan,
          slot: slot,
          title: 'Waktu ${slot.label}',
          body: 'Telah masuk waktu sholat ${slot.label}.',
        ));
        if (prefs.reminderMinutes > 0) {
          out.add(PlannedNotification(
            id: notificationId(dayIndex, slot.index, 1),
            when: utc.subtract(Duration(minutes: prefs.reminderMinutes)),
            kind: PlannedKind.reminder,
            slot: slot,
            title: '${slot.label} ${prefs.reminderMinutes} menit lagi',
            body: 'Bersiaplah untuk sholat ${slot.label}.',
          ));
        }
      }
    }

    if (prefs.dhikrEnabled) {
      // Dzikir harian mengikuti jam dinding perangkat, bukan zona lokasi jadwal.
      final today = DateTime(now.year, now.month, now.day);
      for (var i = 0; i < AppConfig.prayerWindowDays; i++) {
        final d = DateTime(today.year, today.month, today.day + i,
            prefs.dhikrHour, prefs.dhikrMinute);
        final dayIndex = DateTime.utc(d.year, d.month, d.day)
                .millisecondsSinceEpoch ~/
            Duration.millisecondsPerDay;
        out.add(PlannedNotification(
          id: notificationId(dayIndex, 9, 0),
          when: d.toUtc(),
          kind: PlannedKind.dhikr,
          title: 'Waktunya berdzikir',
          body: 'Luangkan sebentar untuk dzikir hari ini.',
        ));
      }
    }

    final upcoming = out.where((n) => n.when.isAfter(nowUtc)).toList()
      ..sort((a, b) => a.when.compareTo(b.when));
    return upcoming.length <= maxItems ? upcoming : upcoming.sublist(0, maxItems);
  }

  /// ID stabil per hari, waktu sholat, dan jenis sehingga penjadwalan ulang
  /// menimpa, bukan menggandakan. Muat dalam 32 bit.
  static int notificationId(int dayIndex, int slot, int kind) =>
      dayIndex * 100 + slot * 10 + kind;

  /// "05:03" atau "05.03" menjadi (5, 3). Null bila tidak valid.
  static (int, int)? parseTime(String? raw) {
    if (raw == null) return null;
    final m = RegExp(r'^\s*(\d{1,2})[:.](\d{2})').firstMatch(raw);
    if (m == null) return null;
    final h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    if (h > 23 || min > 59) return null;
    return (h, min);
  }

  static DateTime? _parseDate(String s) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(s);
    if (m == null) return null;
    return DateTime.utc(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
  }
}
