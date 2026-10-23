// M16 Notifikasi (FR-NTF-01..05). Pure scheduling logic, independent of plugins.
import '../../../core/config/app_config.dart';
import 'notification_prefs.dart';

class PrayerDay {
  const PrayerDay({
    required this.date,
    required this.times,
    required this.utcOffsetMinutes,
  });

  /// Local prayer date in yyyy-MM-dd format.
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

  /// Scheduled instant in UTC.
  final DateTime when;
  final PlannedKind kind;
  final String title;
  final String body;
  final PrayerSlot? slot;
}

abstract final class PrayerScheduler {
  static List<PlannedNotification> plan({
    required List<PrayerDay> days,
    required NotificationPrefs prefs,
    required DateTime now,
    int maxItems = 60,
  }) {
    final planned = <PlannedNotification>[];
    final nowUtc = now.toUtc();

    for (final day in days) {
      final date = _parseDate(day.date);
      if (date == null) continue;
      final dayIndex =
          date.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

      for (final slot in PrayerSlot.values) {
        if (!prefs.isOn(slot)) continue;
        final time = parseTime(day.times[slot]);
        if (time == null) continue;
        final prayerUtc = date
            .add(Duration(hours: time.$1, minutes: time.$2))
            .subtract(Duration(minutes: day.utcOffsetMinutes));
        planned.add(
          PlannedNotification(
            id: notificationId(dayIndex, slot.index, 0),
            when: prayerUtc,
            kind: PlannedKind.adhan,
            slot: slot,
            title: 'Waktu ${slot.label}',
            body: 'Telah masuk waktu sholat ${slot.label}.',
          ),
        );
        if (prefs.reminderMinutes > 0) {
          planned.add(
            PlannedNotification(
              id: notificationId(dayIndex, slot.index, 1),
              when: prayerUtc.subtract(
                Duration(minutes: prefs.reminderMinutes),
              ),
              kind: PlannedKind.reminder,
              slot: slot,
              title: '${slot.label} ${prefs.reminderMinutes} menit lagi',
              body: 'Bersiaplah untuk sholat ${slot.label}.',
            ),
          );
        }
      }
    }

    if (prefs.dhikrEnabled) {
      final today = DateTime(now.year, now.month, now.day);
      for (var dayOffset = 0;
          dayOffset < AppConfig.prayerWindowDays;
          dayOffset++) {
        final scheduled = DateTime(
          today.year,
          today.month,
          today.day + dayOffset,
          prefs.dhikrHour,
          prefs.dhikrMinute,
        );
        final dayIndex = DateTime.utc(
              scheduled.year,
              scheduled.month,
              scheduled.day,
            ).millisecondsSinceEpoch ~/
            Duration.millisecondsPerDay;
        planned.add(
          PlannedNotification(
            id: notificationId(dayIndex, 9, 0),
            when: scheduled.toUtc(),
            kind: PlannedKind.dhikr,
            title: 'Waktunya berdzikir',
            body: 'Luangkan sebentar untuk dzikir hari ini.',
          ),
        );
      }
    }

    final upcoming = planned.where((item) => item.when.isAfter(nowUtc)).toList()
      ..sort((a, b) => a.when.compareTo(b.when));
    return upcoming.length <= maxItems
        ? upcoming
        : upcoming.sublist(0, maxItems);
  }

  /// Stable per-day IDs prevent duplicates when the schedule is refreshed.
  static int notificationId(int dayIndex, int slot, int kind) =>
      dayIndex * 100 + slot * 10 + kind;

  static (int, int)? parseTime(String? raw) {
    if (raw == null) return null;
    final match = RegExp(r'^\s*(\d{1,2})[:.](\d{2})').firstMatch(raw);
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) return null;
    return (hour, minute);
  }

  static DateTime? _parseDate(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(value);
    if (match == null) return null;
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final date = DateTime.utc(year, month, day);
    if (date.year != year || date.month != month || date.day != day) return null;
    return date;
  }
}
