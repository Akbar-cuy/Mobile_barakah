// Keamanan: FR-AUTH-07, FR-SES-02
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';
import '../network/token_store.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore(this._storage);

  final SecureStorageService _storage;

  @override
  Future<String?> readAccessToken() => _storage.read(SecureKeys.accessToken);

  @override
  Future<String?> readRefreshToken() => _storage.read(SecureKeys.refreshToken);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(SecureKeys.accessToken, accessToken);
    await _storage.write(SecureKeys.refreshToken, refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(SecureKeys.accessToken);
    await _storage.delete(SecureKeys.refreshToken);
  }
}
