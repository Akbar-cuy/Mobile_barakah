import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class Env {
  /// dev, staging, atau prod.
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'dev';

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// M21 IoT (opsional).
  static bool get enableIot =>
      dotenv.env['ENABLE_IOT']?.toLowerCase() == 'true';

  /// FR NTF 08, notifikasi dekat masjid (opsional).
  static bool get enableGeofence =>
      dotenv.env['ENABLE_GEOFENCE']?.toLowerCase() == 'true';

  /// Ringkasan yang aman dicetak ke log.
  static Map<String, String> get summary => {
        'APP_ENV': appEnv,
        'SUPABASE_URL':
            supabaseUrl.isEmpty ? '(kosong)' : supabaseUrl,
        'SUPABASE_ANON_KEY':
            supabaseAnonKey.isEmpty ? '(kosong)' : '(terisi)',
        'ENABLE_IOT': '$enableIot',
        'ENABLE_GEOFENCE': '$enableGeofence',
      };
}