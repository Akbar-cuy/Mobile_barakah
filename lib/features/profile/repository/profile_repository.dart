// M17 Profil (FR-PRO-02, FR-PRO-03, FR-PRO-06).
import 'dart:convert';
import 'dart:typed_data';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/database/daos/settings_dao.dart';
import '../../../core/network/api_client.dart';
import '../../auth/models/user.dart';

class ActiveSession {
  const ActiveSession({
    required this.id,
    required this.device,
    this.lastSeenAt,
    this.isCurrent = false,
  });

  factory ActiveSession.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('Session is missing its identifier.');
    }
    final device =
        (json['device'] ?? json['device_id'] ?? json['device_name'] ?? '')
            .toString()
            .trim();
    return ActiveSession(
      id: id,
      device: device.isEmpty ? 'Perangkat tidak dikenal' : device,
      lastSeenAt: DateTime.tryParse(
        '${json['last_seen_at'] ?? json['created_at'] ?? ''}',
      ),
      isCurrent: json['current'] == true || json['is_current'] == true,
    );
  }

  final String id;
  final String device;
  final DateTime? lastSeenAt;
  final bool isCurrent;
}

class ProfileRepository {
  ProfileRepository({required ApiGateway api, required SettingsDao settings})
      : _api = api,
        _settings = settings;

  final ApiGateway _api;
  final SettingsDao _settings;

  /// Same key used by AuthRepository for the cached user.
  static const _cachedUserKey = 'auth_user';

  Future<AppUser> update({
    required String name,
    required String username,
    String? avatarUrl,
  }) async {
    final response = await _api.request('PUT', ApiEndpoints.profile, body: {
      'name': name.trim(),
      'username': username.trim(),
      'avatar_url': (avatarUrl == null || avatarUrl.trim().isEmpty)
          ? null
          : avatarUrl.trim(),
    });
    final rawUser = response['user'];
    if (rawUser is! Map) {
      throw const FormatException('Profile response is missing user data.');
    }
    final user = AppUser.fromJson(Map<String, dynamic>.from(rawUser));
    await _settings.set(_cachedUserKey, jsonEncode(user.toJson()));
    return user;
  }

  /// Mengunggah foto profil. Server menyimpannya dan mengembalikan pengguna
  /// dengan tautan foto yang baru.
  Future<AppUser> uploadAvatar({
    required Uint8List bytes,
    required String contentType,
  }) async {
    final response = await _api.request(
      'POST',
      ApiEndpoints.profileAvatar,
      body: {'content_type': contentType, 'data': base64Encode(bytes)},
      receiveTimeout: const Duration(seconds: 60),
    );
    final rawUser = response['user'];
    if (rawUser is! Map) {
      throw const FormatException('Avatar response is missing user data.');
    }
    final user = AppUser.fromJson(Map<String, dynamic>.from(rawUser));
    await _settings.set(_cachedUserKey, jsonEncode(user.toJson()));
    return user;
  }

  Future<List<ActiveSession>> sessions() async {
    final response = await _api.request('GET', ApiEndpoints.authSessions);
    final rawSessions = response['items'] ?? response['sessions'];
    if (rawSessions is! List) {
      throw const FormatException('Sessions response is not a list.');
    }
    return rawSessions.map((item) {
      if (item is! Map) {
        throw const FormatException('Session item is not an object.');
      }
      return ActiveSession.fromJson(Map<String, dynamic>.from(item));
    }).toList(growable: false);
  }

  Future<void> revokeSession(String id) async {
    await _api.request('DELETE', ApiEndpoints.authSession(id));
  }
}
