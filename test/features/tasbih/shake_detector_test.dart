import 'package:barakah/features/qibla/services/compass_math.dart';
import 'package:barakah/features/tasbih/services/shake_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 12);
  const still = Vec3(0, 0, 9.81);
  const strong = Vec3(0, 0, 25);

  group('ShakeDetector', () {
    test('diam (sekitar gravitasi) tidak dihitung', () {
      final d = ShakeDetector();
      expect(d.process(still, t0), isFalse);
    });

    test('goyangan kuat dihitung sekali (AC-TSB-01)', () {
      final d = ShakeDetector();
      expect(d.process(strong, t0), isTrue);
    });

    test('debounce 500 ms menolak hitungan beruntun', () {
      final d = ShakeDetector();
      expect(d.process(strong, t0), isTrue);
      expect(d.process(strong, t0.add(const Duration(milliseconds: 200))), isFalse);
      expect(d.process(strong, t0.add(const Duration(milliseconds: 499))), isFalse);
      expect(d.process(strong, t0.add(const Duration(milliseconds: 500))), isTrue);
    });

    test('sensitivitas: ambang rendah/sedang/tinggi = 20/15/12', () {
      expect(ShakeSensitivity.low.threshold, 20);
      expect(ShakeSensitivity.medium.threshold, 15);
      expect(ShakeSensitivity.high.threshold, 12);
    });

    test('sampel 17 m/s2 hanya lolos pada sensitivitas sedang dan tinggi', () {
      const sample = Vec3(0, 0, 17);
      for (final entry in {
        ShakeSensitivity.low: false,
        ShakeSensitivity.medium: true,
        ShakeSensitivity.high: true,
      }.entries) {
        final d = ShakeDetector(threshold: entry.key.threshold);
        expect(d.process(sample, t0), entry.value, reason: entry.key.id);
      }
    });

    test('ambang dapat diubah saat berjalan', () {
      final d = ShakeDetector(threshold: 20);
      const sample = Vec3(0, 0, 17);
      expect(d.process(sample, t0), isFalse);
      d.threshold = 12;
      expect(d.process(sample, t0), isTrue);
    });

    test('fromId jatuh ke sedang untuk nilai tak dikenal', () {
      expect(ShakeSensitivity.fromId('tinggi'), ShakeSensitivity.high);
      expect(ShakeSensitivity.fromId(null), ShakeSensitivity.medium);
      expect(ShakeSensitivity.fromId('x'), ShakeSensitivity.medium);
    });
  });
}
