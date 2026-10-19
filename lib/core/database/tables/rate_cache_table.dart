// M10 Konversi Mata Uang (FR-CUR-01, FR-CUR-04). Tabel rate_cache.
import 'package:drift/drift.dart';

class RateCacheTable extends Table {
  @override
  String get tableName => 'rate_cache';

  TextColumn get base => text()();
  TextColumn get quote => text()();
  RealColumn get rate => real()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {base, quote};
}
