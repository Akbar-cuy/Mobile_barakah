// M2 Manajemen Session dan M19 Logout (FR-SES, FR-OUT)
import 'user.dart';

enum AuthStatus { unknown, unauthenticated, locked, authenticated }

/// Pilihan pada dialog logout (FR-OUT-02, FR-OUT-04).
class LogoutOptions {
  const LogoutOptions({this.disableBiometric = false, this.clearLocalData = false});

  final bool disableBiometric;
  final bool clearLocalData;
}

class SessionState {
  const SessionState({
    required this.status,
    this.user,
    this.offerBiometric = false,
    this.expired = false,
  });

  const SessionState.unauthenticated({bool expired = false})
      : this(status: AuthStatus.unauthenticated, expired: expired);

  final AuthStatus status;
  final AppUser? user;

  /// Menawarkan aktivasi biometrik setelah login kata sandi pertama.
  final bool offerBiometric;

  /// Sesi berakhir di server (FR-SES-05).
  final bool expired;

  SessionState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool? offerBiometric,
    bool? expired,
  }) {
    return SessionState(
      status: status ?? this.status,
      user: user ?? this.user,
      offerBiometric: offerBiometric ?? this.offerBiometric,
      expired: expired ?? this.expired,
    );
  }
}
