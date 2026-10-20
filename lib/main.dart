import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/database/app_database.dart';
import 'core/database/database_opener.dart';
import 'core/providers/app_providers.dart';
import 'core/security/encryption_service.dart';
import 'core/security/secure_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BarakahApp(),
    ),
  );
}