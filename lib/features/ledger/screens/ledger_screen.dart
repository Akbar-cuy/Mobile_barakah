// M12 Blockchain Sederhana (FR-BLK-04, FR-BLK-08, FR-BLK-10, FR-BLK-11)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/status_banner.dart';
import '../providers/ledger_provider.dart';
import '../repository/ledger_repository.dart';
import '../widgets/block_card.dart';
import '../widgets/chain_status_badge.dart';
import '../widgets/verification_result_sheet.dart';

/// Daftar blok donasi milik pengguna. Hanya membaca: tidak ada aksi ubah atau
/// hapus blok (FR-BLK-11).
class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(ledgerControllerProvider.notifier).refreshHead();
    });
  }

  Future<void> _verify() async {
    final result = await ref.read(ledgerControllerProvider.notifier).verify();
    if (!mounted || result == null) return;
    await showVerificationResultSheet(
      context,
      result,
      onOpenBlock: (i) => context.push(RouteNames.ledgerBlock(i)),
    );
  }

  Future<void> _refresh() async {
    final report = await ref.read(ledgerControllerProvider.notifier).sync();
    if (!mounted || report == null) return;
    if (report.remined > 0) {
      showAppSnackBar(
        context,
        '${report.remined} blok dihitung ulang di atas head server.',
      );
    } else if (report.pulledBlocks > 0) {
      showAppSnackBar(context, '${report.pulledBlocks} blok baru dari server.');
    }
  }

  Future<void> _export() async {
    final path = await ref.read(ledgerControllerProvider.notifier).exportJson();
    if (!mounted) return;
    showAppSnackBar(
      context,
      path == null
          ? 'Ledger gagal diekspor.'
          : 'JSON disalin dan disimpan di $path',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final view = ref.watch(ledgerControllerProvider);
    final blocks = ref.watch(ledgerBlocksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ledger Donasi')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: blocks.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: const [
              StatusBanner(
                kind: BannerKind.error,
                message: 'Ledger tidak dapat dibaca dari penyimpanan lokal.',
              ),
            ],
          ),
          data: (list) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              Card(
                elevation: 0,
                color: theme.colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.large),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ChainStatusBadge(
                        verification: view.verification,
                        verifying: view.verifying,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      HeadStatusBadge(
                        head: view.head,
                        offline: view.headOffline,
                        checking: view.checkingHead,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FilledButton.tonalIcon(
                        onPressed: view.verifying || list.isEmpty ? null : _verify,
                        icon: const Icon(Icons.rule),
                        label: const Text('Verifikasi Rantai'),
                      ),
                      if (view.head?.status == HeadStatus.serverAhead ||
                          view.head?.status == HeadStatus.mismatch) ...[
                        const SizedBox(height: AppSpacing.sm),
                        OutlinedButton.icon(
                          onPressed: view.syncing ? null : _refresh,
                          icon: const Icon(Icons.cloud_sync_outlined),
                          label: Text(
                            view.syncing ? 'Menyelaraskan...' : 'Selaraskan dengan server',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (view.error != null) ...[
                const SizedBox(height: AppSpacing.md),
                StatusBanner(kind: BannerKind.error, message: view.error!),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (list.isEmpty)
                _EmptyLedger()
              else
                for (final block in list)
                  BlockCard(
                    block: block,
                    onTap: () => context.push(RouteNames.ledgerBlock(block.index)),
                  ),
              if (list.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _export,
                  icon: const Icon(Icons.ios_share),
                  label: const Text('Ekspor JSON'),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Text(
                'Rantai blok sederhana per pengguna, bukan jaringan terdistribusi. '
                'Keutuhan dijaga oleh rantai hash, proof of work ringan, serta '
                'verifikasi dan jangkar head di server.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyLedger extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Icon(Icons.link, size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.md),
          Text('Belum ada blok', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Blok pertama dibuat saat Anda berdonasi.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
