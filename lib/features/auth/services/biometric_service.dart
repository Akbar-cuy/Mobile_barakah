// M3 Login Biometrik (FR-BIO)
import 'package:local_auth/local_auth.dart';

import '../../../core/database/daos/settings_dao.dart';

enum BiometricAvailability { available, notEnrolled, unavailable }

abstract interface class BiometricAuthenticator {
  Future<BiometricAvailability> availability();
  Future<bool> authenticate({required String reason});
}

/// local_auth 3. Untuk versi 2, ganti pemanggilan authenticate dengan
/// options: AuthenticationOptions(biometricOnly: true, stickyAuth: true).
class LocalAuthAuthenticator implements BiometricAuthenticator {
  LocalAuthAuthenticator({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<BiometricAvailability> availability() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported || !await _auth.canCheckBiometrics) {
        return BiometricAvailability.unavailable;
      }
      final types = await _auth.getAvailableBiometrics();
      return types.isEmpty
          ? BiometricAvailability.notEnrolled
          : BiometricAvailability.available;
    } on Exception {
      return BiometricAvailability.unavailable;
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on Exception {
      return false;
    }
  }
}

class BiometricService {
  BiometricService({required this.authenticator, required this.settings});

  final BiometricAuthenticator authenticator;
  final SettingsDao settings;

  static const _kEnabled = 'biometric_enabled';
  static const _kOffered = 'biometric_offered';

  Future<bool> isEnabled() async => (await settings.get(_kEnabled)) == '1';

  Future<void> setEnabled(bool value) => settings.set(_kEnabled, value ? '1' : '0');

  Future<BiometricAvailability> availability() => authenticator.availability();

  Future<bool> authenticate(String reason) => authenticator.authenticate(reason: reason);

  /// Tawaran aktivasi hanya sekali, setelah login pertama bila perangkat
  /// mendukung dan biometrik belum aktif.
  Future<bool> shouldOffer() async {
    if (await isEnabled()) return false;
    if ((await settings.get(_kOffered)) == '1') return false;
    return (await availability()) == BiometricAvailability.available;
  }

  Future<void> markOffered() => settings.set(_kOffered, '1');
}
