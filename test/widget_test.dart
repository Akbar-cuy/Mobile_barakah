import 'package:drift/native.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barakah/app.dart';
import 'package:barakah/core/database/app_database.dart';
import 'package:barakah/core/providers/app_providers.dart';

void main() {
  testWidgets('BarakahApp renders successfully', (WidgetTester tester) async {
    final database = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );

    addTearDown(() async {
      // Unmount Riverpod's Drift watchers before closing their database.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await database.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
        ],
        child: const BarakahApp(),
      ),
    );

    await tester.pump();

    expect(find.byType(BarakahApp), findsOneWidget);
  });
}
