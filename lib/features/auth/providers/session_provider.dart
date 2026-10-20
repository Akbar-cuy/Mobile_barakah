// M2 Manajemen Session (FR-SES)
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../models/session.dart';
import '../services/auto_lock_service.dart';
import '../services/session_service.dart';
import 'auth_provider.dart';

final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService(
    repository: ref.watch(authRepositoryProvider),
    biometric: ref.watch(biometricServiceProvider),
  );
});

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() {
    ref.listen<int>(sessionExpiredProvider, (_, __) => _onExpired());
    return const SessionState(status: AuthStatus.unknown);
  }

  SessionService get _service => ref.read(sessionServiceProvider);

  Future<void> bootstrap() async {
    state = await _service.bootstrap();
    _updateSync();
  }

  Future<void> login(String identifier, String password) async {
    state = await _service.login(identifier, password);
    _updateSync();
  }

  Future<bool> loginWithBiometric() async {
    final next = await _service.loginWithBiometric();
    if (next == null) return false;
    state = next;
    _updateSync();
    return true;
  }

  Future<bool> unlock() async {
    final next = await _service.unlock(state);
    if (next == null) return false;
    state = next;
    _updateSync();
    return true;
  }

  Future<void> lock() async {
    state = await _service.lock(state);
  }

  /// Dari layar kunci: pindah ke login kata sandi tanpa menghapus token.
  void usePassword() {
    state = const SessionState.unauthenticated();
    _updateSync();
  }

  Future<bool> enableBiometric(String password) {
    return _service.enableBiometric(password);
  }

  Future<void> dismissBiometricOffer() async {
    await ref.read(biometricServiceProvider).markOffered();
    state = state.copyWith(offerBiometric: false);
  }

  Future<void> logout(LogoutOptions options) async {
    ref.read(syncServiceProvider).stop();
    await _service.logout(options);
    state = const SessionState.unauthenticated();
  }

  void _onExpired() {
    if (state.status == AuthStatus.authenticated || state.status == AuthStatus.locked) {
      ref.read(syncServiceProvider).stop();
      state = const SessionState.unauthenticated(expired: true);
    }
  }

  void _updateSync() {
    final sync = ref.read(syncServiceProvider);
    if (state.status == AuthStatus.authenticated) {
      sync.start();
      unawaited(sync.syncNow());
    } else {
      sync.stop();
    }
  }
}

final sessionProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

final autoLockServiceProvider = Provider<AutoLockService>((ref) {
  final service = AutoLockService(
    onLock: () => ref.read(sessionProvider.notifier).lock(),
  )..start();
  ref.onDispose(service.stop);
  return service;
});
