// M17 Profil
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/sync/sync_status.dart';
import '../../auth/models/user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/session_provider.dart';
import '../../auth/services/biometric_service.dart';
import '../repository/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    api: ref.watch(apiGatewayProvider),
    settings: ref.watch(settingsDaoProvider),
  );
});

final currentUserProvider = Provider<AppUser?>(
  (ref) => ref.watch(sessionProvider.select((session) => session.user)),
);

final activeSessionsProvider = FutureProvider.autoDispose<List<ActiveSession>>(
  (ref) => ref.watch(profileRepositoryProvider).sessions(),
);

/// Sinkronisasi status stream untuk Settings (FR-SYNC-07).
final syncStatusProvider = StreamProvider<SyncStatus>((ref) async* {
  final service = ref.watch(syncServiceProvider);
  yield service.status;
  yield* service.statusStream;
});

class BiometricStatus {
  const BiometricStatus({required this.enabled, required this.availability});

  final bool enabled;
  final BiometricAvailability availability;
}

final biometricStatusProvider = FutureProvider<BiometricStatus>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return BiometricStatus(
    enabled: await service.isEnabled(),
    availability: await service.availability(),
  );
});

class ProfileActionState {
  const ProfileActionState({this.busy = false, this.error});

  final bool busy;
  final String? error;
}

String _messageOf(Object error) {
  if (error is ApiException) {
    return error.isConnectivity
        ? 'Tidak ada koneksi. Coba lagi saat online.'
        : error.message;
  }
  return 'Terjadi kesalahan. Coba lagi.';
}

class ProfileController extends Notifier<ProfileActionState> {
  @override
  ProfileActionState build() => const ProfileActionState();

  Future<bool> _run(Future<void> Function() action) async {
    state = const ProfileActionState(busy: true);
    try {
      await action();
      state = const ProfileActionState();
      return true;
    } on Object catch (error) {
      state = ProfileActionState(error: _messageOf(error));
      return false;
    }
  }

  Future<bool> save({
    required String name,
    required String username,
    String? avatarUrl,
  }) {
    return _run(() async {
      final user = await ref.read(profileRepositoryProvider).update(
            name: name,
            username: username,
            avatarUrl: avatarUrl,
          );
      ref.read(sessionProvider.notifier).updateUser(user);
    });
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return _run(
      () => ref.read(authRepositoryProvider).changePassword(
            oldPassword: oldPassword,
            newPassword: newPassword,
          ),
    );
  }

  Future<bool> revokeSession(String id) {
    return _run(() async {
      await ref.read(profileRepositoryProvider).revokeSession(id);
      ref.invalidate(activeSessionsProvider);
    });
  }

  void clearError() => state = const ProfileActionState();
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileActionState>(
  ProfileController.new,
);
