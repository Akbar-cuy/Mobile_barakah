// M17 Profil (FR-PRO-07). Pengaturan: tema dan sinkronisasi.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/router/route_names.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static String _statusText(SyncStatus? status) => switch (status) {
        SyncStatus.synced => 'Semua data tersinkron.',
        SyncStatus.pending => 'Ada data menunggu dikirim.',
        SyncStatus.error => 'Sebagian data gagal dikirim. Coba sinkronkan lagi.',
        _ => 'Memeriksa status.',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final status = ref.watch(syncStatusProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          Text('Tema', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('Sistem')),
              ButtonSegment(value: ThemeMode.light, label: Text('Terang')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Gelap')),
            ],
            selected: {mode},
            onSelectionChanged: (s) =>
                ref.read(themeModeProvider.notifier).select(s.first),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Sinkronisasi', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(_statusText(status)),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: () => ref.read(syncServiceProvider).syncNow(manual: true),
              icon: const Icon(Icons.sync),
              label: const Text('Sinkronkan sekarang'),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Pengingat adzan'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(RouteNames.notificationSettings),
          ),
        ],
      ),
    );
  }
}
