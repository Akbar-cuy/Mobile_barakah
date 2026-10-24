import 'package:flutter_test/flutter_test.dart';
import 'package:barakah/core/database/database_opener.dart';

void main() {
  group('ensureSqliteCipherAvailable', () {
    test('allows startup when the encryption hook is available', () {
      expect(() => ensureSqliteCipherAvailable(true), returnsNormally);
    });

    test('fails closed when the encryption hook is missing', () {
      expect(
        () => ensureSqliteCipherAvailable(false),
        throwsA(isA<StateError>()),
      );
    });
  });
}
