// M4 Beranda dan Jadwal Sholat (FR-LBS-03). Tabel prayer_cache.
import 'package:drift/drift.dart';

class PrayerCacheTable extends Table {
  @override
  String get tableName => 'prayer_cache';

  TextColumn get date => text()();

  TextColumn get locationKey => text()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  TextColumn get method => text()();
  TextColumn get fajr => text()();
  TextColumn get sunrise => text()();
  TextColumn get dhuhr => text()();
  TextColumn get asr => text()();
  TextColumn get maghrib => text()();
  TextColumn get isha => text()();
  // utcOffsetMinutes dan fetchedAt: tambahan di luar PRD.
  IntColumn get utcOffsetMinutes => integer()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {date, locationKey, method};
}
