import 'package:flutter_test/flutter_test.dart';
import 'package:barakah/features/converter/services/currency_service.dart';

void main() {
  group('CurrencyService', () {
    final service = CurrencyService();

    test('validates positive numeric amounts', () {
      expect(service.validateAmount(''), isNotNull);
      expect(service.validateAmount('abc'), isNotNull);
      expect(service.validateAmount('0'), isNotNull);
      expect(service.validateAmount('125,5'), isNull);
    });

    test('converts currencies through USD rates', () {
      expect(
        service.convert(100, 'USD', 'IDR', {'USD': 1, 'IDR': 16000}),
        1600000,
      );
    });

    test('formats IDR without decimals and other currencies with decimals', () {
      expect(service.format(1234567.4, 'IDR'), 'Rp1.234.567');
      expect(service.format(1234.5, 'USD'), 'USD 1.234,50');
    });
  });
}
