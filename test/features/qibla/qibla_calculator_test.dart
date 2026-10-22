// AC-QBL-01. Vektor dihitung dengan implementasi referensi independen (Node)
// dari rumus PRD 9.7, radius bumi 6371 km.
import 'package:barakah/features/qibla/services/qibla_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QiblaCalculator', () {
    const cases = <String, List<double>>{
      // nama: [lat, lon, bearing, jarak km]
      'Jakarta': [-6.2088, 106.8456, 295.1517, 7920.127],
      'Yogyakarta': [-7.7956, 110.3695, 294.7111, 8347.166],
      'Surabaya': [-7.2575, 112.7521, 294.0346, 8561.734],
      'Medan': [3.5952, 98.6722, 292.7658, 6645.521],
      'Makassar': [-5.1477, 119.4327, 292.4769, 9148.068],
      'Jayapura': [-2.5337, 140.7181, 291.3263, 11234.877],
      'London': [51.5074, -0.1278, 118.9872, 4793.775],
      'New York': [40.7128, -74.0060, 58.4817, 10306.306],
      'Madinah': [24.4672, 39.6024, 176.0835, 339.330],
      'Sydney': [-33.8688, 151.2093, 277.4996, 13236.255],
    };

    cases.forEach((name, v) {
      test('$name', () {
        final r = QiblaCalculator.calculate(v[0], v[1]);
        expect(r.bearing, closeTo(v[2], 0.05));
        expect(r.distanceKm, closeTo(v[3], 1.0));
      });
    });

    test('Jakarta berada di barat laut sekitar 295 derajat (AC-QBL-01)', () {
      final r = QiblaCalculator.calculate(-6.2088, 106.8456);
      expect(r.bearing, inInclusiveRange(294, 296));
      expect(r.compassName, 'Barat Laut');
    });

    test('bearing selalu dalam rentang 0 sampai <360', () {
      for (var lat = -80.0; lat <= 80; lat += 20) {
        for (var lon = -180.0; lon <= 180; lon += 30) {
          final b = QiblaCalculator.calculate(lat, lon).bearing;
          expect(b, greaterThanOrEqualTo(0));
          expect(b, lessThan(360));
        }
      }
    });
  });
}
