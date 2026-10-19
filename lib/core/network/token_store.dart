// Fondasi lintas fitur. Antarmuka penyimpanan token sesi (FR-SES-02).
abstract interface class TokenStore {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> clear();
}
