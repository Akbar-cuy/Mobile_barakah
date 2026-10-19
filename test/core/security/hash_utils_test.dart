import 'package:barakah/core/security/hash_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HashUtils', () {
    test('sha256Hex sesuai nilai baku', () {
      expect(
        HashUtils.sha256Hex('abc'),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
      expect(
        HashUtils.sha256Hex(''),
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
    });

    test('AC-BLK-06: hash deterministik', () {
      expect(HashUtils.sha256Hex('blok|1'), HashUtils.sha256Hex('blok|1'));
    });

    test('randomHex menghasilkan 2 karakter per byte dan berbeda tiap panggilan', () {
      final a = HashUtils.randomHex(32);
      final b = HashUtils.randomHex(32);
      expect(a.length, 64);
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(a), isTrue);
      expect(a, isNot(b));
    });

    test('hasLeadingZeros', () {
      expect(HashUtils.hasLeadingZeros('000abc', 3), isTrue);
      expect(HashUtils.hasLeadingZeros('00abc0', 3), isFalse);
      expect(HashUtils.hasLeadingZeros('00', 3), isFalse);
    });
  });
}
