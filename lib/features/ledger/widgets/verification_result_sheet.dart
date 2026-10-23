// M12 Blockchain Sederhana (FR-BLK-04, FR-BLK-05)
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../services/chain_verifier.dart';

/// Menampilkan hasil Verifikasi Rantai. Bila tidak valid, tampil indeks blok
/// pertama yang rusak serta perbandingan hash tersimpan dengan hasil hitung
/// ulang (FR-BLK-05). [onOpenBlock] membuka detail blok itu.
Future<void> showVerificationResultSheet(
  BuildContext context,
  ChainVerification result, {
  ValueChanged<int>? onOpenBlock,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => VerificationResultSheet(
      result: result,
      onOpenBlock: onOpenBlock,
    ),
  );
}

class VerificationResultSheet extends StatelessWidget {
  const VerificationResultSheet({
    super.key,
    required this.result,
    this.onOpenBlock,
  });

  final ChainVerification result;
  final ValueChanged<int>? onOpenBlock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = theme.extension<AppStatusColors>() ?? AppStatusColors.light;
    final ok = result.isValid;
    final color = ok ? status.success : theme.colorScheme.error;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          0,
          AppSpacing.page,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  ok ? Icons.verified_outlined : Icons.error_outline,
                  color: color,
                  size: 32,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(result.summary, style: theme.textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (ok)
              Text(
                'Seluruh hash dihitung ulang, setiap prev_hash tersambung, '
                'dan semua blok memenuhi syarat proof of work.',
                style: theme.textTheme.bodyMedium,
              )
            else ...[
              Text(result.issueDescription, style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
              if (result.issue == ChainIssue.hashMismatch) ...[
                _HashRow(label: 'Hash tersimpan', value: result.storedHash),
                _HashRow(label: 'Hash hasil hitung ulang', value: result.recomputedHash),
              ],
              if (result.issue == ChainIssue.prevHashMismatch) ...[
                _HashRow(label: 'prev_hash seharusnya', value: result.expectedPrevHash),
                _HashRow(label: 'prev_hash tertulis', value: result.actualPrevHash),
              ],
              if (result.issue == ChainIssue.powNotMet)
                _HashRow(label: 'Hash blok', value: result.storedHash),
              if (onOpenBlock != null && result.issue != ChainIssue.indexGap) ...[
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onOpenBlock!(result.firstInvalidIndex!);
                  },
                  child: Text('Lihat blok ${result.firstInvalidIndex}'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _HashRow extends StatelessWidget {
  const _HashRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SelectableText(value ?? '-', style: AppTextStyles.hash),
        ],
      ),
    );
  }
}
