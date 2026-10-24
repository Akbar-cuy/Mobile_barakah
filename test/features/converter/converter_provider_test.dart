import 'package:barakah/core/database/app_database.dart';
import 'package:barakah/core/network/api_client.dart';
import 'package:barakah/core/network/api_exception.dart';
import 'package:barakah/features/converter/providers/converter_provider.dart';
import 'package:barakah/features/converter/repository/rate_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _RetryGateway implements ApiGateway {
  var requests = 0;

  @override
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Map<String, String>? headers,
    Duration? receiveTimeout,
  }) async {
    requests++;
    if (requests == 1) throw ApiException.of(ApiErrorKind.network);
    return {
      'base': 'USD',
      'rates': {'USD': 1, 'IDR': 16000, 'SAR': 3.75},
      'updated_at': '2026-10-24',
      'stale': false,
    };
  }
}

void main() {
  test('shows a recoverable error and retry clears it after rates load',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    final api = _RetryGateway();
    final provider = ConverterProvider(
      rateRepository: RateRepository(db: db, api: api),
    );
    addTearDown(() async {
      provider.dispose();
      await db.close();
    });

    await _waitFor(() => !provider.loadingRates);
    expect(provider.rates, isNull);
    expect(provider.ratesError, isNotNull);

    provider.retryRates();
    await _waitFor(() => !provider.loadingRates);

    expect(provider.ratesError, isNull);
    expect(provider.rates!.perUsd['IDR'], 16000);
    expect(api.requests, 2);

    provider.setAmount('1e308');
    expect(provider.amountError, 'Nominal terlalu besar untuk dikonversi.');
    expect(provider.currencyResults, isEmpty);
  });
}

Future<void> _waitFor(bool Function() condition) async {
  for (var i = 0; i < 50 && !condition(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  expect(condition(), isTrue, reason: 'Timed out waiting for converter state.');
}
