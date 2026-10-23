import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/database/app_database.dart';
import 'core/database/database_opener.dart';
import 'core/providers/app_providers.dart';
import 'core/security/encryption_service.dart';
import 'core/security/secure_storage_service.dart';
import 'features/notification/providers/notification_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (error) {
    debugPrint('Gagal memuat file .env: $error');
  }

  debugPrint('Konfigurasi: ${Env.summary}');

  final storage = SecureStorageService();
  final key = await EncryptionService(storage).getOrCreateDatabaseKey();
  final database = AppDatabase(openEncryptedExecutor(key));

  final container = ProviderContainer(
    overrides: [
      secureStorageProvider.overrideWithValue(storage),
      appDatabaseProvider.overrideWithValue(database),
    ],
  );

  try {
    await container.read(notificationGatewayProvider).init();
  } catch (error) {
    debugPrint('Notifikasi belum siap: $error');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BarakahApp(),
    ),
  );
}
