import 'package:barakah/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('AC-AUTH-06: kata sandi kurang dari 8 karakter ditolak', () {
      expect(Validators.password('abc123'), isNotNull);
    });

    test('kata sandi harus berisi huruf dan angka', () {
      expect(Validators.password('abcdefgh'), isNotNull);
      expect(Validators.password('12345678'), isNotNull);
      expect(Validators.password('abcd1234'), isNull);
    });

    test('email', () {
      expect(Validators.email('rizky@mail.com'), isNull);
      expect(Validators.email('rizky@mail'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('nama pengguna minimal 3 karakter', () {
      expect(Validators.username('ab'), isNotNull);
      expect(Validators.username('abc'), isNull);
    });

    test('konfirmasi kata sandi harus sama', () {
      expect(Validators.confirmPassword('abcd1234', 'abcd1234'), isNull);
      expect(Validators.confirmPassword('abcd1235', 'abcd1234'), isNotNull);
    });

    test('AC-FB-02: kesan minimal 10 karakter, maksimal 500', () {
      expect(Validators.feedbackText('pendek'), isNotNull);
      expect(Validators.feedbackText('cukup panjang sekali'), isNull);
      expect(Validators.feedbackText('a' * 501), isNotNull);
    });

    test('AC-ZKT-04: nominal kosong, nol, dan negatif ditolak', () {
      expect(Validators.amount(''), isNotNull);
      expect(Validators.amount('0'), isNotNull);
      expect(Validators.amount('-5'), isNotNull);
      expect(Validators.amount('abc'), isNotNull);
      expect(Validators.amount('100.000'), isNull);
    });

    test('penilaian bintang 1 sampai 5', () {
      expect(Validators.rating(null), isNotNull);
      expect(Validators.rating(0), isNotNull);
      expect(Validators.rating(5), isNull);
    });
  });
}
