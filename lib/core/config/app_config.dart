import 'env.dart';

enum AppEnvironment { dev, staging, prod }

abstract final class AppConfig {
  // ---------------------------------------------------------------- Lingkungan

  static const String appName = 'Barakah';

  static AppEnvironment get environment => AppEnvironment.values.firstWhere(
        (e) => e.name == Env.appEnv,
        orElse: () => AppEnvironment.dev,
      );

  static bool get isProd => environment == AppEnvironment.prod;

  // ------------------------------------------------------------------- Backend

  static const String supabaseUrl = Env.supabaseUrl;
  static const String supabaseAnonKey = Env.supabaseAnonKey;

  static bool get isBackendConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Alamat dasar web service REST (Edge Functions).
  /// Contoh: $apiBaseUrl/auth/login.
  static String get apiBaseUrl =>
      '${supabaseUrl.replaceAll(RegExp(r'/+$'), '')}/functions/v1';

  /// Panggil di main() bila ingin gagal cepat ketika konfigurasi belum diisi.
  static void ensureBackendConfigured() {
    if (!isBackendConfigured) {
      throw StateError(
        'SUPABASE_URL dan SUPABASE_ANON_KEY belum diisi. '
        'Jalankan dengan --dart-define (lihat komentar di app_config.dart).',
      );
    }
  }

  // ------------------------------------------------------------ Jaringan (FR-API)

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration llmReceiveTimeout = Duration(seconds: 45);

  // ------------------------------------------------------------ Session (M2)

  /// Layar kunci muncul setelah aplikasi tidak aktif selama ini (FR-SES-06).
  static const Duration autoLockAfter = Duration(minutes: 5);

  /// Perbarui access token sedikit sebelum kedaluwarsa. Umur token ditentukan
  /// server (15 menit dan 7 hari, FR-SES-01), bukan di sini.
  static const Duration tokenRefreshSkew = Duration(seconds: 30);

  // ---------------------------------------------------------- Penanda fitur

  /// M21 IoT bersifat opsional: --dart-define=ENABLE_IOT=true
  static const bool enableIot = Env.enableIot;

  /// FR-NTF-08 (opsional): --dart-define=ENABLE_GEOFENCE=true
  static const bool enableGeofenceNotification = Env.enableGeofence;

  // ------------------------------------------------- Lokasi dan jadwal (M4, M6)

  /// Cache jadwal dan jendela notifikasi (FR-LBS-03, FR-NTF-01).
  static const int prayerWindowDays = 7;

  /// Jadwal dihitung ulang bila lokasi bergeser lebih dari ini (FR-LBS-04).
  static const double relocationThresholdKm = 20;

  static const double mosqueDefaultRadiusKm = 2;
  static const double mosqueMaxRadiusKm = 10;

  /// Radius notifikasi dekat masjid favorit (FR-NTF-08).
  static const double geofenceRadiusMeters = 200;

  // ------------------------------------------------ Sensor dan game (M7, M8, M15)

  /// Toleransi menghadap kiblat (FR-QBL-03).
  static const double qiblaToleranceDegrees = 3;

  /// Bobot gyroscope pada filter komplementer (FR-QBL-02).
  static const double headingFilterAlpha = 0.98;

  /// Ambang goyang tasbih dalam m/s^2 dan jeda antar hitungan (FR-TSB-01).
  static const double shakeThreshold = 15;
  static const Duration shakeDebounce = Duration(milliseconds: 500);

  /// Game Cari Arah (FR-GAME-06 dan FR-GAME-07).
  static const double directionGameToleranceDegrees = 5;
  static const Duration directionGameHold = Duration(seconds: 2);
  static const int directionGameTargets = 5;
  static const Duration directionGameTimePerTarget = Duration(seconds: 15);

  /// Kuis Islami (FR-GAME-02).
  static const int quizQuestionsPerSession = 10;
  static const Duration quizTimePerQuestion = Duration(seconds: 20);

  // ------------------------------------------------------------ Ledger (M12)

  /// Jumlah digit heksadesimal nol di awal hash (proof of work).
  /// Harus sama persis dengan nilai di server (FR-BLK-06).
  static const int powDifficulty = 3;

  static String get powPrefix => '0' * powDifficulty;

  // ------------------------------------------------------ Sinkronisasi (M20)

  /// Nilai awal. PRD hanya menyebut backoff eksponensial (FR-SYNC-06).
  static const int syncMaxAttempts = 8;
  static const Duration syncBaseBackoff = Duration(seconds: 5);
  static const Duration syncMaxBackoff = Duration(minutes: 15);

  /// Jeda sebelum percobaan ke-[attempt] (mulai dari 1): 5, 10, 20, ... detik.
  static Duration syncBackoff(int attempt) {
    final exp = (attempt - 1).clamp(0, 10).toInt();
    final next = syncBaseBackoff * (1 << exp);
    return next > syncMaxBackoff ? syncMaxBackoff : next;
  }

  // ------------------------------------------------------------- LLM (M13)

  /// Contoh dari PRD (FR-LLM-07). Pembatasan sebenarnya dijalankan server.
  static const int llmRequestsPerHour = 20;

  /// Nilai awal. PRD menyebut batas panjang tetapi belum menetapkan angkanya.
  static const int llmMaxInputChars = 500;

  // ----------------------------------------------------------- Profil (M17)

  /// FR-PRO-09.
  static const int maxAvatarBytes = 2 * 1024 * 1024;
  static const List<String> avatarExtensions = ['jpg', 'jpeg', 'png'];
}