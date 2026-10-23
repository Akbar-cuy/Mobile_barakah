// Fondasi lintas fitur. UUID versi 4 untuk id yang dibuat di klien (FR-SYNC-05).
import 'dart:math';

abstract final class Uuid4 {
  static final Random _random = Random.secure();

  static String generate() {
    final b = List<int>.generate(16, (_) => _random.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40; // versi 4
    b[8] = (b[8] & 0x3f) | 0x80; // varian RFC 4122
    String hex(int from, int to) => b
        .sublist(from, to)
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
  }
}
