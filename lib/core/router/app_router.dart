import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/models/session.dart';
import '../../features/auth/providers/session_provider.dart';
import '../../features/auth/screens/biometric_lock_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/feedback/screens/feedback_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/notification/screens/notification_settings_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/shell/screens/main_shell.dart';
import '../../features/worship/screens/worship_hub_screen.dart';
import 'route_names.dart';

/// Aturan pengalihan berdasarkan status sesi. Mengembalikan null bila lokasi
/// saat ini sudah benar.
@visibleForTesting
String? redirectFor(AuthStatus status, String location) {
  const authPages = {RouteNames.login, RouteNames.register};
  switch (status) {
    case AuthStatus.unknown:
      return location == RouteNames.splash ? null : RouteNames.splash;
    case AuthStatus.unauthenticated:
      return authPages.contains(location) ? null : RouteNames.login;
    case AuthStatus.locked:
      return location == RouteNames.lock ? null : RouteNames.lock;
    case AuthStatus.authenticated:
      final onEntryPage = location == RouteNames.splash ||
          location == RouteNames.lock ||
          authPages.contains(location);
      return onEntryPage ? RouteNames.home : null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen<SessionState>(sessionProvider, (_, __) => refresh.value++);

  final router = GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: refresh,
    redirect: (context, state) =>
        redirectFor(ref.read(sessionProvider).status, state.matchedLocation),
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.lock,
        builder: (_, __) => const BiometricLockScreen(),
      ),
      GoRoute(
        path: RouteNames.notificationSettings,
        builder: (_, __) => const NotificationSettingsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: RouteNames.home, builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.worship,
              builder: (_, __) => const WorshipHubScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.profile,
              builder: (_, __) => const ProfileScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.feedback,
              builder: (_, __) => const FeedbackScreen(),
            ),
          ]),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
