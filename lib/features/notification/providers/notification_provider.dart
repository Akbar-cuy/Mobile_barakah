// M16 Notifikasi (FR-NTF)
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../auth/models/session.dart';
import '../../auth/providers/session_provider.dart';
import '../../profile/providers/theme_provider.dart';
import '../services/notification_prefs.dart';
import '../services/notification_service.dart';
import '../services/prayer_scheduler.dart';

final notificationGatewayProvider = Provider<NotificationGateway>(
  (ref) => FlutterLocalNotificationsGateway(),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(ref.watch(notificationGatewayProvider)),
);

final notificationPrefsStoreProvider = Provider<NotificationPrefsStore>(
  (ref) => NotificationPrefsStore(
    ref.watch(syncedSettingsProvider),
    legacySettings: ref.watch(settingsDaoProvider),
  ),
);

class NotificationPrefsController extends Notifier<NotificationPrefs> {
  @override
  NotificationPrefs build() {
    unawaited(_load());
    return const NotificationPrefs();
  }

  Future<void> _load() async {
    try {
      state = await ref.read(notificationPrefsStoreProvider).read();
    } on Object catch (error, stackTrace) {
      debugPrint('Gagal memuat preferensi notifikasi: $error\n$stackTrace');
    }
  }

  Future<void> _update(NotificationPrefs next) async {
    await ref.read(notificationPrefsStoreProvider).save(next);
    state = next;
  }

  Future<void> setSlot(PrayerSlot slot, bool on) =>
      _update(state.copyWith(enabled: {...state.enabled, slot: on}));

  Future<void> setSound(NotificationSound sound) =>
      _update(state.copyWith(sound: sound));

  Future<void> setReminder(int minutes) =>
      _update(state.copyWith(reminderMinutes: minutes));

  Future<void> setDhikr(bool on) =>
      _update(state.copyWith(dhikrEnabled: on));

  Future<void> setDhikrTime(int hour, int minute) =>
      _update(state.copyWith(dhikrHour: hour, dhikrMinute: minute));

  Future<void> setNearMosque(bool on) =>
      _update(state.copyWith(nearMosque: on));
}

final notificationPrefsProvider =
    NotifierProvider<NotificationPrefsController, NotificationPrefs>(
  NotificationPrefsController.new,
);

/// Jadwal 7 hari ke depan dari cache, memakai satu lokasi/metode terbaru per hari.
final prayerDaysProvider = StreamProvider<List<PrayerDay>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final today = DateTimeUtils.dateKey(DateTime.now());
  final query = db.select(db.prayerCacheTable)
    ..where((table) => table.date.isBiggerOrEqualValue(today));
  return query.watch().map((rows) {
    final latest = <String, PrayerCacheTableData>{};
    for (final row in rows) {
      final current = latest[row.date];
      if (current == null || row.fetchedAt.isAfter(current.fetchedAt)) {
        latest[row.date] = row;
      }
    }
    return [
      for (final row in latest.values)
        PrayerDay(
          date: row.date,
          utcOffsetMinutes: row.utcOffsetMinutes,
          times: {
            PrayerSlot.fajr: row.fajr,
            PrayerSlot.dhuhr: row.dhuhr,
            PrayerSlot.asr: row.asr,
            PrayerSlot.maghrib: row.maghrib,
            PrayerSlot.isha: row.isha,
          },
        ),
    ];
  });
});

/// Rebuilds notifications when cached prayer times or preferences change and
/// clears account-specific notifications after logout.
final notificationRescheduleWatcherProvider = Provider<void>((ref) {
  Timer? debounce;

  void schedule() {
    debounce?.cancel();
    debounce = Timer(const Duration(seconds: 1), () async {
      final days = ref.read(prayerDaysProvider).value;
      if (days == null) return;
      try {
        await ref.read(notificationServiceProvider).reschedule(
              days: days,
              prefs: ref.read(notificationPrefsProvider),
            );
      } on Object catch (error, stackTrace) {
        debugPrint('Gagal menjadwalkan ulang notifikasi: $error\n$stackTrace');
      }
    });
  }

  ref.listen(notificationPrefsProvider, (_, __) => schedule());
  ref.listen(prayerDaysProvider, (_, __) => schedule());
  ref.listen(sessionProvider, (previous, next) {
    if (previous?.status != AuthStatus.unauthenticated &&
        next.status == AuthStatus.unauthenticated) {
      debounce?.cancel();
      unawaited(ref.read(notificationServiceProvider).cancelAll());
    }
  });
  ref.onDispose(() => debounce?.cancel());
  schedule();
});
