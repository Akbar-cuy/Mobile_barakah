// M4 Beranda dan Jadwal Sholat (FR-LBS-03, FR-LBS-04).
import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/prayer_cache_table.dart';

part 'prayer_cache_dao.g.dart';

typedef PrayerCacheRow = PrayerCacheTableData;

@DriftAccessor(tables: [PrayerCacheTable])
class PrayerCacheDao extends DatabaseAccessor<AppDatabase>
    with _$PrayerCacheDaoMixin {
  PrayerCacheDao(super.db);

  Future<PrayerCacheRow?> getDay({
    required String date,
    required String locationKey,
    required String method,
  }) {
    return (select(prayerCacheTable)
          ..where(
            (t) =>
                t.date.equals(date) &
                t.locationKey.equals(locationKey) &
                t.method.equals(method),
          ))
        .getSingleOrNull();
  }

  Future<List<PrayerCacheRow>> getRange({
    required String fromDate,
    required String toDate,
    required String locationKey,
    required String method,
  }) {
    return (select(prayerCacheTable)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(fromDate) &
                t.date.isSmallerOrEqualValue(toDate) &
                t.locationKey.equals(locationKey) &
                t.method.equals(method),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  Future<void> upsertAll(List<PrayerCacheTableCompanion> rows) {
    return batch((b) => b.insertAllOnConflictUpdate(prayerCacheTable, rows));
  }

  Future<int> deleteBefore(String date) {
    return (delete(prayerCacheTable)
          ..where((t) => t.date.isSmallerThanValue(date)))
        .go();
  }

  Future<void> clearAll() async {
    await delete(prayerCacheTable).go();
  }
}
