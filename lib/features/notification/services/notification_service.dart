// M16 Notifikasi (FR-NTF-01, FR-NTF-06, FR-NTF-07)
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'notification_prefs.dart';
import 'prayer_scheduler.dart';

/// Pembungkus plugin agar logika di atasnya dapat diuji dengan gateway palsu.
abstract interface class NotificationGateway {
  Future<void> init();

  /// True bila izin notifikasi diberikan (Android 13+ meminta saat dijalankan).
  Future<bool> requestPermission();

  Future<bool> hasPermission();

  Future<void> cancelAll();

  Future<void> schedule(PlannedNotification n, NotificationSound sound);

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required NotificationSound sound,
  });
}

class FlutterLocalNotificationsGateway implements NotificationGateway {
  FlutterLocalNotificationsGateway([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  static const _adhanChannel = 'barakah_adhan';
  static const _reminderChannel = 'barakah_reminder';
  static const _dhikrChannel = 'barakah_dhikr';

  @override
  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  @override
  Future<bool> hasPermission() async => (await Permission.notification.status).isGranted;

  @override
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  @override
  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  NotificationDetails _details(PlannedKind kind, NotificationSound sound) {
    final silent = sound == NotificationSound.silent;
    final (id, name) = switch (kind) {
      PlannedKind.adhan => (_adhanChannel, 'Waktu sholat'),
      PlannedKind.reminder => (_reminderChannel, 'Pengingat sebelum sholat'),
      PlannedKind.dhikr => (_dhikrChannel, 'Dzikir harian'),
    };
    return NotificationDetails(
      // Pada Android 8+ suara melekat pada channel, jadi ID channel dibedakan
      // menurut pilihan suara.
      android: AndroidNotificationDetails(
        silent ? '${id}_silent' : id,
        name,
        importance: Importance.high,
        priority: Priority.high,
        playSound: !silent,
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: DarwinNotificationDetails(presentSound: !silent),
    );
  }

  @override
  Future<void> schedule(PlannedNotification n, NotificationSound sound) async {
    await init();
    await _plugin.zonedSchedule(
      id: n.id,
      title: n.title,
      body: n.body,
      scheduledDate: tz.TZDateTime.from(n.when, tz.UTC),
      notificationDetails: _details(n.kind, sound),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required NotificationSound sound,
  }) async {
    await init();
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details(PlannedKind.reminder, sound),
    );
  }
}

/// Menjadwalkan ulang seluruh notifikasi dari jadwal cache dan preferensi.
class NotificationService {
  NotificationService(this._gateway);

  final NotificationGateway _gateway;

  /// Mengembalikan jumlah notifikasi yang dijadwalkan. 0 bila izin belum ada.
  /// Tidak meminta izin sendiri; pakai [ensurePermission] dari layar pengaturan.
  Future<int> reschedule({
    required List<PrayerDay> days,
    required NotificationPrefs prefs,
    DateTime? now,
  }) async {
    await _gateway.init();
    await _gateway.cancelAll();
    if (!await _gateway.hasPermission()) return 0;
    final plan = PrayerScheduler.plan(days: days, prefs: prefs, now: now ?? DateTime.now());
    for (final n in plan) {
      await _gateway.schedule(n, prefs.sound);
    }
    return plan.length;
  }

  Future<bool> ensurePermission() async {
    await _gateway.init();
    if (await _gateway.hasPermission()) return true;
    return _gateway.requestPermission();
  }

  /// FR-NTF-07: dipanggil saat logout agar tidak ada notifikasi tersisa.
  Future<void> cancelAll() async {
    await _gateway.init();
    await _gateway.cancelAll();
  }

  Future<void> showNow(String title, String body, NotificationSound sound) {
    return _gateway.showNow(id: 1, title: title, body: body, sound: sound);
  }
}
