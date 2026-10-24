import 'package:flutter_test/flutter_test.dart';
import 'package:barakah/features/donation/services/zakat_calculator.dart';

void main() {
  group('ZakatCalculator', () {
    test('maal is not due below nisab', () {
      final result = ZakatCalculator().calculateMaal(127499999);

      expect(result.wajib, isFalse);
      expect(result.resultIdr, 0);
    });

    test('maal is 2.5 percent at nisab', () {
      final calculator = ZakatCalculator();
      final result = calculator.calculateMaal(calculator.nisabIdr);

      expect(result.wajib, isTrue);
      expect(result.resultIdr, 3187500);
    });

    test('fitrah is calculated per person', () {
      final result = ZakatCalculator().calculateFitrah(3);

      expect(result.wajib, isTrue);
      expect(result.resultIdr, 135000);
    });
  });
}
