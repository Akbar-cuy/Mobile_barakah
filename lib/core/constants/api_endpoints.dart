import '../config/app_config.dart';

abstract final class ApiEndpoints {
  // ------------------------------------------------ Auth (M1, M2, M3, M17)

  static const String register = '/auth/register'; // POST, publik
  static const String login = '/auth/login'; // POST, publik
  static const String refresh = '/auth/refresh'; // POST, publik (refresh token)
  static const String logout = '/auth/logout'; // POST, user
  static const String changePassword = '/auth/password'; // POST, user
  static const String biometricEnable = '/auth/biometric/enable'; // POST, user
  static const String biometricLogin = '/auth/biometric/login'; // POST, publik (device token)
  static const String biometricDisable = '/auth/biometric'; // DELETE, user
  static const String authSessions = '/auth/sessions'; // GET, user

  /// DELETE, user. Mencabut sesi tertentu (FR-PRO-06).
  static String authSession(String id) =>
      '/auth/sessions/${Uri.encodeComponent(id)}';

  // --------------------------------------------------------- Profil (M17)

  static const String profile = '/profile'; // GET dan PUT, user
  static const String profileAvatar = '/profile/avatar'; // POST, user

  // ------------------------------------------------- Masjid dan LBS (M6)

  static const String mosquesNearby = '/mosques/nearby'; // GET, user
  static const String favoriteMosques = '/favorites/mosques'; // GET, POST, DELETE, user

  // ---------------------------------------- Kurs, zakat, donasi (M10, M11)

  static const String rates = '/rates'; // GET, user
  static const String campaigns = '/campaigns'; // GET, user
  static const String donations = '/donations'; // POST, user
  static const String zakatCalculations = '/zakat/calculations'; // POST, user

  // ------------------------------------------------------- Ledger (M12)

  static const String ledger = '/ledger'; // GET, user
  static const String ledgerVerify = '/ledger/verify'; // GET, user

  // ----------------------------------------------------------- LLM (M13)

  static const String aiChat = '/ai/chat'; // POST, user
  static const String aiZakatExplain = '/ai/zakat-explain'; // POST, user
  static const String aiHistory = '/ai/history'; // GET dan DELETE, user

  // ---------------------------------------------------------- Game (M15)

  static const String quizQuestions = '/quiz/questions'; // GET, user
  static const String quizAttempts = '/quiz/attempts'; // POST, user
  static const String quizLeaderboard = '/quiz/leaderboard'; // GET, user
  static const String gameScores = '/games/scores'; // POST, user

  // ------------------------------------------------ Saran dan Kesan (M18)

  static const String feedback = '/feedback'; // POST dan GET, user

  /// PUT dan DELETE, user (FR-FB-05).
  static String feedbackById(String id) =>
      '/feedback/${Uri.encodeComponent(id)}';

  // ------------------------------------------------ Sinkronisasi (M20)

  static const String syncPush = '/sync/push'; // POST, user
  static const String syncPull = '/sync/pull'; // GET, user

  // -------------------------------------------------------- IoT (M21)

  static const String iotDevices = '/iot/devices'; // POST, user

  // Dua endpoint berikut dipanggil perangkat ESP32 dengan device key (bukan
  // token pengguna, FR-IOT-05). Aplikasi tidak memanggilnya, hanya dicatat
  // di sini agar daftar tetap lengkap.
  static const String iotNextPrayer = '/iot/next-prayer'; // GET, device
  static const String iotTasbih = '/iot/tasbih'; // POST, device

  // ------------------------------------------------------ Autentikasi

  /// Endpoint tanpa Bearer access token. AuthInterceptor tidak boleh
  /// menambahkan token atau mencoba memperbarui sesi untuk path ini.
  static const Set<String> publicPaths = {
    register,
    login,
    refresh,
    biometricLogin,
  };

  static bool isPublic(String path) => publicPaths.contains(_stripQuery(path));

  static String _stripQuery(String path) {
    final q = path.indexOf('?');
    return q == -1 ? path : path.substring(0, q);
  }

  // ------------------------------------------------------ Pembentuk URI

  /// Menggabungkan [path] dengan AppConfig.apiBaseUrl. Nilai query yang null
  /// dibuang.
  static Uri uri(String path, {Map<String, Object?>? query}) {
    final base = Uri.parse('${AppConfig.apiBaseUrl}$path');
    if (query == null) return base;
    final params = {
      for (final e in query.entries)
        if (e.value != null) e.key: '${e.value}',
    };
    if (params.isEmpty) return base;
    return base.replace(queryParameters: {...base.queryParameters, ...params});
  }

  /// FR-LBS-09. Radius dalam kilometer (satuan sama dengan
  /// AppConfig.mosqueDefaultRadiusKm). Server harus memakai satuan yang sama.
  static Uri mosquesNearbyUri({
    required double lat,
    required double lng,
    double? radiusKm,
    String? q,
  }) {
    return uri(mosquesNearby, query: {
      ApiParams.lat: lat,
      ApiParams.lng: lng,
      ApiParams.radius: radiusKm ?? AppConfig.mosqueDefaultRadiusKm,
      ApiParams.q: q,
    });
  }

  /// FR-SRC-05.
  static Uri campaignsUri({String? q, String? category}) {
    return uri(campaigns, query: {
      ApiParams.q: q,
      ApiParams.category: category,
    });
  }

  /// FR-GAME-05. [version] adalah versi bank soal yang sudah dimiliki
  /// perangkat, supaya server hanya mengirim bila ada versi yang lebih baru.
  static Uri quizQuestionsUri({String? category, int? version}) {
    return uri(quizQuestions, query: {
      ApiParams.category: category,
      ApiParams.version: version,
    });
  }

  /// FR-SYNC-03. [since] dikirim sebagai waktu UTC ISO 8601.
  static Uri syncPullUri({DateTime? since}) {
    return uri(syncPull, query: {
      ApiParams.since: since?.toUtc().toIso8601String(),
    });
  }
}

/// Nama parameter query. Dipakai bersama oleh klien dan (secara manual)
/// Edge Functions agar penamaannya tidak berbeda.
abstract final class ApiParams {
  static const String lat = 'lat';
  static const String lng = 'lng';
  static const String radius = 'radius';
  static const String q = 'q';
  static const String category = 'category';
  static const String version = 'version';
  static const String since = 'since';
}