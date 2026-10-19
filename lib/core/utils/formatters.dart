// Fondasi lintas fitur. Format angka, mata uang, dan jarak (design.md bagian 13).
import '../constants/app_constants.dart';

abstract final class Formatters {
  static String number(double value, {int fractionDigits = 0}) {
    final negative = value < 0;
    final parts = value.abs().toStringAsFixed(fractionDigits).split('.');
    final digits = parts[0];
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    final decimals = parts.length > 1 ? ',${parts[1]}' : '';
    return '${negative ? '-' : ''}$buffer$decimals';
  }

  static String currency(double value, AppCurrency currency) {
    return '${currency.prefix}${number(value, fractionDigits: currency.fractionDigits)}';
  }

  static double? parseAmount(String input) {
    var s = input.trim().replaceAll(RegExp(r'\s'), '');
    s = s.replaceFirst(RegExp(r'^(Rp|USD|SAR)', caseSensitive: false), '');
    if (s.isEmpty) return null;
    if (s.contains(',')) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(s)) {
      s = s.replaceAll('.', '');
    }
    return double.tryParse(s);
  }

  static String distance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
  }
}
