import 'package:barakah/core/database/app_database.dart';
import 'package:barakah/core/network/api_client.dart';
import 'package:barakah/core/providers/app_providers.dart';
import 'package:barakah/features/games/screens/quiz_category_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

class _EmptyQuizApi implements ApiGateway {
  @override
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Duration? receiveTimeout,
  }) async =>
      const {'items': []};
}

void main() {
  testWidgets('shows all PRD categories and a clear empty-bank error',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        apiGatewayProvider.overrideWithValue(_EmptyQuizApi()),
      ],
      child: const MaterialApp(home: QuizCategoryScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Rukun Islam dan Iman'), findsOneWidget);
    expect(find.text('Sejarah Nabi'), findsOneWidget);
    expect(find.text('Fikih Dasar'), findsOneWidget);
    expect(find.text('Umum'), findsOneWidget);

    await tester.tap(find.text('Umum'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Bank soal belum tersedia'), findsOneWidget);
    expect(find.text('Coba lagi'), findsNothing);
  });
}
