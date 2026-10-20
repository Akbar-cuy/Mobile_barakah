// M1, M2, M3, M19 (FR-AUTH, FR-SES, FR-BIO, FR-OUT)
import 'dart:convert';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/daos/outbox_dao.dart';
import '../../../core/database/daos/settings_dao.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/token_store.dart';
import '../../../core/security/encryption_service.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../../core/sync/sync_status.dart';
import '../models/auth_tokens.dart';
import '../models/user.dart';

abstract interface class AuthRepository {
  Future<bool> hasSession();
  Future<AppUser?> cachedUser();
  Future<AppUser> register({
    required String name,
    required String email,
    required String username,
    required String password,
  });
  Future<AppUser> login({required String identifier, required String password});
  Future<bool> hasDeviceToken();
  Future<AppUser> loginWithDeviceToken();
  Future<void> enableBiometric({required String password});
  Future<void> disableBiometric();
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
  Future<void> logout({bool clearLocalData = false});
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({
    required this.api,
    required this.tokens,
    required this.storage,
    required this.encryption,
    required this.settings,
    required this.outbox,
    required this.wipeLocalData,
  });

  final ApiGateway api;
  final TokenStore tokens;
  final SecureStorageService storage;
  final EncryptionService encryption;
  final SettingsDao settings;
  final OutboxDao outbox;
  final Future<void> Function() wipeLocalData;

  static const _kUser = 'auth_user';

  @override
  Future<bool> hasSession() async => (await tokens.readRefreshToken()) != null;

  @override
  Future<AppUser?> cachedUser() async {
    final raw = await settings.get(_kUser);
    if (raw == null) return null;
    try {
      return AppUser.fromJson((jsonDecode(raw) as Map).cast<String, dynamic>());
    } on FormatException {
      return null;
    }
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String username,
    required String password,
  }) async {
    final res = await api.request('POST', ApiEndpoints.register, body: {
      'name': name,
      'email': email,
      'username': username,
      'password': password,
    });
    return _userOf(res);
  }

  @override
  Future<AppUser> login({
    required String identifier,
    required String password,
  }) async {
    final deviceId = await encryption.getOrCreateDeviceId();
    final res = await api.request('POST', ApiEndpoints.login, body: {
      'identifier': identifier,
      'password': password,
      'device_id': deviceId,
    });
    return _startSession(res);
  }

  @override
  Future<bool> hasDeviceToken() async =>
      (await storage.read(SecureKeys.deviceToken)) != null;

  @override
  Future<AppUser> loginWithDeviceToken() async {
    final token = await storage.read(SecureKeys.deviceToken);
    if (token == null) throw ApiException.of(ApiErrorKind.unauthorized);
    final deviceId = await encryption.getOrCreateDeviceId();
    try {
      final res = await api.request('POST', ApiEndpoints.biometricLogin, body: {
        'device_id': deviceId,
        'device_token': token,
      });
      return _startSession(res);
    } on ApiException catch (e) {
      if (e.kind == ApiErrorKind.unauthorized) {
        await storage.delete(SecureKeys.deviceToken);
      }
      rethrow;
    }
  }

  @override
  Future<void> enableBiometric({required String password}) async {
    final deviceId = await encryption.getOrCreateDeviceId();
    final res = await api.request('POST', ApiEndpoints.biometricEnable, body: {
      'device_id': deviceId,
      'password': password,
    });
    await storage.write(SecureKeys.deviceToken, res['device_token'].toString());
  }

  @override
  Future<void> disableBiometric() async {
    final deviceId = await encryption.getOrCreateDeviceId();
    try {
      await api.request(
        'DELETE',
        ApiEndpoints.biometricDisable,
        query: {'device_id': deviceId},
      );
    } on ApiException catch (e) {
      if (!e.isConnectivity && e.kind != ApiErrorKind.unauthorized) rethrow;
    }
    await storage.delete(SecureKeys.deviceToken);
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await api.request('POST', ApiEndpoints.changePassword, body: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }

  /// Mencabut sesi di server, lalu menghapus token lokal. Bila offline,
  /// pencabutan dijadwalkan lewat outbox (FR-OUT-06).
  @override
  Future<void> logout({bool clearLocalData = false}) async {
    final refresh = await tokens.readRefreshToken();
    await tokens.clear();
    await settings.remove(_kUser);
    if (clearLocalData) await wipeLocalData();
    if (refresh == null) return;
    try {
      await api.request(
        'POST',
        ApiEndpoints.logout,
        body: {'refresh_token': refresh},
      );
    } on ApiException catch (e) {
      if (e.isConnectivity) {
        await outbox.enqueue(
          entity: OutboxEntity.sessionRevoke,
          op: OutboxOp.create,
          payload: jsonEncode({'refresh_token': refresh}),
        );
      }
    }
  }

  Future<AppUser> _startSession(Map<String, dynamic> res) async {
    final t = AuthTokens.fromJson(res);
    await tokens.saveTokens(accessToken: t.accessToken, refreshToken: t.refreshToken);
    final user = _userOf(res);
    await settings.set(_kUser, jsonEncode(user.toJson()));
    return user;
  }

  AppUser _userOf(Map<String, dynamic> res) {
    return AppUser.fromJson((res['user'] as Map).cast<String, dynamic>());
  }
}
