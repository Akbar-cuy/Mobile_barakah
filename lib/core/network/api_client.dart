// Web service REST (FR-API-01, FR-API-02, FR-SES-07)
import 'dart:io';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';
import 'token_store.dart';

// Respons selalu objek JSON. Daftar dibungkus {"items": [...]}.
abstract interface class ApiGateway {
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Duration? receiveTimeout,
  });
}

class ApiClient implements ApiGateway {
  ApiClient({
    required TokenStore tokens,
    void Function()? onSessionExpired,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout: AppConfig.connectTimeout,
                receiveTimeout: AppConfig.receiveTimeout,
                headers: {
                  'Accept': 'application/json',
                  if (AppConfig.supabaseAnonKey.isNotEmpty)
                    'apikey': AppConfig.supabaseAnonKey,
                },
              ),
            ) {
    _dio.interceptors.add(
      AuthInterceptor(
        dio: _dio,
        tokens: tokens,
        onSessionExpired: onSessionExpired,
      ),
    );
  }

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Duration? receiveTimeout,
  }) async {
    try {
      final res = await _dio.request<Object?>(
        path,
        data: body,
        queryParameters: _clean(query),
        options: Options(
          method: method,
          headers: headers,
          receiveTimeout: receiveTimeout,
        ),
      );
      return _asMap(res.data);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<Map<String, dynamic>> get(String path,
          {Map<String, Object?>? query}) =>
      request('GET', path, query: query);

  Future<Map<String, dynamic>> post(String path, {Object? body}) =>
      request('POST', path, body: body);

  Future<Map<String, dynamic>> put(String path, {Object? body}) =>
      request('PUT', path, body: body);

  Future<Map<String, dynamic>> delete(String path,
          {Map<String, Object?>? query}) =>
      request('DELETE', path, query: query);

  static Map<String, dynamic>? _clean(Map<String, Object?>? query) {
    if (query == null) return null;
    return {
      for (final e in query.entries)
        if (e.value != null) e.key: '${e.value}',
    };
  }

  static Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is List) return {'items': data};
    return const {};
  }

  static ApiException _toApiException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException.of(ApiErrorKind.timeout);
      case DioExceptionType.connectionError:
        return ApiException.of(ApiErrorKind.network);
      case DioExceptionType.badResponse:
        return ApiException.fromResponse(
            e.response?.statusCode, e.response?.data);
      case DioExceptionType.cancel:
        return ApiException.of(ApiErrorKind.cancelled);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return ApiException.of(ApiErrorKind.network);
        }
        return ApiException.of(ApiErrorKind.unknown);
    }
  }
}
