// M17 Profil (FR-PRO-04). Keamanan: login biometrik dan kata sandi.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/biometric_service.dart';
import '../../auth/widgets/biometric_offer_dialog.dart';
import '../providers/profile_provider.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool enable) async {
    if (enable) {
      await showBiometricOfferDialog(context);
    } else {
      try {
        await ref.read(authRepositoryProvider).disableBiometric();
        await ref.read(biometricServiceProvider).setEnabled(false);
      } on ApiException catch (e) {
        if (context.mounted) showAppSnackBar(context, e.message);
      }
    }
    ref.invalidate(biometricStatusProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(biometricStatusProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Keamanan')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          status.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const StatusBanner(
              message: 'Status biometrik gagal dibaca.',
              kind: BannerKind.error,
            ),
            data: (s) {
              final available = s.availability == BiometricAvailability.available;
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
                    title: const Text('Login biometrik'),
                    subtitle: const Text('Masuk dan buka kunci aplikasi dengan sidik jari atau wajah.'),
                    value: s.enabled,
                    onChanged: (available || s.enabled) ? (v) => _toggle(context, ref, v) : null,
                  ),
                ],
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('Ubah kata sandi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(RouteNames.changePassword),
          ),
        ],
      ),
    );
  }
}
