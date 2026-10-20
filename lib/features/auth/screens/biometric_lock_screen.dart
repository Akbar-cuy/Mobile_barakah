import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/status_banner.dart';
import '../providers/session_provider.dart';

class BiometricLockScreen extends ConsumerStatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  ConsumerState<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen> {
  int _failures = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _unlock() async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await ref.read(sessionProvider.notifier).unlock();
    if (mounted && !ok) {
      setState(() {
        _busy = false;
        _failures++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final tooMany = _failures >= AppConstants.maxBiometricAttempts;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [s.primaryContainer, s.surface],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Aplikasi terkunci', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Sentuh sensor untuk membuka Barakah.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                IconButton.filled(
                  iconSize: 44,
                  padding: const EdgeInsets.all(26),
                  tooltip: 'Verifikasi sidik jari atau wajah',
                  onPressed: _busy ? null : _unlock,
                  icon: const Icon(Icons.fingerprint),
                ),
                const SizedBox(height: 24),
                if (tooMany) ...[
                  const StatusBanner(
                    message: 'Verifikasi gagal beberapa kali. Gunakan kata sandi.',
                    kind: BannerKind.warning,
                  ),
                  const SizedBox(height: 12),
                ],
                TextButton(
                  onPressed: () => ref.read(sessionProvider.notifier).usePassword(),
                  child: const Text('Gunakan kata sandi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
