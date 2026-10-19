import 'package:barakah/core/constants/app_constants.dart';
import 'package:barakah/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Formatters', () {
    test('number memakai titik ribuan dan koma desimal', () {
      expect(Formatters.number(1000000), '1.000.000');
      expect(Formatters.number(63, fractionDigits: 2), '63,00');
      expect(Formatters.number(-1234.5, fractionDigits: 1), '-1.234,5');
    });

    test('AC-CUR-01: pembulatan sesuai mata uang', () {
      expect(Formatters.currency(1000000, AppCurrency.idr), 'Rp1.000.000');
      expect(Formatters.currency(63, AppCurrency.usd), 'USD 63,00');
      expect(Formatters.currency(237, AppCurrency.sar), 'SAR 237,00');
    });

    test('parseAmount membaca beberapa gaya penulisan', () {
      expect(Formatters.parseAmount('1.000.000,50'), 1000000.5);
      expect(Formatters.parseAmount('1.000.000'), 1000000);
      expect(Formatters.parseAmount('1000000.5'), 1000000.5);
      expect(Formatters.parseAmount('Rp 50.000'), 50000);
      expect(Formatters.parseAmount('abc'), isNull);
      expect(Formatters.parseAmount(''), isNull);
    });

    test('distance', () {
      expect(Formatters.distance(350), '350 m');
      expect(Formatters.distance(1100), '1,1 km');
    });
  });
}
