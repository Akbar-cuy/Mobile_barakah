// M12 Blockchain Sederhana (FR-BLK-04, FR-BLK-08)
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../repository/ledger_repository.dart';
import '../services/chain_verifier.dart';

/// Status selalu memakai ikon dan teks, tidak hanya warna (design.md bagian 12).
class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.icon,
    required this.color,
    required this.text,
    this.busy = false,
  });

  final IconData icon;
  final Color color;
  final String text;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (busy)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}

/// Hasil Verifikasi Rantai: valid, tidak valid, atau belum diperiksa.
class ChainStatusBadge extends StatelessWidget {
  const ChainStatusBadge({
    super.key,
    required this.verification,
    this.verifying = false,
  });

  final ChainVerification? verification;
  final bool verifying;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = theme.extension<AppStatusColors>() ?? AppStatusColors.light;
    final v = verification;

    if (verifying) {
      return const _StatusLine(
        icon: Icons.hourglass_empty,
        color: Colors.transparent,
        text: 'Memverifikasi rantai...',
        busy: true,
      );
    }
    if (v == null) {
      return _StatusLine(
        icon: Icons.help_outline,
        color: theme.colorScheme.onSurfaceVariant,
        text: 'Rantai belum diverifikasi',
      );
    }
    return Semantics(
      liveRegion: true,
      child: v.isValid
          ? _StatusLine(
              icon: Icons.verified_outlined,
              color: status.success,
              text: v.summary,
            )
          : _StatusLine(
              icon: Icons.error_outline,
              color: theme.colorScheme.error,
              text: v.summary,
            ),
    );
  }
}

/// Perbandingan head lokal dengan head server (FR-BLK-08).
class HeadStatusBadge extends StatelessWidget {
  const HeadStatusBadge({
    super.key,
    required this.head,
    this.offline = false,
    this.checking = false,
  });

  final HeadComparison? head;
  final bool offline;
  final bool checking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = theme.extension<AppStatusColors>() ?? AppStatusColors.light;

    if (checking) {
      return const _StatusLine(
        icon: Icons.sync,
        color: Colors.transparent,
        text: 'Memeriksa head server...',
        busy: true,
      );
    }
    final h = head;
    if (h == null) {
      return _StatusLine(
        icon: offline ? Icons.cloud_off_outlined : Icons.help_outline,
        color: offline ? status.warning : theme.colorScheme.onSurfaceVariant,
        text: offline
            ? 'Head server: belum diperiksa (offline)'
            : 'Head server: belum diperiksa',
      );
    }
    switch (h.status) {
      case HeadStatus.match:
        return _StatusLine(
          icon: Icons.check_circle_outline,
          color: status.success,
          text: h.pendingCount > 0
              ? 'Head server: sesuai, ${h.pendingCount} blok menunggu dikirim'
              : 'Head server: sesuai',
        );
      case HeadStatus.serverAhead:
        return _StatusLine(
          icon: Icons.cloud_download_outlined,
          color: status.warning,
          text: 'Server punya blok yang belum ada di perangkat ini',
        );
      case HeadStatus.mismatch:
        return _StatusLine(
          icon: Icons.warning_amber_rounded,
          color: theme.colorScheme.error,
          text: 'Head server tidak cocok dengan ledger di perangkat',
        );
      case HeadStatus.unknown:
        return _StatusLine(
          icon: Icons.help_outline,
          color: theme.colorScheme.onSurfaceVariant,
          text: 'Head server: belum diperiksa',
        );
    }
  }
}
