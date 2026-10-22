// M14 Notifikasi Adzan (FR-NTF). Pengaturan, penyimpanan, dan pembungkus plugin.
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/database/daos/settings_dao.dart';
import '../../home/models/prayer_times.dart';

class NotificationSettings {
  const NotificationSettings({
    required this.enabled,
    required this.minutesBefore,
    required this.prayers,
  });

  /// Semua sholat wajib aktif, pengingat tepat waktu.
  factory NotificationSettings.defaults() => NotificationSettings(
        enabled: true,
        minutesBefore: 0,
        prayers: PrayerName.obligatory.toSet(),
      );

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    final names = (json['prayers'] as List?)?.map((e) => e.toString()).toSet() ?? {};
    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      minutesBefore: (json['minutes_before'] as num?)?.toInt() ?? 0,
      prayers: {
        for (final p in PrayerName.obligatory)
          if (names.contains(p.name)) p,
      },
    );
  }

  static const minutesChoices = [0, 5, 10, 15];

  final bool enabled;
  final int minutesBefore;
  final Set<PrayerName> prayers;

  NotificationSettings copyWith({
    bool? enabled,
    int? minutesBefore,
    Set<PrayerName>? prayers,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      minutesBefore: minutesBefore ?? this.minutesBefore,
      prayers: prayers ?? this.prayers,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'minutes_before': minutesBefore,
        'prayers': [for (final p in prayers) p.name],
      };
}

class NotificationSettingsStore {
  NotificationSettingsStore(this._settings);

  final SettingsDao _settings;

  static const _kSettings = 'notification_settings';
  static const _kAsked = 'notification_permission_asked';

  Future<NotificationSettings> load() async {
    final raw = await _settings.get(_kSettings);
    if (raw == null) return NotificationSettings.defaults();
    try {
      return NotificationSettings.fromJson(
        (jsonDecode(raw) as Map).cast<String, dynamic>(),
      );
    } on Object {
      return NotificationSettings.defaults();
    }
  }

  Future<void> save(NotificationSettings value) =>
      _settings.set(_kSettings, jsonEncode(value.toJson()));

  Future<bool> permissionAsked() async => (await _settings.get(_kAsked)) == '1';

  Future<void> markPermissionAsked() => _settings.set(_kAsked, '1');
}

abstract interface class NotificationGateway {
  Future<void> init();

  /// True bila pengguna mengizinkan notifikasi.
  Future<bool> requestPermission();

  Future<void> cancelAll();

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
  });
}

/// Penjadwalan memakai waktu absolut (UTC), jadi tidak perlu zona lokal perangkat.
/// Mode tidak tepat dipilih agar tidak membutuhkan izin alarm tepat.
class LocalNotificationGateway implements NotificationGateway {
  LocalNotificationGateway({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'adzan_channel',
      'Pengingat Adzan',
      channelDescription: 'Pengingat waktu sholat',
      importance: Importance.max,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
  );

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
  Future<bool> requestPermission() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.requestNotificationsPermission();
    final iosGranted =
        await ios?.requestPermissions(alert: true, badge: false, sound: true);
    return androidGranted ?? iosGranted ?? false;
  }

  @override
  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
  }) async {
    await init();
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
