import 'package:barakah/core/router/app_router.dart';
import 'package:barakah/core/router/route_names.dart';
import 'package:barakah/features/auth/models/session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('redirectFor', () {
    test('status belum diketahui diarahkan ke splash', () {
      expect(redirectFor(AuthStatus.unknown, RouteNames.home), RouteNames.splash);
      expect(redirectFor(AuthStatus.unknown, RouteNames.splash), isNull);
    });

    test('belum masuk hanya boleh di login dan registrasi', () {
      expect(redirectFor(AuthStatus.unauthenticated, RouteNames.home), RouteNames.login);
      expect(redirectFor(AuthStatus.unauthenticated, RouteNames.login), isNull);
      expect(redirectFor(AuthStatus.unauthenticated, RouteNames.register), isNull);
    });

    test('terkunci hanya boleh di layar kunci', () {
      expect(redirectFor(AuthStatus.locked, RouteNames.home), RouteNames.lock);
      expect(redirectFor(AuthStatus.locked, RouteNames.lock), isNull);
    });

    test('sudah masuk tidak boleh kembali ke halaman masuk', () {
      for (final page in [
        RouteNames.splash,
        RouteNames.login,
        RouteNames.register,
        RouteNames.lock,
      ]) {
        expect(redirectFor(AuthStatus.authenticated, page), RouteNames.home);
      }
      expect(redirectFor(AuthStatus.authenticated, RouteNames.worship), isNull);
    });
  });
}
