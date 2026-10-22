// M12 Blockchain Sederhana (FR-BLK-10, FR-BLK-11)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../models/block.dart';
import '../providers/ledger_provider.dart';
import '../widgets/block_card.dart';

/// Detail satu blok. Hash lengkap dapat disalin; tidak ada ubah atau hapus.
class BlockDetailScreen extends ConsumerWidget {
  const BlockDetailScreen({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocks = ref.watch(ledgerBlocksProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Blok #$index')),
      body: blocks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Blok tidak dapat dibaca.')),
        data: (list) {
          Block? block;
          for (final b in list) {
            if (b.index == index) block = b;
          }
          if (block == null) {
            return const Center(child: Text('Blok tidak ditemukan.'));
          }
          return _Detail(block: block);
        },
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.block});

  final Block block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                block.isGenesis ? 'Blok genesis' : block.donorAlias,
                style: theme.textTheme.titleLarge,
              ),
            ),
            SyncChip(state: block.syncState),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _Field(label: 'Waktu', value: formatBlockTime(block)),
        _Field(label: 'Waktu (UTC, persis yang di-hash)', value: block.timestamp, mono: true),
        _Field(label: 'Kampanye', value: block.campaign),
        _Field(label: 'Nominal', value: block.displayAmount),
        _Field(label: 'Setara rupiah', value: block.displayAmountIdr),
        _Field(label: 'Kurs dipakai', value: block.rateUsed, mono: true),
        _Field(label: 'Nonce', value: '${block.nonce}', mono: true),
        _Field(label: 'Hash', value: block.hash, mono: true, copyable: true),
        _Field(label: 'Hash blok sebelumnya', value: block.prevHash, mono: true, copyable: true),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    this.mono = false,
    this.copyable = false,
  });

  final String label;
  final String value;
  final bool mono;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: mono ? AppTextStyles.hash : theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          if (copyable)
            IconButton(
              tooltip: 'Salin $label',
              icon: const Icon(Icons.copy),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: value));
                if (context.mounted) showAppSnackBar(context, '$label disalin');
              },
            ),
        ],
      ),
    );
  }
}
