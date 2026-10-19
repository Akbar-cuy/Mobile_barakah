// Fondasi lintas fitur. Validasi formulir (FR-AUTH-02, FR-FB-02, FR-ZKT-04).
import '../constants/app_constants.dart';
import 'formatters.dart';

abstract final class Validators {
  static String? required(String? v, {String field = 'Kolom ini'}) {
    if (v == null || v.trim().isEmpty) return '$field wajib diisi.';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email wajib diisi.';
    if (!AppConstants.emailPattern.hasMatch(v.trim())) return 'Email tidak valid.';
    return null;
  }

  static String? username(String? v) {
    if (v == null || v.trim().isEmpty) return 'Nama pengguna wajib diisi.';
    if (v.trim().length < AppConstants.usernameMinLength) {
      return 'Nama pengguna minimal ${AppConstants.usernameMinLength} karakter.';
    }
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Kata sandi wajib diisi.';
    if (!AppConstants.passwordPattern.hasMatch(v)) {
      return 'Minimal ${AppConstants.passwordMinLength} karakter, berisi huruf dan angka.';
    }
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return 'Ulangi kata sandi.';
    if (v != original) return 'Konfirmasi kata sandi tidak sama.';
    return null;
  }

  static String? feedbackText(String? v, {String field = 'Teks'}) {
    final length = v?.trim().length ?? 0;
    if (length < AppConstants.feedbackTextMin) {
      return '$field minimal ${AppConstants.feedbackTextMin} karakter.';
    }
    if (length > AppConstants.feedbackTextMax) {
      return '$field maksimal ${AppConstants.feedbackTextMax} karakter.';
    }
    return null;
  }

  static String? rating(int? v) {
    if (v == null || v < AppConstants.feedbackRatingMin || v > AppConstants.feedbackRatingMax) {
      return 'Pilih penilaian bintang.';
    }
    return null;
  }

  static String? amount(String? v) {
    if (v == null || v.trim().isEmpty) return 'Nominal wajib diisi.';
    final parsed = Formatters.parseAmount(v);
    if (parsed == null) return 'Nominal tidak valid.';
    if (parsed <= 0) return 'Nominal harus lebih dari nol.';
    return null;
  }
}
