// M12 Blockchain Sederhana (FR-BLK-10)
import 'package:flutter/material.dart';

import '../../../core/sync/sync_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_utils.dart';
import '../models/block.dart';

String formatBlockTime(Block block) {
  final t = block.time;
  if (t == null) return block.timestamp;
  return '${DateTimeUtils.formatDate(t)} ${DateTimeUtils.hm(t)}';
}

/// Satu baris pada daftar blok: indeks, waktu, alias, nominal, nonce, dan
/// delapan karakter awal hash. Tidak ada aksi ubah atau hapus (FR-BLK-11).
class BlockCard extends StatelessWidget {
  const BlockCard({super.key, required this.block, this.onTap});

  final Block block;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mono = AppTextStyles.hash.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final title = block.isGenesis
        ? 'Blok genesis'
        : '${block.donorAlias} | ${block.displayAmount}';

    return Semantics(
      button: onTap != null,
      label: 'Blok ${block.index}, $title, ${_syncLabel(block.syncState)}',
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          side: BorderSide(color: theme.colorScheme.outline),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.large),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('#${block.index}', style: theme.textTheme.titleMedium),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        formatBlockTime(block),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SyncChip(state: block.syncState),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(title, style: theme.textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.sm),
                Text('nonce: ${block.nonce}', style: mono),
                Text('hash: ${block.shortHash}...', style: mono),
                Text('prev: ${block.shortPrevHash}...', style: mono),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _syncLabel(String state) {
  switch (state) {
    case SyncState.synced:
      return 'Terkirim';
    case SyncState.failed:
      return 'Gagal';
    default:
      return 'Menunggu';
  }
}

/// Status kirim blok: ikon dan teks, bukan hanya warna.
class SyncChip extends StatelessWidget {
  const SyncChip({super.key, required this.state});

  final String state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = theme.extension<AppStatusColors>() ?? AppStatusColors.light;
    final (IconData icon, Color color) = switch (state) {
      SyncState.synced => (Icons.cloud_done_outlined, status.success),
      SyncState.failed => (Icons.error_outline, theme.colorScheme.error),
      _ => (Icons.schedule, status.warning),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          _syncLabel(state),
          style: theme.textTheme.labelMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
