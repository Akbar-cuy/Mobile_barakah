// Vektor diverifikasi dengan implementasi referensi independen (Node).
import 'dart:math' as math;

import 'package:barakah/features/qibla/services/compass_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const g = 9.81;

  double? flat(double mx, double my, double mz) => CompassMath.headingFrom(
        accel: const Vec3(0, 0, g),
        magnetic: Vec3(mx, my, mz),
      );

  double? upright(double mx, double my, double mz) => CompassMath.headingFrom(
        accel: const Vec3(0, g, 0),
        magnetic: Vec3(mx, my, mz),
      );

  group('CompassMath.headingFrom', () {
    test('ponsel datar: atas menghadap utara, timur, selatan, barat', () {
      expect(flat(0, 20, -40), closeTo(0, 0.01));
      expect(flat(-20, 0, -40), closeTo(90, 0.01));
      expect(flat(0, -20, -40), closeTo(180, 0.01));
      expect(flat(20, 0, -40), closeTo(270, 0.01));
    });

    test('ponsel tegak: belakang menghadap utara, timur, selatan, barat', () {
      expect(upright(0, -40, -20), closeTo(0, 0.01));
      expect(upright(-20, -40, 0), closeTo(90, 0.01));
      expect(upright(0, -40, 20), closeTo(180, 0.01));
      expect(upright(20, -40, 0), closeTo(270, 0.01));
    });

    test('miring 30 derajat tetap menunjuk timur', () {
      final t = 30 * math.pi / 180;
      final h = CompassMath.headingFrom(
        accel: Vec3(0, g * math.sin(t), g * math.cos(t)),
        magnetic: Vec3(-20, -40 * math.sin(t), -40 * math.cos(t)),
      );
      expect(h, closeTo(90, 0.01));
    });

    test('jatuh bebas (akselerasi nol) tidak menghasilkan heading', () {
      expect(
        CompassMath.headingFrom(
          accel: const Vec3(0, 0, 0),
          magnetic: const Vec3(0, 20, -40),
        ),
        isNull,
      );
    });
  });

  group('CompassQuality.evaluate', () {
    final steady = List.filled(16, 45.0);

    test('medan normal dan stabil: tinggi', () {
      expect(CompassQuality.evaluate(strength: 45, recent: steady), CompassAccuracy.high);
    });

    test('medan di luar 25-65 uT tetapi masih wajar: rendah', () {
      expect(CompassQuality.evaluate(strength: 20, recent: steady), CompassAccuracy.low);
      expect(CompassQuality.evaluate(strength: 70, recent: steady), CompassAccuracy.low);
    });

    test('interferensi kuat: tidak andal', () {
      expect(CompassQuality.evaluate(strength: 10, recent: steady), CompassAccuracy.unreliable);
      expect(CompassQuality.evaluate(strength: 90, recent: steady), CompassAccuracy.unreliable);
      expect(CompassQuality.hasInterference(90), isTrue);
      expect(CompassQuality.hasInterference(45), isFalse);
    });

    test('sampel sangat berisik: tidak andal', () {
      final noisy = [for (var i = 0; i < 16; i++) i.isEven ? 30.0 : 60.0];
      expect(CompassQuality.evaluate(strength: 45, recent: noisy), CompassAccuracy.unreliable);
    });
  });
}
