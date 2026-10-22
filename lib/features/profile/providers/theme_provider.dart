// M17 Profil (FR-PRO-07). Tema disimpan di pengaturan dan ikut tersinkron.
import 'dart:async';

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

String themeModeId(ThemeMode m) => switch (m) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Mengikuti tabel settings, sehingga nilai dari sinkronisasi langsung terpakai.
    final sub = ref
        .read(settingsDaoProvider)
        .watch(SyncedKeys.theme)
        .listen((v) => state = themeModeFromId(v));
    ref.onDispose(sub.cancel);
    return ThemeMode.system;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(syncedSettingsProvider).set(SyncedKeys.theme, themeModeId(mode));
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
