// M20 Basis Data Lokal, Online, dan Sinkronisasi (FR-SYNC, FR-API)
import 'package:drift/drift.dart';

import '../constants/app_constants.dart';
// Dipakai oleh app_database.g.dart (ekspresi default kolom tabel).
import '../sync/sync_status.dart';
import 'daos/ledger_dao.dart';
import 'daos/outbox_dao.dart';
import 'daos/prayer_cache_dao.dart';
import 'daos/settings_dao.dart';
import 'tables/chat_message_table.dart';
import 'tables/donation_local_table.dart';
import 'tables/favorite_mosque_table.dart';
import 'tables/feedback_local_table.dart';
import 'tables/ledger_local_table.dart';
import 'tables/outbox_table.dart';
import 'tables/prayer_cache_table.dart';
import 'tables/quiz_attempt_table.dart';
import 'tables/quiz_question_table.dart';
import 'tables/rate_cache_table.dart';
import 'tables/settings_table.dart';
import 'tables/tasbih_log_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    LedgerLocalTable,
    OutboxTable,
    SettingsTable,
    PrayerCacheTable,
    RateCacheTable,
    DonationLocalTable,
    TasbihLogTable,
    QuizAttemptTable,
    QuizQuestionTable,
    ChatMessageTable,
    FeedbackLocalTable,
    FavoriteMosqueTable,
  ],
  daos: [LedgerDao, OutboxDao, SettingsDao, PrayerCacheDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => AppConstants.databaseSchemaVersion;

  /// Menghapus seluruh data lokal (FR-OUT-04).
  Future<void> clearAllData() {
    return transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }
}
