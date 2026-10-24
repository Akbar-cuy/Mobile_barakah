import 'package:barakah/core/database/app_database.dart';
import 'package:barakah/core/network/api_client.dart';
import 'package:barakah/core/network/api_exception.dart';
import 'package:barakah/features/converter/repository/rate_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGateway implements ApiGateway {
  Map<String, dynamic>? response;
  Object? error;
  final calls = <(String, String, Map<String, Object?>?)>[];

  @override
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Duration? receiveTimeout,
  }) async {
    calls.add((method, path, query));
    if (error != null) throw error!;
    return response!;
  }
}

void main() {
  late AppDatabase db;
  late _FakeGateway api;
  late RateRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = _FakeGateway()
      ..response = {
        'base': 'USD',
        'rates': {'USD': 1, 'IDR': 16000, 'SAR': 3.75},
        'updated_at': '2026-10-24',
        'stale': false,
      };
    repository = RateRepository(db: db, api: api);
  });

  tearDown(() async => db.close());

  test('loads rates through ApiGateway and stores them in Drift cache',
      () async {
    final rates = (await repository.getRates())!;

    expect(api.calls.single.$1, 'GET');
    expect(api.calls.single.$2, '/rates');
    expect(api.calls.single.$3, {'base': 'USD'});
    expect(rates.perUsd, {'USD': 1, 'IDR': 16000, 'SAR': 3.75});
    expect(rates.isStale, isFalse);
    expect(await db.select(db.rateCacheTable).get(), hasLength(3));
  });

  test('uses cached rates after a network failure', () async {
    await repository.getRates();
    api.error = ApiException.of(ApiErrorKind.network);

    final rates = (await repository.getRates())!;

    expect(rates.perUsd['IDR'], 16000);
    expect(rates.isStale, isTrue);
  });

  test('does not invent rates when both server and local cache are empty',
      () async {
    api.error = ApiException.of(ApiErrorKind.network);

    await expectLater(repository.getRates(), throwsA(isA<ApiException>()));
  });

  test('no-cache consumer receives no rates on API failure', () async {
    api.error = ApiException.of(ApiErrorKind.unauthorized);
    final noCacheRepository = RateRepository(api: api);

    expect(await noCacheRepository.getRates(), isNull);
  });

  test('rejects malformed or incomplete backend responses', () async {
    api.response = {
      'base': 'USD',
      'rates': {'USD': 1, 'IDR': double.nan, 'SAR': 3.75},
      'updated_at': '2026-10-24',
    };

    await expectLater(repository.getRates(), throwsFormatException);
  });
}
