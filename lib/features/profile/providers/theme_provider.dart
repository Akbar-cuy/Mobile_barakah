// M17 Profil (FR-PRO-07). Tema ikut tersinkron antar perangkat.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../repository/synced_settings.dart';

final syncedSettingsProvider = Provider<SyncedSettings>((ref) {
  return SyncedSettings(
    settings: ref.watch(settingsDaoProvider),
    outbox: ref.watch(outboxDaoProvider),
  );
});

final settingsPullHandlerProvider = Provider<SettingsPullHandler>(
  (ref) => SettingsPullHandler(ref.watch(syncedSettingsProvider)),
);

ThemeMode themeModeFromId(String? id) => switch (id) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

String themeModeId(ThemeMode mode) => switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final subscription = ref
        .read(settingsDaoProvider)
        .watch(SyncedKeys.theme)
        .listen((value) => state = themeModeFromId(value));
    ref.onDispose(subscription.cancel);
    return ThemeMode.system;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(syncedSettingsProvider).set(SyncedKeys.theme, themeModeId(mode));
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
