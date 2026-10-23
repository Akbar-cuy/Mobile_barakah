// M16 Notifikasi (FR-NTF-02..05)
import 'dart:convert';

import '../../../core/database/daos/settings_dao.dart';
import '../../profile/repository/synced_settings.dart';

/// Waktu sholat yang dapat diberi notifikasi. Terbit tidak termasuk.
enum PrayerSlot {
  fajr('Subuh'),
  dhuhr('Dzuhur'),
  asr('Ashar'),
  maghrib('Maghrib'),
  isha('Isya');

  const PrayerSlot(this.label);
  final String label;
}

enum NotificationSound { defaultSound, silent }

class NotificationPrefs {
  const NotificationPrefs({
    this.enabled = _allOn,
    this.sound = NotificationSound.defaultSound,
    this.reminderMinutes = 0,
    this.dhikrEnabled = false,
    this.dhikrHour = 5,
    this.dhikrMinute = 30,
    this.nearMosque = false,
  });

  factory NotificationPrefs.fromJson(Map<String, dynamic> j) {
    final en = (j['enabled'] as Map?)?.cast<String, dynamic>() ?? const {};
    return NotificationPrefs(
      enabled: {for (final s in PrayerSlot.values) s: en[s.name] != false},
      sound: j['sound'] == 'silent' ? NotificationSound.silent : NotificationSound.defaultSound,
      reminderMinutes: _allowedReminder((j['reminder'] as num?)?.toInt() ?? 0),
      dhikrEnabled: j['dhikr'] == true,
      dhikrHour: ((j['dhikr_h'] as num?)?.toInt() ?? 5).clamp(0, 23),
      dhikrMinute: ((j['dhikr_m'] as num?)?.toInt() ?? 30).clamp(0, 59),
      nearMosque: j['near_mosque'] == true,
    );
  }

  static const Map<PrayerSlot, bool> _allOn = {
    PrayerSlot.fajr: true,
    PrayerSlot.dhuhr: true,
    PrayerSlot.asr: true,
    PrayerSlot.maghrib: true,
    PrayerSlot.isha: true,
  };

  /// Pengingat sebelum adzan (menit). 0 berarti mati.
  static const List<int> reminderOptions = [0, 5, 10, 15];

  static int _allowedReminder(int v) => reminderOptions.contains(v) ? v : 0;

  final Map<PrayerSlot, bool> enabled;
  final NotificationSound sound;
  final int reminderMinutes;
  final bool dhikrEnabled;
  final int dhikrHour;
  final int dhikrMinute;
  final bool nearMosque;

  bool isOn(PrayerSlot s) => enabled[s] ?? true;

  NotificationPrefs copyWith({
    Map<PrayerSlot, bool>? enabled,
    NotificationSound? sound,
    int? reminderMinutes,
    bool? dhikrEnabled,
    int? dhikrHour,
    int? dhikrMinute,
    bool? nearMosque,
  }) {
    return NotificationPrefs(
      enabled: enabled ?? this.enabled,
      sound: sound ?? this.sound,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      dhikrEnabled: dhikrEnabled ?? this.dhikrEnabled,
      dhikrHour: dhikrHour ?? this.dhikrHour,
      dhikrMinute: dhikrMinute ?? this.dhikrMinute,
      nearMosque: nearMosque ?? this.nearMosque,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': {for (final e in enabled.entries) e.key.name: e.value},
        'sound': sound == NotificationSound.silent ? 'silent' : 'default',
        'reminder': reminderMinutes,
        'dhikr': dhikrEnabled,
        'dhikr_h': dhikrHour,
        'dhikr_m': dhikrMinute,
        'near_mosque': nearMosque,
      };
}

class NotificationPrefsStore {
  NotificationPrefsStore(this._settings, {SettingsDao? legacySettings})
      : _legacySettings = legacySettings;

  final SyncedSettings _settings;
  final SettingsDao? _legacySettings;
  static const key = SyncedKeys.notificationPrefs;
  static const _legacyKey = 'notification_settings';

  Future<NotificationPrefs> read() async {
    final raw = await _settings.get(key);
    if (raw == null) {
      final legacy = await _legacySettings?.get(_legacyKey);
      if (legacy == null) return const NotificationPrefs();
      final old = (jsonDecode(legacy) as Map).cast<String, dynamic>();
      final enabled = old['enabled'] != false;
      final minutesBefore = (old['minutes_before'] as num?)?.toInt() ?? 0;
      final names = (old['prayers'] as List?)
              ?.map((value) => value.toString())
              .toSet() ??
          const <String>{};
      final migrated = NotificationPrefs(
        enabled: {
          for (final slot in PrayerSlot.values)
            slot: enabled && (names.isEmpty || names.contains(slot.name)),
        },
        reminderMinutes: NotificationPrefs.reminderOptions.contains(minutesBefore)
            ? minutesBefore
            : 0,
      );
      await save(migrated);
      return migrated;
    }
    try {
      return NotificationPrefs.fromJson((jsonDecode(raw) as Map).cast<String, dynamic>());
    } on FormatException {
      return const NotificationPrefs();
    } on TypeError {
      return const NotificationPrefs();
    }
  }

  Future<void> save(NotificationPrefs p) => _settings.set(key, jsonEncode(p.toJson()));
}
