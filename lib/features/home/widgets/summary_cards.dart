// M4 Beranda: ringkasan lokasi dan status pengingat adzan.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../notification/providers/notification_provider.dart';
import '../services/location_service.dart';

class SummaryCards extends ConsumerWidget {
  const SummaryCards({super.key, required this.location});

  final GeoPoint location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminder = ref.watch(notificationSettingsProvider).value;
    final reminderText = reminder == null
        ? 'Memuat'
        : reminder.enabled
            ? 'Aktif, ${reminder.prayers.length} sholat'
            : 'Mati';
    return Row(
      children: [
        Expanded(
          child: _Card(
            icon: Icons.place_outlined,
            title: 'Lokasi',
            value: location.isDefault ? 'Jakarta (bawaan)' : location.city,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _Card(
            icon: Icons.notifications_outlined,
            title: 'Pengingat adzan',
            value: reminderText,
            onTap: () => context.push(RouteNames.notificationSettings),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(title, style: theme.textTheme.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
