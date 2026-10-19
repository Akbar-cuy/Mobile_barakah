// Fondasi lintas fitur. Galat yang ditampilkan ke lapisan antarmuka.
sealed class Failure {
  const Failure(this.message, {this.code});

  final String message;

  final String? code;

  @override
  String toString() => '$runtimeType(${code ?? '-'}): $message';
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message, {super.code});
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

final class AccountLockedFailure extends Failure {
  const AccountLockedFailure(super.message, {super.code});
}

final class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.message, {super.code});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});
}

final class ConflictFailure extends Failure {
  const ConflictFailure(super.message, {super.code});
}

final class RateLimitFailure extends Failure {
  const RateLimitFailure(super.message, {super.code});
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

final class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}
