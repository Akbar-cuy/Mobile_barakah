// M1 Registrasi dan Login (FR-AUTH), M3 Login Biometrik (FR-BIO)
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failure.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../repository/auth_repository.dart';
import '../services/biometric_service.dart';
import 'session_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository(
    api: ref.watch(apiGatewayProvider),
    tokens: ref.watch(tokenStoreProvider),
    storage: ref.watch(secureStorageProvider),
    encryption: ref.watch(encryptionServiceProvider),
    settings: ref.watch(settingsDaoProvider),
    outbox: ref.watch(outboxDaoProvider),
    wipeLocalData: () => ref.read(appDatabaseProvider).clearAllData(),
  );
});

final biometricAuthenticatorProvider =
    Provider<BiometricAuthenticator>((ref) => LocalAuthAuthenticator());

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService(
    authenticator: ref.watch(biometricAuthenticatorProvider),
    settings: ref.watch(settingsDaoProvider),
  );
});

class AuthFormState {
  const AuthFormState({this.isLoading = false, this.failure});

  final bool isLoading;
  final Failure? failure;
}

/// Status formulir login dan registrasi (memuat dan galat).
class AuthFormController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  void reset() => state = const AuthFormState();

  Future<bool> login(String identifier, String password) {
    return _run(() => ref.read(sessionProvider.notifier).login(identifier, password));
  }

  Future<bool> loginWithBiometric() {
    return _run(() async {
      final ok = await ref.read(sessionProvider.notifier).loginWithBiometric();
      if (!ok) throw ApiException.of(ApiErrorKind.cancelled, message: 'Verifikasi biometrik dibatalkan.');
    });
  }

  Future<bool> register({
    required String name,
    required String email,
    required String username,
    required String password,
  }) {
    return _run(() async {
      await ref.read(authRepositoryProvider).register(
            name: name,
            email: email,
            username: username,
            password: password,
          );
    });
  }

  Future<bool> _run(Future<void> Function() action) async {
    state = const AuthFormState(isLoading: true);
    try {
      await action();
      state = const AuthFormState();
      return true;
    } on ApiException catch (e) {
      state = AuthFormState(failure: e.failure);
    } catch (e) {
      state = AuthFormState(failure: UnknownFailure(e.toString()));
    }
    return false;
  }
}

final authFormProvider =
    NotifierProvider<AuthFormController, AuthFormState>(AuthFormController.new);
