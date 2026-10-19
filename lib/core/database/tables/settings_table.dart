// M17 Profil, bagian Pengaturan (FR-PRO-07). Tabel settings.
import 'package:drift/drift.dart';

class SettingsTable extends Table {
  @override
  String get tableName => 'settings';

  TextColumn get settingKey => text().named('key')();
  TextColumn get settingValue => text().named('value')();

  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {settingKey};
}
