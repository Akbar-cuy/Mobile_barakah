// M17 Profil (FR-PRO-01..06)
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../../auth/models/user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/session_provider.dart';
import '../repository/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ApiProfileRepository(
    api: ref.watch(apiGatewayProvider),
    settings: ref.watch(settingsDaoProvider),
  );
});

/// Pengguna yang sedang masuk, mengikuti sesi.
final currentUserProvider = Provider<AppUser?>(
  (ref) => ref.watch(sessionProvider.select((s) => s.user)),
);

final activeSessionsProvider = FutureProvider.autoDispose<List<ActiveSession>>(
  (ref) => ref.watch(profileRepositoryProvider).sessions(),
);

class ProfileActionState {
  const ProfileActionState({this.busy = false, this.error});

  final bool busy;
  final String? error;
}

String _messageOf(Object e) {
  if (e is ApiException) {
    return e.isConnectivity ? 'Tidak ada koneksi. Coba lagi saat online.' : e.message;
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
    } catch (e) {
      state = ProfileActionState(error: _messageOf(e));
      return false;
    }
  }

  Future<bool> save({required String name, required String username, required String email}) {
    return _run(() async {
      final user = await ref
          .read(profileRepositoryProvider)
          .update(name: name, username: username, email: email);
      ref.read(sessionProvider.notifier).updateUser(user);
    });
  }

  Future<bool> setAvatar(Uint8List bytes, String filename) {
    return _run(() async {
      final user = await ref.read(profileRepositoryProvider).uploadAvatar(bytes, filename);
      ref.read(sessionProvider.notifier).updateUser(user);
    });
  }

  Future<bool> changePassword({required String oldPassword, required String newPassword}) {
    return _run(() => ref
        .read(authRepositoryProvider)
        .changePassword(oldPassword: oldPassword, newPassword: newPassword));
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
    NotifierProvider<ProfileController, ProfileActionState>(ProfileController.new);
