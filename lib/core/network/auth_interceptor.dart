// Web service REST (FR-SES-03, FR-SES-05, FR-SES-07)
import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import 'token_store.dart';

// Refresh: POST /auth/refresh {"refresh_token"} -> {access_token, refresh_token}.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required Dio dio,
    required TokenStore tokens,
    this.onSessionExpired,
    Dio? refreshDio,
  })  : _dio = dio,
        _tokens = tokens,
        _refreshDio = refreshDio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout: AppConfig.connectTimeout,
                receiveTimeout: AppConfig.receiveTimeout,
                headers: {
                  if (AppConfig.supabaseAnonKey.isNotEmpty)
                    'apikey': AppConfig.supabaseAnonKey,
                },
              ),
            );

  final Dio _dio;
  final TokenStore _tokens;

  final void Function()? onSessionExpired;

  final Dio _refreshDio;

  static const _kRetried = 'auth_retried';
  static const _kExplicitAuth = 'auth_explicit';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.headers.containsKey('Authorization')) {
      options.extra[_kExplicitAuth] = true;
    } else if (!ApiEndpoints.isPublic(options.path)) {
      final token = await _tokens.readAccessToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final req = err.requestOptions;
    final shouldRefresh = err.response?.statusCode == ApiStatus.unauthorized &&
        !ApiEndpoints.isPublic(req.path) &&
        req.extra[_kExplicitAuth] != true &&
        req.extra[_kRetried] != true;
    if (!shouldRefresh) return handler.next(err);

    final used = req.headers['Authorization'];
    final current = await _tokens.readAccessToken();
    if (current != null && used != 'Bearer $current') {
      return _retry(req, current, err, handler);
    }

    final outcome = await _refresh();
    if (outcome.accessToken != null) {
      return _retry(req, outcome.accessToken!, err, handler);
    }
    if (outcome.invalid) {
      await _tokens.clear();
      onSessionExpired?.call();
    }
    handler.next(err);
  }

  Future<void> _retry(
    RequestOptions req,
    String accessToken,
    DioException original,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final response = await _dio.fetch<dynamic>(
        req.copyWith(
          headers: {...req.headers, 'Authorization': 'Bearer $accessToken'},
          extra: {...req.extra, _kRetried: true},
        ),
      );
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<({String? accessToken, bool invalid})> _refresh() async {
    final refreshToken = await _tokens.readRefreshToken();
    if (refreshToken == null) return (accessToken: null, invalid: true);
    try {
      final res = await _refreshDio.post<dynamic>(
        ApiEndpoints.refresh,
        data: {'refresh_token': refreshToken},
      );
      final data = res.data;
      if (data is Map) {
        final access = data['access_token']?.toString();
        final refresh = data['refresh_token']?.toString();
        if (access != null && refresh != null) {
          await _tokens.saveTokens(accessToken: access, refreshToken: refresh);
          return (accessToken: access, invalid: false);
        }
      }
      return (accessToken: null, invalid: true);
    } on DioException catch (e) {
      final s = e.response?.statusCode;
      final rejected = s == ApiStatus.badRequest ||
          s == ApiStatus.unauthorized ||
          s == ApiStatus.forbidden;
      return (accessToken: null, invalid: rejected);
    }
  }
}
