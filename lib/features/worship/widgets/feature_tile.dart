// M16 Beranda Ibadah. Kartu satu fitur.
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/feature_search_provider.dart';

class FeatureTile extends StatelessWidget {
  const FeatureTile({super.key, required this.feature, required this.onTap});

  final WorshipFeature feature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = !feature.available;
    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                feature.icon,
                color: muted ? scheme.onSurfaceVariant : scheme.primary,
              ),
              const Spacer(),
              Text(feature.title, style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                muted ? 'Segera hadir' : feature.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
