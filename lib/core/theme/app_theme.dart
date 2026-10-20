// Tema terang dan gelap sesuai design.md.
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppRadius {
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 20.0;
  static const extra = 28.0;
  static const full = 999.0;
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const page = 20.0;
}

abstract final class AppTheme {
  static ThemeData light() =>
      _build(AppColors.lightScheme, AppStatusColors.light);

  static ThemeData dark() => _build(AppColors.darkScheme, AppStatusColors.dark);

  static ThemeData _build(ColorScheme s, AppStatusColors status) {
    final text = AppTextStyles.textTheme(s);

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: s,
      scaffoldBackgroundColor: s.surface,
      fontFamily: AppTextStyles.fontFamily,
      textTheme: text,
      extensions: [status],
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: s.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: text.bodyMedium?.copyWith(color: s.onSurfaceVariant),
        border: border(s.outline),
        enabledBorder: border(s.outline),
        focusedBorder: border(s.primary, 2),
        errorBorder: border(s.error),
        focusedErrorBorder: border(s.error, 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          side: BorderSide(color: s.outline),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: const StadiumBorder(),
          textStyle: text.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: s.outline),
        labelStyle: text.bodyMedium,
        selectedColor: s.primaryContainer,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: s.surface,
        indicatorColor: s.primaryContainer,
        elevation: 3,
        height: 68,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: s.onSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: s.surface),
        shape: const StadiumBorder(),
      ),
      dividerTheme: DividerThemeData(color: s.outline, space: 1),
    );
  }
}
