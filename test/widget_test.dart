import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barakah/app.dart';
import 'package:barakah/core/database/app_database.dart';
import 'package:barakah/core/providers/app_providers.dart';

void main() {
  testWidgets('BarakahApp renders successfully', (WidgetTester tester) async {
    final database = AppDatabase(NativeDatabase.memory());

    addTearDown(database.close);

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
