import 'package:barakah/core/database/app_database.dart';
import 'package:barakah/features/auth/models/session.dart';
import 'package:barakah/features/auth/models/user.dart';
import 'package:barakah/features/auth/repository/auth_repository.dart';
import 'package:barakah/features/auth/services/biometric_service.dart';
import 'package:barakah/features/auth/services/session_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = AppUser(id: 'u1', name: 'Rizky Pratama', username: 'rizky');

class FakeAuthRepository implements AuthRepository {
  bool session = false;
  bool deviceToken = false;
  final calls = <String>[];
  String? enabledWithPassword;

  @override
  Future<bool> hasSession() async => session;

  @override
  Future<AppUser?> cachedUser() async => _user;

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String username,
    required String password,
  }) async =>
      _user;

  @override
  Future<AppUser> login({required String identifier, required String password}) async {
    calls.add('login');
    return _user;
  }

  @override
  Future<bool> hasDeviceToken() async => deviceToken;

  @override
  Future<AppUser> loginWithDeviceToken() async {
    calls.add('loginWithDeviceToken');
    return _user;
  }

  @override
  Future<void> enableBiometric({required String password}) async {
    calls.add('enableBiometric');
    enabledWithPassword = password;
  }

  @override
  Future<void> disableBiometric() async => calls.add('disableBiometric');

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {}

  @override
  Future<void> logout({bool clearLocalData = false}) async => calls.add('logout');
}

class FakeAuthenticator implements BiometricAuthenticator {
  BiometricAvailability available = BiometricAvailability.available;
  bool succeeds = true;

  @override
  Future<BiometricAvailability> availability() async => available;

  @override
  Future<bool> authenticate({required String reason}) async => succeeds;
}

void main() {
  late AppDatabase db;
  late FakeAuthRepository repo;
  late FakeAuthenticator authenticator;
  late BiometricService biometric;
  late SessionService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = FakeAuthRepository();
    authenticator = FakeAuthenticator();
    biometric = BiometricService(authenticator: authenticator, settings: db.settingsDao);
    service = SessionService(repository: repo, biometric: biometric);
  });

  tearDown(() => db.close());

  group('bootstrap', () {
    test('tanpa sesi: belum masuk', () async {
      final s = await service.bootstrap();
      expect(s.status, AuthStatus.unauthenticated);
    });

    test('AC-SES-01: sesi tersimpan tanpa biometrik langsung masuk', () async {
      repo.session = true;
      final s = await service.bootstrap();
      expect(s.status, AuthStatus.authenticated);
      expect(s.user?.name, 'Rizky Pratama');
    });

    test('sesi tersimpan dengan biometrik aktif: layar kunci', () async {
      repo.session = true;
      await biometric.setEnabled(true);
      final s = await service.bootstrap();
      expect(s.status, AuthStatus.locked);
    });
  });

  group('login', () {
    test('masuk dan menawarkan biometrik bila tersedia dan belum aktif', () async {
      final s = await service.login('rizky', 'abcd1234');
      expect(s.status, AuthStatus.authenticated);
      expect(s.offerBiometric, isTrue);
    });

    test('tidak menawarkan lagi setelah pernah ditawarkan', () async {
      await biometric.markOffered();
      final s = await service.login('rizky', 'abcd1234');
      expect(s.offerBiometric, isFalse);
    });

    test('tidak menawarkan bila perangkat tidak mendukung', () async {
      authenticator.available = BiometricAvailability.notEnrolled;
      final s = await service.login('rizky', 'abcd1234');
      expect(s.offerBiometric, isFalse);
    });
  });

  group('kunci', () {
    test('AC-SES-05: mengunci hanya bila biometrik aktif', () async {
      const current = SessionState(status: AuthStatus.authenticated, user: _user);
      expect((await service.lock(current)).status, AuthStatus.authenticated);
      await biometric.setEnabled(true);
      expect((await service.lock(current)).status, AuthStatus.locked);
    });

    test('unlock berhasil dan gagal', () async {
      const locked = SessionState(status: AuthStatus.locked, user: _user);
      authenticator.succeeds = false;
      expect(await service.unlock(locked), isNull);
      authenticator.succeeds = true;
      expect((await service.unlock(locked))?.status, AuthStatus.authenticated);
    });
  });

  group('biometrik', () {
    test('canBiometricLogin butuh biometrik aktif dan token perangkat', () async {
      expect(await service.canBiometricLogin(), isFalse);
      await biometric.setEnabled(true);
      expect(await service.canBiometricLogin(), isFalse);
      repo.deviceToken = true;
      expect(await service.canBiometricLogin(), isTrue);
    });

    test('enableBiometric dibatalkan: server tidak dipanggil', () async {
      authenticator.succeeds = false;
      expect(await service.enableBiometric('abcd1234'), isFalse);
      expect(repo.calls, isEmpty);
      expect(await biometric.isEnabled(), isFalse);
    });

    test('enableBiometric berhasil mengirim kata sandi dan mengaktifkan', () async {
      expect(await service.enableBiometric('abcd1234'), isTrue);
      expect(repo.enabledWithPassword, 'abcd1234');
      expect(await biometric.isEnabled(), isTrue);
    });

    test('loginWithBiometric dibatalkan mengembalikan null', () async {
      authenticator.succeeds = false;
      expect(await service.loginWithBiometric(), isNull);
      expect(repo.calls, isEmpty);
    });
  });

  group('logout', () {
    test('biometrik dicabut sebelum sesi diakhiri', () async {
      await biometric.setEnabled(true);
      await service.logout(const LogoutOptions(disableBiometric: true));
      expect(repo.calls, ['disableBiometric', 'logout']);
      expect(await biometric.isEnabled(), isFalse);
    });

    test('logout biasa tidak menyentuh biometrik', () async {
      await biometric.setEnabled(true);
      await service.logout(const LogoutOptions());
      expect(repo.calls, ['logout']);
      expect(await biometric.isEnabled(), isTrue);
    });
  });
}
