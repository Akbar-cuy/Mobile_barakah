// M17 Profil (FR-PRO-04, FR-PRO-06).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/biometric_service.dart';
import '../../auth/widgets/biometric_offer_dialog.dart';
import '../providers/profile_provider.dart';
import '../repository/profile_repository.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _busy = false;

  Future<void> _toggleBiometric(bool enabled) async {
    setState(() => _busy = true);
    try {
      if (enabled) {
        await showBiometricOfferDialog(context);
      } else {
        await ref.read(authRepositoryProvider).disableBiometric();
        await ref.read(biometricServiceProvider).setEnabled(false);
      }
    } on ApiException catch (error) {
      if (mounted) showAppSnackBar(context, error.message);
    } on Object {
      if (mounted) {
        showAppSnackBar(context, 'Pengaturan biometrik gagal. Coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
      ref.invalidate(biometricStatusProvider);
    }
  }

  Future<void> _revoke(ActiveSession session) async {
    final shouldRevoke = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cabut sesi ini?'),
        content: Text('${session.device} akan keluar dari akun Anda.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cabut'),
          ),
        ],
      ),
    );
    if (shouldRevoke != true) return;
    final ok =
        await ref.read(profileControllerProvider.notifier).revokeSession(session.id);
    if (mounted && !ok) {
      showAppSnackBar(
        context,
        ref.read(profileControllerProvider).error ?? 'Gagal mencabut sesi.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(biometricStatusProvider);
    final sessions = ref.watch(activeSessionsProvider);
    final action = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Keamanan dan Sesi')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          status.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const StatusBanner(
              message: 'Status biometrik gagal dibaca.',
              kind: BannerKind.error,
            ),
            data: (value) {
              final available =
                  value.availability == BiometricAvailability.available;
              return Column(
                children: [
                  if (!available)
                    const Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                      child: StatusBanner(
                        message:
                            'Perangkat belum mendukung biometrik atau belum ada sidik jari atau wajah yang terdaftar.',
                        kind: BannerKind.warning,
                      ),
                    ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.fingerprint),
                    title: const Text('Login biometrik'),
                    subtitle: const Text(
                      'Masuk dan buka kunci aplikasi dengan sidik jari atau wajah.',
                    ),
                    value: value.enabled,
                    onChanged: _busy || (!available && !value.enabled)
                        ? null
                        : _toggleBiometric,
                  ),
                ],
              );
            },
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.password),
            title: const Text('Ubah kata sandi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(RouteNames.changePassword),
          ),
          const Divider(height: AppSpacing.xxl),
          Text('Sesi aktif', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          if (action.error != null)
            StatusBanner(kind: BannerKind.error, message: action.error!),
          sessions.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Column(
              children: [
                const StatusBanner(
                  kind: BannerKind.offline,
                  message: 'Daftar sesi tidak dapat dimuat saat ini.',
                ),
                TextButton(
                  onPressed: () => ref.invalidate(activeSessionsProvider),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
            data: (list) => list.isEmpty
                ? const Text('Tidak ada sesi aktif.')
                : Column(
                    children: [
                      for (final session in list)
                        Card(
                          elevation: 0,
                          child: ListTile(
                            leading: const Icon(Icons.phone_android),
                            title: Text(
                              session.device,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text([
                              if (session.isCurrent) 'Perangkat ini',
                              if (session.lastSeenAt != null)
                                'Aktif ${DateTimeUtils.formatDate(session.lastSeenAt!.toLocal())}',
                            ].join(' • ')),
                            trailing: session.isCurrent
                                ? null
                                : IconButton(
                                    tooltip: 'Cabut sesi',
                                    icon: const Icon(Icons.logout),
                                    onPressed: action.busy
                                        ? null
                                        : () => _revoke(session),
                                  ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
