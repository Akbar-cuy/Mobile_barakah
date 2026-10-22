// M4 Beranda dan Jadwal Sholat (FR-LBS-03, FR-LBS-04). Cache lebih dulu, lalu jaringan.
import '../../../core/database/daos/prayer_cache_dao.dart';
import '../../../core/utils/date_time_utils.dart';
import '../models/prayer_times.dart';
import '../services/location_service.dart';
import '../services/prayer_time_service.dart';

class PrayerResult {
  const PrayerResult({required this.days, this.offline = false});

  final List<PrayerTimes> days;

  /// Jaringan gagal, jadwal berasal dari cache.
  final bool offline;
}

class PrayerRepository {
  PrayerRepository({
    required PrayerCacheDao dao,
    required PrayerTimeSource source,
    DateTime Function()? clock,
  })  : _dao = dao,
        _source = source,
        _now = clock ?? DateTime.now;

  /// 20 = Kementerian Agama Republik Indonesia pada API Aladhan.
  static const method = '20';

  final PrayerCacheDao _dao;
  final PrayerTimeSource _source;
  final DateTime Function() _now;

  List<DateTime> _dates(int days, DateTime? from) {
    final start = from ?? _now();
    return [
      for (var i = 0; i < days; i++)
        DateTime(start.year, start.month, start.day + i),
    ];
  }

  Future<List<PrayerTimes>> cachedDays(
    GeoPoint point, {
    int days = 7,
    DateTime? from,
  }) async {
    final dates = _dates(days, from);
    final rows = await _dao.getRange(
      fromDate: DateTimeUtils.dateKey(dates.first),
      toDate: DateTimeUtils.dateKey(dates.last),
      locationKey: point.locationKey,
      method: method,
    );
    return rows.map(PrayerTimes.fromRow).toList();
  }

  Future<PrayerResult> load(GeoPoint point, {int days = 7}) async {
    final dates = _dates(days, null);
    final cached = await cachedDays(point, days: days);
    if (cached.length >= days) return PrayerResult(days: cached);

    try {
      final months = {for (final date in dates) (date.year, date.month)};
      for (final (year, month) in months) {
        final fetched = await _source.fetchMonth(
          lat: point.lat,
          lon: point.lon,
          year: year,
          month: month,
          method: method,
          locationKey: point.locationKey,
        );
        final fetchedAt = _now();
        await _dao.upsertAll([
          for (final day in fetched) day.toCompanion(fetchedAt),
        ]);
      }
      await _dao.deleteBefore(DateTimeUtils.dateKey(dates.first));
      final fresh = await cachedDays(point, days: days);
      if (fresh.isEmpty) {
        throw const PrayerFetchException('Jadwal sholat kosong.');
      }
      return PrayerResult(days: fresh);
    } on PrayerFetchException {
      if (cached.isNotEmpty) return PrayerResult(days: cached, offline: true);
      rethrow;
    }
  }
}
