import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:barakah/features/converter/services/timezone_service.dart';

void main() {
  group('TimezoneService', () {
    setUpAll(tzdata.initializeTimeZones);

    test('converts between Indonesian time zones', () {
      final results = TimezoneService().convertTime(
        hour: 9,
        minute: 5,
        from: zoneList.first,
      );

      expect(
        results.map((result) => result.zoneLabel).toList(),
        ['WIB', 'WITA', 'WIT', 'London'],
      );
      expect(results.take(3).map((result) => result.time), [
        '09:05',
        '10:05',
        '11:05',
      ]);
      expect(results.last.time, matches(RegExp(r'^\d{2}:\d{2}$')));
    });

    test('formats time with leading zeroes', () {
      expect(TimezoneService().formatTime(4, 7), '04:07');
    });
  });
}
