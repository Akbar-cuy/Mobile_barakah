// Kurs referensi terbaru, disimpan lokal agar tetap tersedia saat offline.
import '../../../core/constants/api_endpoints.dart';
import '../../../core/database/app_database.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/security/secure_storage_service.dart';

class RateData {
  const RateData({
    required this.perUsd,
    required this.updatedAt,
    this.isStale = false,
  });

  final Map<String, double> perUsd;
  final DateTime updatedAt;
  final bool isStale;

  RateData asStale() => RateData(
        perUsd: perUsd,
        updatedAt: updatedAt,
        isStale: true,
      );
}

class RateRepository {
  RateRepository({AppDatabase? db, ApiGateway? api})
      : _db = db,
        _api =
            api ?? ApiClient(tokens: SecureTokenStore(SecureStorageService()));

  static const currencies = ['USD', 'IDR', 'SAR'];

  final AppDatabase? _db;
  final ApiGateway _api;

  Future<RateData?> getRates() async {
    try {
      final response = await _api.request(
        'GET',
        ApiEndpoints.rates,
        query: const {'base': 'USD'},
      );
      final rates = _parseRates(response);
      await _saveCache(rates);
      return rates;
    } catch (error) {
      if (!_canUseCache(error)) {
        if (_db == null && error is ApiException) return null;
        rethrow;
      }
      final cached = await _readCache();
      if (cached != null) return cached.asStale();
      if (_db == null) return null;
      rethrow;
    }
  }

  RateData _parseRates(Map<String, dynamic> response) {
    if (response['base'] != 'USD' || response['rates'] is! Map) {
      throw const FormatException('Respons kurs tidak valid.');
    }
    final ratesJson = Map<String, dynamic>.from(response['rates'] as Map);
    final rates = <String, double>{};
    for (final currency in currencies) {
      final value = ratesJson[currency];
      if (value is! num || !value.toDouble().isFinite || value <= 0) {
        throw const FormatException(
            'Data kurs tidak lengkap atau tidak valid.');
      }
      rates[currency] = value.toDouble();
    }
    if (rates['USD'] != 1) {
      throw const FormatException('Kurs dasar USD tidak valid.');
    }
    final date = response['updated_at'];
    if (date is! String) {
      throw const FormatException('Waktu pembaruan kurs tidak valid.');
    }
    final updatedAt = DateTime.tryParse(date);
    if (updatedAt == null) {
      throw const FormatException('Waktu pembaruan kurs tidak valid.');
    }
    return RateData(
      perUsd: rates,
      updatedAt: updatedAt.toUtc(),
      isStale: response['stale'] == true,
    );
  }

  bool _canUseCache(Object error) {
    if (error is FormatException) return true;
    if (error is! ApiException) return false;
    return error.isConnectivity ||
        error.kind == ApiErrorKind.server ||
        error.kind == ApiErrorKind.tooManyRequests;
  }

  Future<void> _saveCache(RateData data) async {
    final db = _db;
    if (db == null) return;
    await db.transaction(() async {
      for (final entry in data.perUsd.entries) {
        await db.into(db.rateCacheTable).insertOnConflictUpdate(
              RateCacheTableCompanion.insert(
                base: 'USD',
                quote: entry.key,
                rate: entry.value,
                fetchedAt: data.updatedAt,
              ),
            );
      }
    });
  }

  Future<RateData?> _readCache() async {
    final db = _db;
    if (db == null) return null;
    final rows = await (db.select(db.rateCacheTable)
          ..where((row) => row.base.equals('USD')))
        .get();
    final cachedRates = <String, double>{
      for (final row in rows)
        if (currencies.contains(row.quote) && row.rate.isFinite && row.rate > 0)
          row.quote: row.rate,
    };
    if (!currencies.every(cachedRates.containsKey) || cachedRates['USD'] != 1) {
      return null;
    }
    final dates = rows
        .where((row) => currencies.contains(row.quote))
        .map((row) => row.fetchedAt.toUtc());
    final updatedAt = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    return RateData(perUsd: cachedRates, updatedAt: updatedAt, isStale: true);
  }
}
