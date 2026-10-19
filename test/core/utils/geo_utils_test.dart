import 'package:barakah/core/constants/app_constants.dart';
import 'package:barakah/core/utils/geo_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeoUtils', () {
    test('arah kiblat dari Yogyakarta sekitar 295 derajat', () {
      final b = GeoUtils.bearingDegrees(
        -7.7956, 110.3695,
        AppConstants.kaabaLatitude, AppConstants.kaabaLongitude,
      );
      expect(b, closeTo(294.7, 0.5));
    });

    test('jarak Yogyakarta ke Jakarta sekitar 427 km', () {
      final m = GeoUtils.distanceMeters(-7.7956, 110.3695, -6.2088, 106.8456);
      expect(m / 1000, closeTo(427, 5));
    });

    test('normalizeDegrees', () {
      expect(GeoUtils.normalizeDegrees(370), 10);
      expect(GeoUtils.normalizeDegrees(-10), 350);
    });

    test('angleDifference memilih arah putar terpendek', () {
      expect(GeoUtils.angleDifference(10, 350), 20);
      expect(GeoUtils.angleDifference(350, 10), -20);
      expect(GeoUtils.angleDifference(180, 0).abs(), 180);
    });

    test('compassName', () {
      expect(GeoUtils.compassName(0), 'Utara');
      expect(GeoUtils.compassName(45), 'Timur Laut');
      expect(GeoUtils.compassName(295), 'Barat Laut');
      expect(GeoUtils.compassName(359), 'Utara');
    });
  });
}
