// M16 Notifikasi (FR-NTF)
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../auth/models/session.dart';
import '../../profile/providers/theme_provider.dart';
import '../../auth/providers/session_provider.dart';
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
  (ref) => NotificationPrefsStore(ref.watch(syncedSettingsProvider)),
);

class NotificationPrefsController extends Notifier<NotificationPrefs> {
  @override
  NotificationPrefs build() {
    unawaited(_load());
    return const NotificationPrefs();
  }

  Future<void> _load() async {
    final loaded = await ref.read(notificationPrefsStoreProvider).read();
    state = loaded;
  }

  Future<void> _update(NotificationPrefs next) async {
    state = next;
    await ref.read(notificationPrefsStoreProvider).save(next);
  }

  Future<void> setSlot(PrayerSlot slot, bool on) =>
      _update(state.copyWith(enabled: {...state.enabled, slot: on}));

  Future<void> setSound(NotificationSound s) => _update(state.copyWith(sound: s));

  Future<void> setReminder(int minutes) => _update(state.copyWith(reminderMinutes: minutes));

  Future<void> setDhikr(bool on) => _update(state.copyWith(dhikrEnabled: on));

  Future<void> setDhikrTime(int hour, int minute) =>
      _update(state.copyWith(dhikrHour: hour, dhikrMinute: minute));

  Future<void> setNearMosque(bool on) => _update(state.copyWith(nearMosque: on));
}

final notificationPrefsProvider =
    NotifierProvider<NotificationPrefsController, NotificationPrefs>(
  NotificationPrefsController.new,
);

/// Jadwal 7 hari ke depan dari cache. Bila satu tanggal punya beberapa baris
/// (lokasi atau metode berbeda), dipakai yang paling baru diambil.
final prayerDaysProvider = StreamProvider<List<PrayerDay>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final today = DateTimeUtils.dateKey(DateTime.now());
  final query = db.select(db.prayerCacheTable)
    ..where((t) => t.date.isBiggerOrEqualValue(today));
  return query.watch().map((rows) {
    final latest = <String, dynamic>{};
    for (final r in rows) {
      final cur = latest[r.date];
      if (cur == null || r.fetchedAt.isAfter(cur.fetchedAt)) latest[r.date] = r;
    }
    return [
      for (final r in latest.values)
        PrayerDay(
          date: r.date as String,
          utcOffsetMinutes: r.utcOffsetMinutes as int,
          times: {
            PrayerSlot.fajr: r.fajr as String,
            PrayerSlot.dhuhr: r.dhuhr as String,
            PrayerSlot.asr: r.asr as String,
            PrayerSlot.maghrib: r.maghrib as String,
            PrayerSlot.isha: r.isha as String,
          },
        ),
    ];
  });
});

/// Menjadwalkan ulang bila preferensi atau jadwal berubah, dan membatalkan
/// semuanya saat logout (FR-NTF-07). Aktifkan dengan `ref.watch` di shell.
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
      } catch (_) {
        // Dicoba lagi pada perubahan berikutnya.
      }
    });
  }

  ref.listen(notificationPrefsProvider, (_, __) => schedule());
  ref.listen(prayerDaysProvider, (_, __) => schedule());
  ref.listen(sessionProvider, (prev, next) {
    if (prev?.status != AuthStatus.unauthenticated &&
        next.status == AuthStatus.unauthenticated) {
      debounce?.cancel();
      unawaited(ref.read(notificationServiceProvider).cancelAll());
    }
  });
  ref.onDispose(() => debounce?.cancel());
  schedule();
});
