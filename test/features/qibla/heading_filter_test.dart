import 'package:barakah/features/qibla/services/heading_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HeadingFilter', () {
    test('sampel pertama dipakai apa adanya', () {
      final f = HeadingFilter();
      expect(f.update(magneticHeading: 123, dtSeconds: 0.06), closeTo(123, 1e-9));
    });

    test('melintasi utara tidak melonjak (359 ke 1)', () {
      final f = HeadingFilter();
      f.update(magneticHeading: 359, yawRateDegPerSec: 0, dtSeconds: 0.06);
      final next = f.update(magneticHeading: 1, yawRateDegPerSec: 0, dtSeconds: 0.06);
      // Harus bergerak sedikit ke arah 1 melalui 0, bukan ke arah ~180.
      final circular = ((next - 359 + 540) % 360) - 180;
      expect(circular, inInclusiveRange(0, 2));
    });

    test('konvergen ke heading magnetik tetap', () {
      final f = HeadingFilter();
      f.update(magneticHeading: 10, yawRateDegPerSec: 0, dtSeconds: 0.06);
      var h = 0.0;
      for (var i = 0; i < 400; i++) {
        h = f.update(magneticHeading: 100, yawRateDegPerSec: 0, dtSeconds: 0.06);
      }
      expect(h, closeTo(100, 0.5));
    });

    test('tanpa gyroscope tetap konvergen', () {
      final f = HeadingFilter();
      f.update(magneticHeading: 10, dtSeconds: 0.06);
      var h = 0.0;
      for (var i = 0; i < 100; i++) {
        h = f.update(magneticHeading: 200, dtSeconds: 0.06);
      }
      expect(h, closeTo(200, 0.5));
    });

    test('reset menghapus riwayat', () {
      final f = HeadingFilter()..update(magneticHeading: 50, dtSeconds: 0.06);
      f.reset();
      expect(f.heading, isNull);
    });
  });

  group('HeadingUnwrapper', () {
    test('359 ke 1 derajat hanya bergerak 2 derajat', () {
      final u = HeadingUnwrapper();
      final a = u.unwrap(359);
      final b = u.unwrap(1);
      expect(b - a, closeTo(2, 1e-9));
    });

    test('putaran penuh searah jarum jam terakumulasi', () {
      final u = HeadingUnwrapper();
      var last = 0.0;
      for (var d = 0; d <= 720; d += 30) {
        last = u.unwrap((d % 360).toDouble());
      }
      expect(last, closeTo(720, 1e-9));
    });

    test('berbalik arah melewati nol menjadi negatif', () {
      final u = HeadingUnwrapper();
      u.unwrap(5);
      expect(u.unwrap(355), closeTo(-5, 1e-9));
    });
  });
}
