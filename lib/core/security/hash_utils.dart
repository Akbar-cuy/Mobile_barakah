// Keamanan dan ledger (M12). Fungsi hash dan acak.

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

abstract final class HashUtils {
  static String sha256Hex(String input) =>
      sha256.convert(utf8.encode(input)).toString();

  static String randomHex(int bytes) {
    final random = Random.secure();
    return List.generate(
      bytes,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  static bool hasLeadingZeros(String hash, int zeros) {
    if (hash.length < zeros) return false;
    for (var i = 0; i < zeros; i++) {
      if (hash[i] != '0') return false;
    }
    return true;
  }
}