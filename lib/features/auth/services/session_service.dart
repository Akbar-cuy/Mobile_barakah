// M2 Manajemen Session dan M3 Login Biometrik (FR-SES, FR-BIO, FR-OUT)
import '../models/session.dart';
import '../repository/auth_repository.dart';
import 'biometric_service.dart';

/// Logika sesi tanpa ketergantungan pada Riverpod, sehingga mudah diuji.
class SessionService {
  SessionService({required this.repository, required this.biometric});

  final AuthRepository repository;
  final BiometricService biometric;

  /// FR-SES-08. Dengan biometrik aktif, aplikasi yang dibuka dari kondisi
  /// tertutup menampilkan layar kunci (FR-SES-06).
  Future<SessionState> bootstrap() async {
    if (!await repository.hasSession()) return const SessionState.unauthenticated();
    final user = await repository.cachedUser();
    final locked = await biometric.isEnabled();
    return SessionState(
      status: locked ? AuthStatus.locked : AuthStatus.authenticated,
      user: user,
    );
  }

  Future<SessionState> login(String identifier, String password) async {
    final user = await repository.login(identifier: identifier, password: password);
    return SessionState(
      status: AuthStatus.authenticated,
      user: user,
      offerBiometric: await biometric.shouldOffer(),
    );
  }

  Future<bool> canBiometricLogin() async {
    if (!await biometric.isEnabled() || !await repository.hasDeviceToken()) {
      return false;
    }
    return (await biometric.availability()) == BiometricAvailability.available;
  }

  /// Null bila verifikasi biometrik gagal atau dibatalkan.
  Future<SessionState?> loginWithBiometric() async {
    if (!await biometric.authenticate('Masuk ke Barakah')) return null;
    final user = await repository.loginWithDeviceToken();
    return SessionState(status: AuthStatus.authenticated, user: user);
  }

  Future<SessionState?> unlock(SessionState current) async {
    if (!await biometric.authenticate('Buka kunci Barakah')) return null;
    return current.copyWith(status: AuthStatus.authenticated);
  }

  /// Layar kunci hanya dipakai bila biometrik aktif.
  Future<SessionState> lock(SessionState current) async {
    if (current.status != AuthStatus.authenticated) return current;
    if (!await biometric.isEnabled()) return current;
    return current.copyWith(status: AuthStatus.locked);
  }

  /// FR-BIO-02: kata sandi dan verifikasi biometrik diminta sebelum aktivasi.
  Future<bool> enableBiometric(String password) async {
    if (!await biometric.authenticate('Aktifkan login biometrik')) return false;
    await repository.enableBiometric(password: password);
    await biometric.setEnabled(true);
    return true;
  }

  Future<void> logout(LogoutOptions options) async {
    // Dicabut lebih dulu karena membutuhkan sesi yang masih berlaku. Data lokal
    // yang dihapus juga menghapus penanda biometrik, jadi token perangkat ikut dicabut.
    if (options.disableBiometric || options.clearLocalData) {
      await repository.disableBiometric();
      await biometric.setEnabled(false);
    }
    await repository.logout(clearLocalData: options.clearLocalData);
  }
}
