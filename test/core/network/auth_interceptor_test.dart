import 'dart:typed_data';

import 'package:barakah/core/network/auth_interceptor.dart';
import 'package:barakah/core/network/token_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _TokenStore implements TokenStore {
  String? access = 'expired-access';
  String? refresh = 'valid-refresh';

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

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);

  final ResponseBody Function(RequestOptions options) respond;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('temporary refresh failure is surfaced without clearing the session',
      () async {
    final tokens = _TokenStore();
    final refreshDio = Dio(BaseOptions(
      baseUrl: 'https://example.test/functions/v1',
    ))
      ..httpClientAdapter = _Adapter(
        (_) => ResponseBody.fromString(
          '{"error":{"code":"server_error","message":"Unavailable"}}',
          503,
          headers: {
            Headers.contentTypeHeader: ['application/json']
          },
        ),
      );
    final dio = Dio(BaseOptions(
      baseUrl: 'https://example.test/functions/v1',
    ))
      ..httpClientAdapter = _Adapter(
        (_) => ResponseBody.fromString(
          '{"error":{"code":"unauthorized","message":"Expired"}}',
          401,
          headers: {
            Headers.contentTypeHeader: ['application/json']
          },
        ),
      );
    dio.interceptors.add(
      AuthInterceptor(dio: dio, tokens: tokens, refreshDio: refreshDio),
    );

    await expectLater(
      dio.get<dynamic>('/mosques/nearby'),
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'refresh status',
          503,
        ),
      ),
    );
    expect(tokens.access, 'expired-access');
    expect(tokens.refresh, 'valid-refresh');

    dio.close();
    refreshDio.close();
  });
}
