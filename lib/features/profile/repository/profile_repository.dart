// M17 Profil (FR-PRO-02, FR-PRO-03). GET dan PUT /profile.
import 'dart:convert';

import '../../../core/database/daos/settings_dao.dart';
import '../../../core/network/api_client.dart';
import '../../auth/models/user.dart';

class ProfileRepository {
  ProfileRepository({required ApiGateway api, required SettingsDao settings})
      : _api = api,
        _settings = settings;

  final ApiGateway _api;
  final SettingsDao _settings;

  static const _path = '/profile';

  /// Sama dengan kunci cache pengguna di AuthRepository.
  static const _cachedUserKey = 'auth_user';

  Future<AppUser> update({
    required String name,
    required String username,
    String? avatarUrl,
  }) async {
    final res = await _api.request('PUT', _path, body: {
      'name': name.trim(),
      'username': username.trim(),
      'avatar_url': (avatarUrl == null || avatarUrl.trim().isEmpty) ? null : avatarUrl.trim(),
    });
    final user = AppUser.fromJson((res['user'] as Map).cast<String, dynamic>());
    await _settings.set(_cachedUserKey, jsonEncode(user.toJson()));
    return user;
  }
}
