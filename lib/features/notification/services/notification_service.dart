// M16 Notifikasi (FR-NTF-01, FR-NTF-06, FR-NTF-07)
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'notification_prefs.dart';
import 'prayer_scheduler.dart';

abstract interface class NotificationGateway {
  Future<void> init();
  Future<bool> requestPermission();
  Future<bool> hasPermission();
  Future<void> cancelAll();
  Future<void> schedule(PlannedNotification notification, NotificationSound sound);
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required NotificationSound sound,
  });

  /// Apakah notifikasi [id] benar-benar tampil di bilah notifikasi. Bernilai
  /// true bila platform tidak dapat memeriksanya.
  Future<bool> isShowing(int id);

  /// Membuka pengaturan notifikasi aplikasi di sistem.
  Future<void> openSystemSettings();
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
        android: AndroidInitializationSettings('@drawable/ic_stat_barakah'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    await _createChannels();
    _ready = true;
  }

  /// Saluran dibuat sejak awal agar nama dan tingkat pentingnya tetap, dan
  /// pengguna dapat mengaturnya di pengaturan sistem.
  Future<void> _createChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;
    const channels = {
      _adhanChannel: 'Waktu sholat',
      _reminderChannel: 'Pengingat sebelum sholat',
      _dhikrChannel: 'Dzikir harian',
    };
    for (final entry in channels.entries) {
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          entry.key,
          entry.value,
          importance: Importance.high,
        ),
      );
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          '${entry.key}_silent',
          '${entry.value} (senyap)',
          importance: Importance.high,
          playSound: false,
          enableVibration: false,
        ),
      );
    }
  }

  @override
  Future<bool> isShowing(int id) async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;
    try {
      final active = await android.getActiveNotifications();
      return active.any((n) => n.id == id);
    } on Object {
      return true;
    }
  }

  @override
  Future<void> openSystemSettings() async {
    await openAppSettings();
  }

  @override
  Future<bool> hasPermission() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.areNotificationsEnabled();
    if (androidGranted != null) return androidGranted;

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosSettings = await ios?.checkPermissions();
    return iosSettings?.isEnabled ?? false;
  }

  @override
  Future<bool> requestPermission() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.requestNotificationsPermission();
    if (androidGranted != null) return androidGranted;

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted =
        await ios?.requestPermissions(alert: true, badge: false, sound: true);
    if (iosGranted != null) return iosGranted;

    return (await Permission.notification.request()).isGranted;
  }

  @override
  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  NotificationDetails _details(PlannedKind kind, NotificationSound sound) {
    final silent = sound == NotificationSound.silent;
    final (channelId, name) = switch (kind) {
      PlannedKind.adhan => (_adhanChannel, 'Waktu sholat'),
      PlannedKind.reminder => (_reminderChannel, 'Pengingat sebelum sholat'),
      PlannedKind.dhikr => (_dhikrChannel, 'Dzikir harian'),
    };
    return NotificationDetails(
      android: AndroidNotificationDetails(
        silent ? '${channelId}_silent' : channelId,
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
  Future<void> schedule(
    PlannedNotification notification,
    NotificationSound sound,
  ) async {
    await init();
    await _plugin.zonedSchedule(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      scheduledDate: tz.TZDateTime.from(notification.when, tz.UTC),
      notificationDetails: _details(notification.kind, sound),
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

class NotificationService {
  NotificationService(this._gateway);

  final NotificationGateway _gateway;

  Future<int> reschedule({
    required List<PrayerDay> days,
    required NotificationPrefs prefs,
    DateTime? now,
  }) async {
    await _gateway.init();
    await _gateway.cancelAll();
    if (!await _gateway.hasPermission()) return 0;
    final plan = PrayerScheduler.plan(
      days: days,
      prefs: prefs,
      now: now ?? DateTime.now(),
    );
    for (final notification in plan) {
      await _gateway.schedule(notification, prefs.sound);
    }
    return plan.length;
  }

  Future<bool> ensurePermission() async {
    await _gateway.init();
    if (await _gateway.hasPermission()) return true;
    return _gateway.requestPermission();
  }

  /// FR-NTF-07: membatalkan pengingat akun saat logout.
  Future<void> cancelAll() async {
    await _gateway.init();
    await _gateway.cancelAll();
  }

  Future<void> showNow(String title, String body, NotificationSound sound) {
    return _gateway.showNow(id: _testId, title: title, body: body, sound: sound);
  }

  static const int _testId = 1;

  /// Menampilkan notifikasi uji lalu memeriksa apakah benar muncul. False
  /// berarti sistem menahannya (Jangan Ganggu, saluran dimatikan, dan sebagainya).
  Future<bool> showTest(String title, String body, NotificationSound sound) async {
    await _gateway.init();
    await showNow(title, body, sound);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _gateway.isShowing(_testId);
  }

  Future<void> openSystemSettings() => _gateway.openSystemSettings();
}
