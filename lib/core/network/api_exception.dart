// Web service REST (FR-API-01, FR-API-02)
import '../constants/app_constants.dart';
import '../errors/failure.dart';

enum ApiErrorKind {
  network,
  timeout,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  locked,
  tooManyRequests,
  server,
  cancelled,
  unknown,
}

class ApiException implements Exception {
  const ApiException({
    required this.kind,
    required this.message,
    this.statusCode,
    this.code,
    this.details,
  });

  factory ApiException.fromResponse(int? status, Object? body) {
    String? code;
    String? message;
    Map<String, dynamic>? details;
    if (body is Map) {
      final err = body['error'];
      if (err is Map) {
        details = err.cast<String, dynamic>();
        code = err['code']?.toString();
        message = err['message']?.toString();
      } else {
        // Galat dari gateway Supabase (bukan dari fungsi kita), misalnya
        // {"code":"NOT_FOUND","message":"Requested function was not found"}.
        code = body['code']?.toString();
        message = _gatewayMessage(code, body['message']?.toString());
      }
    }
    final kind = _kindOf(status);
    return ApiException(
      kind: kind,
      message: message ?? defaultMessage(kind),
      statusCode: status,
      code: code,
      details: details,
    );
  }

  /// Pesan berbahasa Indonesia untuk galat gateway yang artinya khas, atau
  /// null bila tidak dikenali (pesan bawaan status dipakai).
  static String? _gatewayMessage(String? code, String? raw) {
    final text = (raw ?? '').toLowerCase();
    if (code == 'NOT_FOUND' || text.contains('function was not found')) {
      return 'Layanan ini belum tersedia di server (function belum di-deploy).';
    }
    if (code == 'BOOT_ERROR' ||
        code == 'WORKER_ERROR' ||
        text.contains('failed to start')) {
      return 'Layanan di server gagal dijalankan. Periksa log Edge Function '
          'di Supabase.';
    }
    return null;
  }

  factory ApiException.of(ApiErrorKind kind, {String? message}) {
    return ApiException(kind: kind, message: message ?? defaultMessage(kind));
  }

  final ApiErrorKind kind;
  final String message;
  final int? statusCode;
  final String? code;

  final Map<String, dynamic>? details;

  bool get isConnectivity =>
      kind == ApiErrorKind.network || kind == ApiErrorKind.timeout;

  Failure get failure {
    switch (kind) {
      case ApiErrorKind.network:
        return NetworkFailure(message, code: code);
      case ApiErrorKind.timeout:
        return TimeoutFailure(message, code: code);
      case ApiErrorKind.badRequest:
        return ValidationFailure(message, code: code);
      case ApiErrorKind.unauthorized:
        return AuthFailure(message, code: code);
      case ApiErrorKind.forbidden:
        return ForbiddenFailure(message, code: code);
      case ApiErrorKind.notFound:
        return NotFoundFailure(message, code: code);
      case ApiErrorKind.conflict:
        return ConflictFailure(message, code: code);
      case ApiErrorKind.locked:
        return AccountLockedFailure(message, code: code);
      case ApiErrorKind.tooManyRequests:
        return RateLimitFailure(message, code: code);
      case ApiErrorKind.server:
        return ServerFailure(message, code: code);
      case ApiErrorKind.cancelled:
      case ApiErrorKind.unknown:
        return UnknownFailure(message, code: code);
    }
  }

  static ApiErrorKind _kindOf(int? status) {
    switch (status) {
      case ApiStatus.badRequest:
        return ApiErrorKind.badRequest;
      case ApiStatus.unauthorized:
        return ApiErrorKind.unauthorized;
      case ApiStatus.forbidden:
        return ApiErrorKind.forbidden;
      case ApiStatus.notFound:
        return ApiErrorKind.notFound;
      case ApiStatus.conflict:
        return ApiErrorKind.conflict;
      case ApiStatus.locked:
        return ApiErrorKind.locked;
      case ApiStatus.tooManyRequests:
        return ApiErrorKind.tooManyRequests;
    }
    if (status != null && status >= 500) return ApiErrorKind.server;
    return ApiErrorKind.unknown;
  }

  static String defaultMessage(ApiErrorKind kind) {
    switch (kind) {
      case ApiErrorKind.network:
        return 'Tidak ada koneksi internet.';
      case ApiErrorKind.timeout:
        return 'Server terlalu lama merespons. Coba lagi.';
      case ApiErrorKind.badRequest:
        return 'Data yang dikirim tidak valid.';
      case ApiErrorKind.unauthorized:
        return 'Sesi berakhir. Silakan masuk kembali.';
      case ApiErrorKind.forbidden:
        return 'Anda tidak memiliki akses.';
      case ApiErrorKind.notFound:
        return 'Data tidak ditemukan.';
      case ApiErrorKind.conflict:
        return 'Data bertabrakan dengan data di server.';
      case ApiErrorKind.locked:
        return 'Akun dikunci sementara. Coba lagi nanti.';
      case ApiErrorKind.tooManyRequests:
        return 'Terlalu banyak permintaan. Coba lagi nanti.';
      case ApiErrorKind.server:
        return 'Terjadi gangguan di server. Coba lagi nanti.';
      case ApiErrorKind.cancelled:
        return 'Permintaan dibatalkan.';
      case ApiErrorKind.unknown:
        return 'Terjadi kesalahan yang tidak diketahui.';
    }
  }

  @override
  String toString() =>
      'ApiException(${kind.name}, status: $statusCode, code: $code): $message';
}
