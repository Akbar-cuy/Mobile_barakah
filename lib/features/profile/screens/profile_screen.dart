// M17 Profil (FR-PRO-01).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../widgets/avatar_picker.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    Widget tile(IconData icon, String title, String route, {String? subtitle}) =>
        Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            leading: Icon(icon),
            title: Text(title),
            subtitle: subtitle == null ? null : Text(subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(route),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          if (user != null) ...[
            Center(
              child: AvatarPicker(
                initials: user.initials,
                url: user.avatarUrl,
                onEdit: () => context.push(RouteNames.editProfile),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(child: Text(user.name, style: theme.textTheme.titleLarge)),
            if (user.username.isNotEmpty)
              Center(
                child: Text(
                  '@${user.username}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            if (user.email.isNotEmpty)
              Center(child: Text(user.email, style: theme.textTheme.bodyMedium)),
          ] else
            const Center(child: CircularProgressIndicator()),
          const SizedBox(height: AppSpacing.xl),
          tile(Icons.person_outline, 'Ubah profil', RouteNames.editProfile),
          tile(
            Icons.lock_outline,
            'Ganti kata sandi',
            RouteNames.changePassword,
          ),
          tile(
            Icons.shield_outlined,
            'Keamanan dan sesi',
            RouteNames.security,
          ),
          tile(
            Icons.notifications_outlined,
            'Pengingat adzan',
            RouteNames.notificationSettings,
          ),
          tile(Icons.link, 'Ledger donasi', RouteNames.ledger),
          if (AppConfig.enableIot)
            tile(Icons.sensors, 'Tasbih fisik (IoT)', RouteNames.iot),
          tile(Icons.settings_outlined, 'Pengaturan', RouteNames.settings),
        ],
      ),
    );
  }
}
