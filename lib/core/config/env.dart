abstract final class Env {
  /// dev, staging, atau prod. Nilai lain dianggap dev oleh AppConfig.
  static const String appEnv =
      String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// M21 IoT (opsional).
  static const bool enableIot = bool.fromEnvironment('ENABLE_IOT');

  /// FR-NTF-08, notifikasi dekat masjid (opsional).
  static const bool enableGeofence = bool.fromEnvironment('ENABLE_GEOFENCE');

  /// Ringkasan yang aman dicetak ke log untuk memeriksa konfigurasi.
  /// Nilai kunci tidak ditampilkan, hanya status terisi atau kosong.
  static Map<String, String> get summary => {
        'APP_ENV': appEnv,
        'SUPABASE_URL': supabaseUrl.isEmpty ? '(kosong)' : supabaseUrl,
        'SUPABASE_ANON_KEY': supabaseAnonKey.isEmpty ? '(kosong)' : '(terisi)',
        'ENABLE_IOT': '$enableIot',
        'ENABLE_GEOFENCE': '$enableGeofence',
      };
}