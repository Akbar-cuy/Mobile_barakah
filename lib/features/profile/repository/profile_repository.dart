// M17 Profil (FR-PRO-01..06)
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

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

  factory ActiveSession.fromJson(Map<String, dynamic> j) {
    final device = (j['device'] ?? j['user_agent'] ?? j['device_name'] ?? '').toString().trim();
    return ActiveSession(
      id: j['id'].toString(),
      device: device.isEmpty ? 'Perangkat tidak dikenal' : device,
      lastSeenAt: DateTime.tryParse('${j['last_seen_at'] ?? j['last_used_at'] ?? j['created_at']}'),
      isCurrent: j['current'] == true || j['is_current'] == true,
    );
  }

  final String id;
  final String device;
  final DateTime? lastSeenAt;
  final bool isCurrent;
}

abstract interface class ProfileRepository {
  Future<AppUser> update({required String name, required String username, required String email});
  Future<AppUser> uploadAvatar(Uint8List bytes, String filename);
  Future<List<ActiveSession>> sessions();
  Future<void> revokeSession(String id);
}

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository({required this.api, required this.settings});

  final ApiGateway api;
  final SettingsDao settings;

  /// Kunci yang sama dengan cache pengguna milik modul auth.
  static const _kUser = 'auth_user';

  AppUser _userOf(Map<String, dynamic> res) {
    final raw = res['user'] ?? res['data'] ?? res;
    return AppUser.fromJson((raw as Map).cast<String, dynamic>());
  }

  Future<AppUser> _cache(AppUser u) async {
    await settings.set(_kUser, jsonEncode(u.toJson()));
    return u;
  }

  @override
  Future<AppUser> update({
    required String name,
    required String username,
    required String email,
  }) async {
    final res = await api.request('PUT', ApiEndpoints.profile, body: {
      'name': name.trim(),
      'username': username.trim(),
      'email': email.trim(),
    });
    return _cache(_userOf(res));
  }

  @override
  Future<AppUser> uploadAvatar(Uint8List bytes, String filename) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final res = await api.request('POST', ApiEndpoints.profileAvatar, body: form);
    return _cache(_userOf(res));
  }

  @override
  Future<List<ActiveSession>> sessions() async {
    final res = await api.request('GET', ApiEndpoints.authSessions);
    final raw = res['items'] ?? res['sessions'] ?? res['data'] ?? const [];
    return [
      for (final e in raw as List) ActiveSession.fromJson((e as Map).cast<String, dynamic>()),
    ];
  }

  @override
  Future<void> revokeSession(String id) async {
    await api.request('DELETE', ApiEndpoints.authSession(id));
  }
}
