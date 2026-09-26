import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const fontFamily = 'HostGrotesk';

  static const _regular = FontWeight.w400;
  static const _medium = FontWeight.w500;
  static const _semiBold = FontWeight.w600;

  static const textTheme = TextTheme(
    displaySmall: TextStyle(
      fontSize: 32,
      height: 40 / 32,
      fontWeight: _semiBold,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      height: 36 / 28,
      fontWeight: _semiBold,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      height: 32 / 24,
      fontWeight: _semiBold,
    ),
    titleLarge: TextStyle(fontSize: 20, height: 24 / 20, fontWeight: _medium),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 24 / 16,
      fontWeight: _semiBold,
    ),
    titleSmall: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: _semiBold),
    bodyLarge: TextStyle(fontSize: 16, height: 24 / 16, fontWeight: _regular),
    bodyMedium: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: _regular),
    bodySmall: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: _regular),
    labelLarge: TextStyle(fontSize: 16, height: 24 / 16, fontWeight: _medium),
    labelMedium: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: _medium),
    labelSmall: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: _medium),
  );

  /// "REFEIÇÕES", "HOJE, 12 DE JULHO" — caption com espaçamento largo.
  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1,
    fontWeight: _medium,
    letterSpacing: 1.2,
    color: AppColors.onSurfaceSecondary,
  );
}
