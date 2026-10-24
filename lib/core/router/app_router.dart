import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai_chat/screens/ai_chat_screen.dart';
import '../../features/auth/models/session.dart';
import '../../features/auth/providers/session_provider.dart';
import '../../features/auth/screens/biometric_lock_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/converter/screens/converter_screen.dart';
import '../../features/donation/screens/donation_screen.dart';
import '../../features/feedback/screens/feedback_screen.dart';
import '../../features/games/screens/direction_game_screen.dart';
import '../../features/games/screens/quiz_category_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/iot/screens/iot_screen.dart';
import '../../features/ledger/screens/block_detail_screen.dart';
import '../../features/ledger/screens/ledger_screen.dart';
import '../../features/mosque/screens/mosque_screen.dart';
import '../../features/notification/screens/notification_settings_screen.dart';
import '../../features/profile/screens/change_password_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/security_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/qibla/screens/qibla_screen.dart';
import '../../features/shell/screens/main_shell.dart';
import '../../features/tasbih/screens/tasbih_history_screen.dart';
import '../../features/tasbih/screens/tasbih_screen.dart';
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
      GoRoute(path: RouteNames.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: RouteNames.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: RouteNames.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(path: RouteNames.lock, builder: (_, __) => const BiometricLockScreen()),
      GoRoute(
        path: RouteNames.notificationSettings,
        builder: (_, __) => const NotificationSettingsScreen(),
      ),
      GoRoute(path: RouteNames.mosque, builder: (_, __) => const MosqueScreen()),
      GoRoute(path: RouteNames.qibla, builder: (_, __) => const QiblaScreen()),
      GoRoute(
        path: RouteNames.tasbih,
        builder: (_, __) => const TasbihScreen(),
        routes: [
          GoRoute(
            path: 'riwayat',
            builder: (_, __) => const TasbihHistoryScreen(),
          ),
        ],
      ),
      GoRoute(path: RouteNames.converter, builder: (_, __) => const ConverterScreen()),
      GoRoute(path: RouteNames.donation, builder: (_, __) => const DonationScreen()),
      GoRoute(path: RouteNames.zakat, builder: (_, __) => const DonationScreen()),
      GoRoute(path: RouteNames.aiChat, builder: (_, __) => const AiChatScreen()),
      GoRoute(path: RouteNames.quiz, builder: (_, __) => const QuizCategoryScreen()),
      GoRoute(
        path: RouteNames.directionGame,
        builder: (_, __) => const DirectionGameScreen(),
      ),
      GoRoute(
        path: RouteNames.ledger,
        builder: (_, __) => const LedgerScreen(),
        routes: [
          GoRoute(
            path: 'blok/:index',
            builder: (_, state) => BlockDetailScreen(
              index: int.tryParse(state.pathParameters['index'] ?? '') ?? -1,
            ),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.editProfile,
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.changePassword,
        builder: (_, __) => const ChangePasswordScreen(),
      ),
      GoRoute(path: RouteNames.security, builder: (_, __) => const SecurityScreen()),
      GoRoute(path: RouteNames.settings, builder: (_, __) => const SettingsScreen()),
      GoRoute(path: RouteNames.iot, builder: (_, __) => const IotScreen()),
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
