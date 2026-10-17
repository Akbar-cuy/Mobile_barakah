abstract final class AppConstants {
  // --------------------------------------------------- Autentikasi (M1, M3)

  /// FR-AUTH-02: minimal 8 karakter, berisi huruf dan angka.
  static const int passwordMinLength = 8;
  static final RegExp passwordPattern =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');

  static final RegExp emailPattern = RegExp(r'^\S+@\S+\.\S+$');

  /// Nilai awal. PRD hanya mewajibkan nama pengguna unik.
  static const int usernameMinLength = 3;

  /// FR-AUTH-06: 5 kali gagal beruntun mengunci akun 15 menit.
  static const int maxLoginAttempts = 5;
  static const Duration loginLockDuration = Duration(minutes: 15);

  /// FR-BIO-06: setelah 3 kali gagal, tawarkan login kata sandi.
  static const int maxBiometricAttempts = 3;

  // ------------------------------------------------- Saran dan Kesan (M18)

  /// FR-FB-01 dan FR-FB-02.
  static const int feedbackRatingMin = 1;
  static const int feedbackRatingMax = 5;
  static const int feedbackTextMin = 10;
  static const int feedbackTextMax = 500;

  // ------------------------------------------------ Mata uang dan zakat

  /// Mata uang acuan untuk nilai setara (kolom amount_idr pada ledger).
  static const AppCurrency baseCurrency = AppCurrency.idr;

  /// FR-ZKT-01: zakat maal 2,5 persen, nisab setara 85 gram emas.
  static const double zakatRate = 0.025;
  static const double nisabGoldGrams = 85;

  // --------------------------------------------------- Ibadah (M7, M8, M13)

  /// Koordinat Ka'bah untuk rumus arah kiblat (PRD bagian 9.7).
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  /// FR-TSB-02.
  static const List<int> tasbihTargets = [33, 99, 100];

  /// FR-LLM-03. Ditambahkan di akhir setiap jawaban.
  static const String fiqhDisclaimer =
      'Ini informasi umum. Untuk kasus yang spesifik, '
      'tanyakan kepada ulama atau ustadz.';

  // ---------------------------------------------------------- Ledger (M12)

  /// Pemisah antar bidang pada masukan hash blok (PRD bagian 9.12).
  static const String ledgerFieldSeparator = '|';
  static const int ledgerGenesisIndex = 0;
  static const int ledgerHashLength = 64;

  /// Nilai prev_hash untuk blok genesis. PRD belum menetapkannya, jadi ini
  /// nilai awal. Klien dan server harus memakai nilai yang sama.
  static String get ledgerGenesisPrevHash => '0' * ledgerHashLength;

  // ---------------------------------------------------- Basis data lokal

  /// FR-AUTH-07: berkas SQLite terenkripsi (SQLCipher).
  static const String databaseFileName = 'barakah.db';
  static const int databaseSchemaVersion = 1;
}

/// Zona waktu tampilan (PRD Tabel 10, FR-TZ-01).
enum DisplayZone {
  wib('WIB', 'Asia/Jakarta'),
  wita('WITA', 'Asia/Makassar'),
  wit('WIT', 'Asia/Jayapura'),
  london('London', 'Europe/London');

  const DisplayZone(this.label, this.ianaId);

  final String label;

  /// Identitas zona pada basis data IANA (dipakai paket timezone).
  final String ianaId;
}

/// Mata uang yang didukung (FR-CUR-01, FR-CUR-03).
/// [prefix] mengikuti gaya penulisan: Rp1.000.000, USD 63,00, SAR 237,00.
enum AppCurrency {
  idr('IDR', 'Rp', 0),
  usd('USD', 'USD ', 2),
  sar('SAR', 'SAR ', 2);

  const AppCurrency(this.code, this.prefix, this.fractionDigits);

  final String code;
  final String prefix;
  final int fractionDigits;

  static AppCurrency? tryParse(String code) {
    for (final c in values) {
      if (c.code == code) return c;
    }
    return null;
  }
}

/// Kategori kuis (FR-GAME-01). [id] dikirim ke server sebagai parameter
/// category, jadi nilainya harus sama dengan data bank soal di server.
enum QuizCategory {
  rukunIman('rukun_iman', 'Rukun Islam dan Iman'),
  sejarahNabi('sejarah_nabi', 'Sejarah Nabi'),
  fikihDasar('fikih_dasar', 'Fikih Dasar'),
  umum('umum', 'Umum');

  const QuizCategory(this.id, this.label);

  final String id;
  final String label;
}

/// Kode status HTTP yang dipakai web service (FR-API-01 dan contoh login PRD).
abstract final class ApiStatus {
  static const int ok = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int locked = 423;
  static const int tooManyRequests = 429;
  static const int serverError = 500;
}

/// Kode galat pada badan respons (error.code), dari contoh kontrak API PRD.
abstract final class ApiErrorCodes {
  static const String invalidCredentials = 'invalid_credentials';
  static const String accountLocked = 'account_locked';
  static const String prevHashMismatch = 'prev_hash_mismatch';
}

/// Kunci di flutter_secure_storage (FR-SES-02, FR-AUTH-07, FR-BIO-03).
/// Token dan kunci tidak boleh disimpan di SQLite atau shared_preferences.
abstract final class SecureKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';

  /// Hanya dapat dibuka setelah verifikasi biometrik berhasil.
  static const String deviceToken = 'device_token';

  /// Kunci enkripsi SQLCipher yang dibangkitkan acak saat instalasi.
  static const String dbEncryptionKey = 'db_encryption_key';
  static const String deviceId = 'device_id';
}