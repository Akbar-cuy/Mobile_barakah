// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_cache_dao.dart';

// ignore_for_file: type=lint
mixin _$PrayerCacheDaoMixin on DatabaseAccessor<AppDatabase> {
  $PrayerCacheTableTable get prayerCacheTable =>
      attachedDatabase.prayerCacheTable;
  PrayerCacheDaoManager get managers => PrayerCacheDaoManager(this);
}

class PrayerCacheDaoManager {
  final _$PrayerCacheDaoMixin _db;
  PrayerCacheDaoManager(this._db);
  $$PrayerCacheTableTableTableManager get prayerCacheTable =>
      $$PrayerCacheTableTableTableManager(
          _db.attachedDatabase, _db.prayerCacheTable);
}
