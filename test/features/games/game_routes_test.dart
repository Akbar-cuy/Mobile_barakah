import 'package:barakah/core/router/app_router.dart';
import 'package:barakah/core/router/route_names.dart';
import 'package:barakah/features/auth/models/session.dart';
import 'package:barakah/features/auth/providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SignedInSession extends SessionController {
  @override
  SessionState build() => const SessionState(status: AuthStatus.authenticated);
}

void main() {
  testWidgets('registered quiz question route renders its screen',
      (tester) async {
    final container = ProviderContainer(overrides: [
      sessionProvider.overrideWith(_SignedInSession.new),
    ]);
    addTearDown(container.dispose);
    final router = container.read(routerProvider)..go(RouteNames.quizQuestion);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Pilih kategori untuk memulai kuis.'), findsOneWidget);
  });
}
