// M17 Profil (FR-PRO-08), FR-SYNC-03. Pengaturan yang ikut tersinkron antar
// perangkat dengan aturan last-write-wins berdasarkan updated_at.
import 'dart:convert';

import '../../../core/database/daos/outbox_dao.dart';
import '../../../core/database/daos/settings_dao.dart';
import '../../../core/sync/sync_service.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/utils/date_time_utils.dart';

abstract final class SyncedKeys {
  static const theme = 'theme_mode';
  static const notificationPrefs = 'notification_prefs';
  static const tasbihMode = 'tasbih_mode';
  static const tasbihSensitivity = 'tasbih_sensitivity';
  static const tasbihVibrate = 'tasbih_vibrate';
  static const tasbihTarget = 'tasbih_target';

  /// Hanya kunci ini yang dikirim dan diterima. Data sensitif dan cache
  /// (kota manual, cache masjid, token) sengaja tidak termasuk.
  static const all = {
    theme,
    notificationPrefs,
    tasbihMode,
    tasbihSensitivity,
    tasbihVibrate,
    tasbihTarget,
  };
}

class SyncedSettings {
  SyncedSettings({required this.settings, required this.outbox, DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  final SettingsDao settings;
  final OutboxDao outbox;
  final DateTime Function() _now;

  Future<String?> get(String key) => settings.get(key);

  /// Menyimpan lokal dan, untuk kunci yang disinkronkan, memasukkan ke outbox.
  Future<void> set(String key, String value) async {
    final now = _now();
    await settings.set(key, value, now: now);
    if (!SyncedKeys.all.contains(key)) return;
    await outbox.enqueue(
      entity: OutboxEntity.setting,
      op: OutboxOp.update,
      payload: jsonEncode({
        'key': key,
        'value': value,
        'updated_at': DateTimeUtils.toIsoUtcSeconds(now),
      }),
      now: now,
    );
  }

  /// Menerapkan pengaturan dari server bila lebih baru dari yang lokal.
  Future<void> applyRemote(List<Map<String, dynamic>> items) async {
    final local = {for (final r in await settings.getAll()) r.settingKey: r};
    for (final item in items) {
      final key = (item['key'] ?? item['setting_key'])?.toString();
      final value = (item['value'] ?? item['setting_value'])?.toString();
      final at = DateTime.tryParse('${item['updated_at']}');
      if (key == null || value == null || at == null) continue;
      if (!SyncedKeys.all.contains(key)) continue;
      final existing = local[key];
      if (existing != null) {
        final localAt = DateTime.tryParse(existing.updatedAt);
        if (localAt != null && !at.toUtc().isAfter(localAt.toUtc())) continue;
      }
      await settings.set(key, value, now: at.toUtc());
    }
  }
}

class SettingsPullHandler implements SyncPullHandler {
  SettingsPullHandler(this._settings);

  final SyncedSettings _settings;

  @override
  String get entity => OutboxEntity.setting;

  @override
  Future<void> apply(List<Map<String, dynamic>> items) => _settings.applyRemote(items);
}
