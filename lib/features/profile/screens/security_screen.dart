// M17 Profil (FR-PRO-05, FR-PRO-06)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/status_banner.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/session_provider.dart';
import '../providers/profile_provider.dart';
import '../repository/profile_repository.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool? _biometricOn;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadBiometric();
  }

  Future<void> _loadBiometric() async {
    final on = await ref.read(authRepositoryProvider).hasDeviceToken();
    if (mounted) setState(() => _biometricOn = on);
  }

  Future<String?> _askPassword() {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi kata sandi'),
        content: TextField(
          controller: c,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Kata sandi'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('Lanjut')),
        ],
      ),
    ).whenComplete(c.dispose);
  }

  Future<void> _toggleBiometric(bool on) async {
    setState(() => _busy = true);
    try {
      if (on) {
        final password = await _askPassword();
        if (password == null || password.isEmpty) return;
        final ok = await ref.read(sessionProvider.notifier).enableBiometric(password);
        if (!mounted) return;
        if (!ok) showAppSnackBar(context, 'Biometrik gagal diaktifkan.');
      } else {
        await ref.read(authRepositoryProvider).disableBiometric();
      }
    } catch (_) {
      if (mounted) showAppSnackBar(context, 'Pengaturan biometrik gagal. Coba lagi.');
    } finally {
      if (mounted) setState(() => _busy = false);
      await _loadBiometric();
    }
  }

  Future<void> _revoke(ActiveSession s) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cabut sesi ini?'),
        content: Text('${s.device} akan keluar dari akun Anda.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cabut')),
        ],
      ),
    );
    if (sure != true) return;
    final ok = await ref.read(profileControllerProvider.notifier).revokeSession(s.id);
    if (mounted && !ok) {
      showAppSnackBar(context, ref.read(profileControllerProvider).error ?? 'Gagal mencabut sesi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessions = ref.watch(activeSessionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Keamanan dan Sesi')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.page),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Masuk dengan biometrik'),
            subtitle: const Text('Sidik jari atau wajah untuk membuka aplikasi.'),
            value: _biometricOn ?? false,
            onChanged: (_biometricOn == null || _busy) ? null : _toggleBiometric,
          ),
          const Divider(height: AppSpacing.xxl),
          Text('Sesi aktif', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          sessions.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => Column(
              children: [
                const StatusBanner(
                  kind: BannerKind.offline,
                  message: 'Daftar sesi hanya tersedia saat online.',
                ),
                TextButton(
                  onPressed: () => ref.invalidate(activeSessionsProvider),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
            data: (list) => list.isEmpty
                ? const Text('Tidak ada sesi lain.')
                : Column(
                    children: [
                      for (final s in list)
                        Card(
                          elevation: 0,
                          child: ListTile(
                            leading: const Icon(Icons.phone_android),
                            title: Text(s.device, maxLines: 2, overflow: TextOverflow.ellipsis),
                            subtitle: Text([
                              if (s.isCurrent) 'Perangkat ini',
                              if (s.lastSeenAt != null)
                                'Aktif ${DateTimeUtils.formatDate(s.lastSeenAt!.toLocal())}',
                            ].join(' • ')),
                            trailing: s.isCurrent
                                ? null
                                : IconButton(
                                    tooltip: 'Cabut sesi',
                                    icon: const Icon(Icons.logout),
                                    onPressed: () => _revoke(s),
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
