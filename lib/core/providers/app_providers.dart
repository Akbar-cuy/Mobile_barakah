// Fondasi lintas fitur. Provider Riverpod untuk layanan inti.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/daos/ledger_dao.dart';
import '../database/daos/outbox_dao.dart';
import '../database/daos/prayer_cache_dao.dart';
import '../database/daos/settings_dao.dart';
import '../network/api_client.dart';
import '../network/connectivity_service.dart';
import '../network/token_store.dart';
import '../security/encryption_service.dart';
import '../security/secure_storage_service.dart';
import '../sync/outbox_processor.dart';
import '../sync/sync_service.dart';
// Pull handler milik fitur didaftarkan di sini (FR-SYNC-03). Saling impor
// dengan provider fitur aman karena provider diinisialisasi malas.
import '../../features/profile/providers/theme_provider.dart';
import '../../features/tasbih/providers/tasbih_provider.dart';

// appDatabaseProvider di-override di main() setelah kunci enkripsi didapat.
final secureStorageProvider =
    Provider<SecureStorageService>((ref) => SecureStorageService());

final tokenStoreProvider = Provider<TokenStore>(
  (ref) => SecureTokenStore(ref.watch(secureStorageProvider)),
);

final encryptionServiceProvider = Provider<EncryptionService>(
  (ref) => EncryptionService(ref.watch(secureStorageProvider)),
);

final connectivityServiceProvider =
    Provider<ConnectivityService>((ref) => ConnectivityService());

class SessionExpiredNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void notifyExpired() => state++;
}

final sessionExpiredProvider =
    NotifierProvider<SessionExpiredNotifier, int>(SessionExpiredNotifier.new);

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    tokens: ref.watch(tokenStoreProvider),
    onSessionExpired: () =>
        ref.read(sessionExpiredProvider.notifier).notifyExpired(),
  );
});

final apiGatewayProvider =
    Provider<ApiGateway>((ref) => ref.watch(apiClientProvider));

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider harus di-override di main() dengan AppDatabase yang sudah dibuat.',
  );
});

final ledgerDaoProvider =
    Provider<LedgerDao>((ref) => ref.watch(appDatabaseProvider).ledgerDao);

final outboxDaoProvider =
    Provider<OutboxDao>((ref) => ref.watch(appDatabaseProvider).outboxDao);

final settingsDaoProvider =
    Provider<SettingsDao>((ref) => ref.watch(appDatabaseProvider).settingsDao);

final prayerCacheDaoProvider = Provider<PrayerCacheDao>(
  (ref) => ref.watch(appDatabaseProvider).prayerCacheDao,
);

final outboxProcessorProvider = Provider<OutboxProcessor>((ref) {
  return OutboxProcessor(
    outbox: ref.watch(outboxDaoProvider),
    ledger: ref.watch(ledgerDaoProvider),
    api: ref.watch(apiGatewayProvider),
  );
});

final syncPullHandlersProvider = Provider<List<SyncPullHandler>>((ref) {
  return [
    ref.watch(tasbihPullHandlerProvider),
    ref.watch(settingsPullHandlerProvider),
  ];
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    processor: ref.watch(outboxProcessorProvider),
    outbox: ref.watch(outboxDaoProvider),
    settings: ref.watch(settingsDaoProvider),
    api: ref.watch(apiGatewayProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    pullHandlers: ref.watch(syncPullHandlersProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});
