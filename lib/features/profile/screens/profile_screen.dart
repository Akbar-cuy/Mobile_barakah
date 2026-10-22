// M17 Profil (FR-PRO-01)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/session_provider.dart';
import '../widgets/avatar_picker.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          Center(
            child: AvatarPicker(
              initials: user?.initials ?? '',
              url: user?.avatarUrl,
              onEdit: () => context.push(RouteNames.editProfile),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(child: Text(user?.name ?? '', style: theme.textTheme.titleLarge)),
          if (user != null && user.username.isNotEmpty)
            Center(child: Text('@${user.username}', style: theme.textTheme.bodyMedium)),
          if (user != null && user.email.isNotEmpty)
            Center(child: Text(user.email, style: theme.textTheme.bodyMedium)),
          const SizedBox(height: AppSpacing.xl),
          _Tile(
            icon: Icons.person_outline,
            title: 'Ubah profil',
            onTap: () => context.push(RouteNames.editProfile),
          ),
          _Tile(
            icon: Icons.lock_outline,
            title: 'Keamanan',
            subtitle: 'Login biometrik dan kata sandi',
            onTap: () => context.push(RouteNames.security),
          ),
          _Tile(
            icon: Icons.notifications_outlined,
            title: 'Pengingat adzan',
            onTap: () => context.push(RouteNames.notificationSettings),
          ),
          _Tile(
            icon: Icons.settings_outlined,
            title: 'Pengaturan',
            subtitle: 'Tema dan sinkronisasi',
            onTap: () => context.push(RouteNames.settings),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
