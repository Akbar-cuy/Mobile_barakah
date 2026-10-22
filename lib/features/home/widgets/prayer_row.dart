// M4 Beranda (FR-LBS-02). Satu baris waktu sholat.
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class PrayerRow extends StatelessWidget {
  const PrayerRow({
    super.key,
    required this.name,
    required this.time,
    this.highlighted = false,
  });

  final String name;
  final String time;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color:
            highlighted ? scheme.secondaryContainer : scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        children: [
          Icon(
            highlighted ? Icons.notifications_active : Icons.access_time,
            size: 20,
            color: highlighted
                ? scheme.onSecondaryContainer
                : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(name, style: theme.textTheme.titleMedium)),
          Text(time, style: theme.textTheme.titleMedium),
          if (highlighted) ...[
            const SizedBox(width: AppSpacing.sm),
            Text('Berikutnya', style: theme.textTheme.labelSmall),
          ],
        ],
      ),
    );
  }
}
