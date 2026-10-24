import 'package:flutter_test/flutter_test.dart';
import 'package:barakah/features/home/services/prayer_time_service.dart';

void main() {
  group('AladhanPrayerTimeService.parse', () {
    test('rejects impossible provider dates without throwing FormatException',
        () {
      expect(
        () => AladhanPrayerTimeService.parse(
          _response(date: '31-02-2026'),
          lat: -6.2,
          lon: 106.8,
          method: '20',
          locationKey: 'test-location',
        ),
        throwsA(isA<PrayerFetchException>()),
      );
    });

    test('rejects out-of-range prayer times', () {
      expect(
        () => AladhanPrayerTimeService.parse(
          _response(fajr: '25:70'),
          lat: -6.2,
          lon: 106.8,
          method: '20',
          locationKey: 'test-location',
        ),
        throwsA(isA<PrayerFetchException>()),
      );
    });
  });
}

Map<String, Object?> _response({
  String date = '24-10-2026',
  String fajr = '04:15',
}) =>
    {
      'data': [
        {
          'date': {
            'gregorian': {'date': date},
          },
          'timings': {
            'Fajr': fajr,
            'Sunrise': '05:30',
            'Dhuhr': '11:45',
            'Asr': '15:00',
            'Maghrib': '17:50',
            'Isha': '19:00',
          },
          'meta': {'timezone': 'Asia/Jakarta'},
        },
      ],
    };
