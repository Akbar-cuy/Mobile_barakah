// Token warna dari design.md (bagian 3 dan 4).
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0E6B57),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFCFEDE3),
    onPrimaryContainer: Color(0xFF00382C),
    secondary: Color(0xFFA9791C),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF6E7C1),
    onSecondaryContainer: Color(0xFF3A2800),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFFBFAF6),
    onSurface: Color(0xFF1B1F1D),
    onSurfaceVariant: Color(0xFF4A524E),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFF1EFE8),
    surfaceContainerHigh: Color(0xFFE7E4DB),
    outline: Color(0xFFC9CEC9),
  );

  static const darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF6FD3B6),
    onPrimary: Color(0xFF00382C),
    primaryContainer: Color(0xFF0A4F40),
    onPrimaryContainer: Color(0xFFCFEDE3),
    secondary: Color(0xFFE3B45B),
    onSecondary: Color(0xFF3A2800),
    secondaryContainer: Color(0xFF5A4210),
    onSecondaryContainer: Color(0xFFF6E7C1),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    surface: Color(0xFF121614),
    onSurface: Color(0xFFE4E8E5),
    onSurfaceVariant: Color(0xFFB4BCB7),
    surfaceContainerLowest: Color(0xFF0D100F),
    surfaceContainer: Color(0xFF1B201E),
    surfaceContainerHigh: Color(0xFF252B28),
    outline: Color(0xFF414844),
  );
}

@immutable
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.success,
    required this.warning,
    required this.info,
  });

  final Color success;
  final Color warning;
  final Color info;

  static const light = AppStatusColors(
    success: Color(0xFF1E7B4A),
    warning: Color(0xFFB26A00),
    info: Color(0xFF1F5F8B),
  );

  static const dark = AppStatusColors(
    success: Color(0xFF7FD6A0),
    warning: Color(0xFFF0B25A),
    info: Color(0xFF8EC5EA),
  );

  @override
  AppStatusColors copyWith({Color? success, Color? warning, Color? info}) {
    return AppStatusColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  AppStatusColors lerp(ThemeExtension<AppStatusColors>? other, double t) {
    if (other is! AppStatusColors) return this;
    return AppStatusColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
