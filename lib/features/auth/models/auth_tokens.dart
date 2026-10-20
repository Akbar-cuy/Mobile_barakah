// M2 Manajemen Session (FR-SES-01)
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'].toString(),
      refreshToken: json['refresh_token'].toString(),
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 900,
    );
  }

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
}
