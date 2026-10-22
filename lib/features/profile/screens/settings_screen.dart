// M17 Profil (FR-PRO-07, FR-PRO-08)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/theme_provider.dart';

final _pendingCountProvider = StreamProvider.autoDispose<int>(
  (ref) => ref.watch(outboxDaoProvider).watchPendingCount(),
);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mode = ref.watch(themeModeProvider);
    final pending = ref.watch(_pendingCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          Text('Tema', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto), label: Text('Sistem')),
              ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode), label: Text('Terang')),
              ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode), label: Text('Gelap')),
            ],
            selected: {mode},
            onSelectionChanged: (v) => ref.read(themeModeProvider.notifier).set(v.first),
          ),
          const Divider(height: AppSpacing.xxl),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Pengingat adzan'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(RouteNames.notificationSettings),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(pending == 0 ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined),
            title: const Text('Sinkronisasi'),
            subtitle: Text(pending == 0 ? 'Semua data tersinkron.' : '$pending perubahan menunggu dikirim.'),
            trailing: TextButton(
              onPressed: () => ref.read(syncServiceProvider).syncNow(manual: true),
              child: const Text('Sinkronkan'),
            ),
          ),
        ],
      ),
    );
  }
}
