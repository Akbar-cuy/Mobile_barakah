import 'package:barakah/core/constants/api_endpoints.dart';
import 'package:barakah/core/constants/app_constants.dart';
import 'package:barakah/core/database/app_database.dart';
import 'package:barakah/core/network/api_client.dart';
import 'package:barakah/core/network/api_exception.dart';
import 'package:barakah/core/network/token_store.dart';
import 'package:barakah/core/security/encryption_service.dart';
import 'package:barakah/core/security/secure_storage_service.dart';
import 'package:barakah/core/sync/sync_status.dart';
import 'package:barakah/features/auth/repository/auth_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSecureStorage extends SecureStorageService {
  final data = <String, String>{};

  @override
  Future<String?> read(String key) async => data[key];

  @override
  Future<void> write(String key, String value) async => data[key] = value;

  @override
  Future<void> delete(String key) async => data.remove(key);
}

class FakeTokenStore implements TokenStore {
  String? access;
  String? refresh;

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

class FakeGateway implements ApiGateway {
  final calls = <({String method, String path, Object? body, Map<String, Object?>? query})>[];
  final responses = <String, Map<String, dynamic>>{};
  ApiException? failWith;
  String? failOnPath;

  @override
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Duration? receiveTimeout,
  }) async {
    calls.add((method: method, path: path, body: body, query: query));
    if (failWith != null && (failOnPath == null || failOnPath == path)) {
      throw failWith!;
    }
    return responses[path] ?? const {};
  }
}

const _loginResponse = {
  'access_token': 'access-1',
  'refresh_token': 'refresh-1',
  'expires_in': 900,
  'user': {
    'id': 'u1',
    'name': 'Rizky Pratama',
    'username': 'rizky',
    'email': 'rizky@mail.com',
  },
};

void main() {
  late AppDatabase db;
  late FakeGateway api;
  late FakeTokenStore tokens;
  late FakeSecureStorage storage;
  late ApiAuthRepository repo;
  var wiped = false;

  setUp(() {
    wiped = false;
    db = AppDatabase(NativeDatabase.memory());
    api = FakeGateway();
    tokens = FakeTokenStore();
    storage = FakeSecureStorage();
    repo = ApiAuthRepository(
      api: api,
      tokens: tokens,
      storage: storage,
      encryption: EncryptionService(storage),
      settings: db.settingsDao,
      outbox: db.outboxDao,
      wipeLocalData: () async => wiped = true,
    );
  });

  tearDown(() => db.close());

  test('login menyimpan token, menyimpan pengguna, dan mengirim device_id', () async {
    api.responses[ApiEndpoints.login] = _loginResponse;
    final user = await repo.login(identifier: 'rizky', password: 'abcd1234');

    expect(user.name, 'Rizky Pratama');
    expect(tokens.access, 'access-1');
    expect(tokens.refresh, 'refresh-1');
    expect(await repo.hasSession(), isTrue);
    expect((await repo.cachedUser())?.username, 'rizky');

    final body = api.calls.single.body as Map;
    expect(body['identifier'], 'rizky');
    expect(body['device_id'], storage.data[SecureKeys.deviceId]);
  });

  test('register tidak menyimpan token', () async {
    api.responses[ApiEndpoints.register] = {
      'user': {'id': 'u2', 'name': 'Siti', 'username': 'siti', 'email': 's@mail.com'},
    };
    final user = await repo.register(
      name: 'Siti',
      email: 's@mail.com',
      username: 'siti',
      password: 'abcd1234',
    );
    expect(user.id, 'u2');
    expect(tokens.access, isNull);
  });

  test('AC-OUT-03: logout menghapus token dan mencabut sesi di server', () async {
    tokens
      ..access = 'a'
      ..refresh = 'r';
    await repo.logout();
    expect(tokens.access, isNull);
    expect(tokens.refresh, isNull);
    final call = api.calls.single;
    expect(call.path, ApiEndpoints.logout);
    expect((call.body as Map)['refresh_token'], 'r');
    expect(await db.outboxDao.pendingCount(), 0);
  });

  test('AC-OUT-04: logout offline menjadwalkan pencabutan lewat outbox', () async {
    tokens.refresh = 'r';
    api.failWith = ApiException.of(ApiErrorKind.network);
    await repo.logout();
    expect(tokens.refresh, isNull);
    final due = await db.outboxDao.getDue(now: DateTime.now().add(const Duration(days: 1)));
    expect(due.single.entity, OutboxEntity.sessionRevoke);
    expect(due.single.payload, contains('"refresh_token":"r"'));
  });

  test('logout dengan hapus data memanggil pembersih data lokal', () async {
    tokens.refresh = 'r';
    await repo.logout(clearLocalData: true);
    expect(wiped, isTrue);
  });

  test('enableBiometric menyimpan token perangkat', () async {
    api.responses[ApiEndpoints.biometricEnable] = {'device_token': 'dev-1'};
    await repo.enableBiometric(password: 'abcd1234');
    expect(await repo.hasDeviceToken(), isTrue);
    expect(storage.data[SecureKeys.deviceToken], 'dev-1');
    expect((api.calls.single.body as Map)['password'], 'abcd1234');
  });

  test('disableBiometric menghapus token perangkat', () async {
    storage.data[SecureKeys.deviceToken] = 'dev-1';
    await repo.disableBiometric();
    expect(await repo.hasDeviceToken(), isFalse);
    expect(api.calls.single.method, 'DELETE');
  });

  test('loginWithDeviceToken ditolak: token perangkat dihapus', () async {
    storage.data[SecureKeys.deviceToken] = 'dev-1';
    api.failWith = ApiException.of(ApiErrorKind.unauthorized);
    await expectLater(
      repo.loginWithDeviceToken(),
      throwsA(isA<ApiException>()),
    );
    expect(await repo.hasDeviceToken(), isFalse);
  });
}
