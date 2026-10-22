import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/session_provider.dart';
import '../../auth/widgets/biometric_offer_dialog.dart';
import '../../auth/widgets/logout_dialog.dart';
import '../../ledger/providers/ledger_provider.dart';
import '../../notification/providers/notification_provider.dart';
import '../widgets/app_bottom_nav.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _offerBiometric());
  }

  Future<void> _offerBiometric() async {
    if (!mounted || !ref.read(sessionProvider).offerBiometric) return;
    await ref.read(sessionProvider.notifier).dismissBiometricOffer();
    if (mounted) await showBiometricOfferDialog(context);
  }

  Future<void> _logout() async {
    final options = await showLogoutDialog(context);
    if (options == null) return;
    await ref.read(sessionProvider.notifier).logout(options);
  }

  @override
  Widget build(BuildContext context) {
    // Layanan latar yang hidup selama pengguna berada di shell.
    ref.watch(ledgerConflictWatcherProvider);
    ref.watch(notificationRescheduleWatcherProvider);
    final shell = widget.navigationShell;
    return Scaffold(
      body: shell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: shell.currentIndex,
        onTabSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        onLogout: _logout,
      ),
    );
  }
}
