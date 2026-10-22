// M14 Notifikasi Adzan. Nama provider dipakai juga oleh main.dart.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../home/providers/home_provider.dart';
import '../services/notification_service.dart';
import '../services/prayer_scheduler.dart';

final notificationServiceProvider =
    Provider<NotificationGateway>((ref) => LocalNotificationGateway());

final notificationSettingsStoreProvider = Provider<NotificationSettingsStore>(
  (ref) => NotificationSettingsStore(ref.watch(settingsDaoProvider)),
);

final prayerSchedulerProvider = Provider<PrayerScheduler>((ref) {
  return PrayerScheduler(
    gateway: ref.watch(notificationServiceProvider),
    repository: ref.watch(prayerRepositoryProvider),
    locations: ref.watch(locationStoreProvider),
  );
});

class NotificationSettingsController extends AsyncNotifier<NotificationSettings> {
  @override
  Future<NotificationSettings> build() {
    return ref.read(notificationSettingsStoreProvider).load();
  }

  /// Menyimpan pengaturan lalu menjadwalkan ulang. Mengembalikan false bila
  /// pengingat aktif tetapi izin notifikasi ditolak.
  Future<bool> updateSettings(NotificationSettings next) async {
    var permitted = true;
    if (next.enabled) {
      permitted = await ref.read(notificationServiceProvider).requestPermission();
    }
    await ref.read(notificationSettingsStoreProvider).save(next);
    state = AsyncData(next);
    await ref.read(prayerSchedulerProvider).reschedule(next);
    return permitted;
  }
}

final notificationSettingsProvider =
    AsyncNotifierProvider<NotificationSettingsController, NotificationSettings>(
  NotificationSettingsController.new,
);

/// Dipantau oleh layar Beranda. Setiap jadwal baru dimuat, pengingat dijadwalkan
/// ulang, dan izin notifikasi diminta satu kali.
final prayerAutoScheduleProvider = Provider<void>((ref) {
  ref.listen(homeProvider, (_, next) {
    final data = next.value;
    if (data == null) return;
    unawaited(_apply(ref, data));
  }, fireImmediately: true);
});

Future<void> _apply(Ref ref, HomeState data) async {
  try {
    final store = ref.read(notificationSettingsStoreProvider);
    final settings = await store.load();
    if (settings.enabled && !await store.permissionAsked()) {
      await store.markPermissionAsked();
      await ref.read(notificationServiceProvider).requestPermission();
    }
    await ref.read(prayerSchedulerProvider).reschedule(settings, days: data.days);
  } on Object {
    // Notifikasi tidak boleh menghentikan Beranda.
  }
}
