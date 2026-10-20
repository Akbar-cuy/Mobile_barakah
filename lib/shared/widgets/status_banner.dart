import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

enum BannerKind { info, warning, error, offline }

/// Status selalu memakai ikon dan teks, tidak hanya warna (design.md bagian 12).
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.message,
    this.kind = BannerKind.info,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final BannerKind kind;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = theme.extension<AppStatusColors>() ?? AppStatusColors.light;
    final (color, icon) = switch (kind) {
      BannerKind.info => (status.info, Icons.info_outline),
      BannerKind.warning => (status.warning, Icons.warning_amber_rounded),
      BannerKind.error => (theme.colorScheme.error, Icons.error_outline),
      BannerKind.offline => (status.warning, Icons.cloud_off_outlined),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
