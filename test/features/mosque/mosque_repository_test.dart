import 'package:barakah/core/database/app_database.dart';
import 'package:barakah/core/network/api_client.dart';
import 'package:barakah/core/network/api_exception.dart';
import 'package:barakah/features/mosque/repository/mosque_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeApi implements ApiGateway {
  Map<String, dynamic> response = const {'items': []};
  ApiException? failure;
  String? method;
  String? path;
  Map<String, Object?>? query;

  @override
  Future<Map<String, dynamic>> request(String method, String path,
      {Object? body,
      Map<String, Object?>? query,
      Map<String, String>? headers,
      Duration? receiveTimeout}) async {
    this.method = method;
    this.path = path;
    this.query = query;
    if (failure case final exception?) throw exception;
    return response;
  }
}

void main() {
  late AppDatabase db;
  late _FakeApi api;
  late ApiMosqueRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = _FakeApi();
    repository = ApiMosqueRepository(
      api: api,
      db: db,
      settings: db.settingsDao,
      outbox: db.outboxDao,
    );
  });

  tearDown(() async => db.close());

  test('fetches nearby API data and deduplicates valid OSM records', () async {
    api.response = {
      'items': [
        {'osm_id': 'node/1', 'name': 'Masjid Satu', 'lat': -6.2, 'lon': 106.8},
        {'osm_id': 'node/1', 'name': 'Duplikat', 'lat': -6.2, 'lon': 106.8},
        {'osm_id': 'node/2', 'name': 'Invalid', 'lat': 100, 'lon': 0},
      ],
    };

    final result = await repository.nearby(lat: -6.2, lon: 106.8, radiusKm: 10);

    expect(api.method, 'GET');
    expect(api.path, '/mosques/nearby');
    expect(api.query, {'lat': -6.2, 'lng': 106.8, 'radius': 10});
    expect(result.items, hasLength(1));
    expect(result.items.single.osmId, 'node/1');
    expect(result.items.single.distanceM, 0);
  });

  test('rejects invalid coordinates and radius before calling API', () async {
    await expectLater(
      repository.nearby(lat: double.nan, lon: 0, radiusKm: 2),
      throwsFormatException,
    );
    await expectLater(
      repository.nearby(lat: 0, lon: 0, radiusKm: 11),
      throwsFormatException,
    );
    expect(api.method, isNull);
  });

  test('falls back to stored results when Overpass source is unavailable',
      () async {
    api.response = {
      'items': [
        {'osm_id': 'way/1', 'name': 'Masjid Cache', 'lat': -6.2, 'lon': 106.8},
      ],
    };
    await repository.nearby(lat: -6.2, lon: 106.8, radiusKm: 10);
    api.failure = const ApiException(
      kind: ApiErrorKind.server,
      statusCode: 502,
      code: 'mosque_source_unavailable',
      message: 'Data masjid sementara tidak tersedia.',
    );

    final result = await repository.nearby(lat: -6.2, lon: 106.8, radiusKm: 10);

    expect(result.fromCache, isTrue);
    expect(result.items.single.osmId, 'way/1');
  });

  test('rejects malformed server response instead of treating it as empty',
      () async {
    api.response = const {'items': 'unexpected'};
    await expectLater(
      repository.nearby(lat: -6.2, lon: 106.8, radiusKm: 10),
      throwsFormatException,
    );
  });
}
