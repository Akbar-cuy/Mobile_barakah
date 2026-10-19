// M17 Profil (FR-PRO-07) dan M20 (FR-SYNC-04).
import 'package:drift/drift.dart';

import '../../utils/date_time_utils.dart';
import '../app_database.dart';
import '../tables/settings_table.dart';

part 'settings_dao.g.dart';

typedef SettingRow = SettingsTableData;

@DriftAccessor(tables: [SettingsTable])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> get(String key) async {
    final row = await (select(settingsTable)
          ..where((t) => t.settingKey.equals(key)))
        .getSingleOrNull();
    return row?.settingValue;
  }

  Stream<String?> watch(String key) {
    return (select(settingsTable)..where((t) => t.settingKey.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.settingValue);
  }

  Future<List<SettingRow>> getAll() => select(settingsTable).get();

  Future<void> set(String key, String value, {DateTime? now}) {
    return into(settingsTable).insertOnConflictUpdate(
      SettingsTableCompanion.insert(
        settingKey: key,
        settingValue: value,
        updatedAt: DateTimeUtils.toIsoUtcSeconds(now ?? DateTime.now()),
      ),
    );
  }

  Future<void> remove(String key) async {
    await (delete(settingsTable)..where((t) => t.settingKey.equals(key))).go();
  }

  Future<void> clearAll() async {
    await delete(settingsTable).go();
  }
}
