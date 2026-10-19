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
        assert(
          rawDb.select('PRAGMA cipher;').isNotEmpty,
          'SQLite3MultipleCiphers tidak aktif. Periksa pengaturan hooks di pubspec.yaml.',
        );
        rawDb.execute("PRAGMA key = '${_escape(key)}';");
      },
    );
  });
}

String _escape(String source) => source.replaceAll("'", "''");
