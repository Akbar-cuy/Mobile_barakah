// Keamanan: FR-AUTH-07 (basis data lokal terenkripsi)
// Memerlukan hooks sqlite3mc di pubspec.yaml (lihat README_TAHAP1A.md).
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';

QueryExecutor openEncryptedExecutor(String key) {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, AppConstants.databaseFileName));
    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        ensureSqliteCipherAvailable(rawDb.select('PRAGMA cipher;').isNotEmpty);
        rawDb.execute("PRAGMA key = '${_escape(key)}';");
      },
    );
  });
}

/// Fails closed if the SQLite encryption hook is not available.
///
/// This must remain a runtime check: Dart assertions are removed in release
/// builds, where silently opening an unencrypted database would expose local
/// user data.
void ensureSqliteCipherAvailable(bool isAvailable) {
  if (!isAvailable) {
    throw StateError(
      'SQLite3MultipleCiphers tidak aktif. Periksa pengaturan hooks di pubspec.yaml.',
    );
  }
}

String _escape(String source) => source.replaceAll("'", "''");
