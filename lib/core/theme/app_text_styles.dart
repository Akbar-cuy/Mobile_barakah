// Tipografi dari design.md bagian 5. Berkas font ditambahkan di pubspec.yaml
// (lihat README_TAHAP2.md). Tanpa berkas font, Flutter memakai font bawaan.
import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  static const fontFamily = 'PlusJakartaSans';
  static const arabicFamily = 'NotoNaskhArabic';
  static const monoFamily = 'JetBrainsMono';

  static TextStyle _s(double size, double line, FontWeight weight) => TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        height: line / size,
        fontWeight: weight,
      );

  static TextTheme textTheme(ColorScheme scheme) {
    return TextTheme(
      displayLarge: _s(36, 44, FontWeight.w700).copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      headlineMedium: _s(28, 36, FontWeight.w700),
      titleLarge: _s(20, 28, FontWeight.w600),
      titleMedium: _s(16, 24, FontWeight.w600),
      titleSmall: _s(14, 20, FontWeight.w600),
      bodyLarge: _s(16, 24, FontWeight.w400),
      bodyMedium: _s(14, 20, FontWeight.w400),
      bodySmall: _s(12, 16, FontWeight.w400),
      labelLarge: _s(14, 20, FontWeight.w600),
      labelMedium: _s(12, 16, FontWeight.w600),
      labelSmall: _s(12, 16, FontWeight.w600),
    ).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
  }

  static const arabic = TextStyle(
    fontFamily: arabicFamily,
    fontSize: 24,
    height: 40 / 24,
  );

  static const hash = TextStyle(
    fontFamily: monoFamily,
    fontSize: 12,
    height: 16 / 12,
  );
}
