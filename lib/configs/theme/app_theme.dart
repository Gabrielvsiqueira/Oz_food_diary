import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.primaryLight,
      onSecondary: AppColors.onPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceVariant,
      outline: AppColors.border,
      error: AppColors.error,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.onSurface,
        displayColor: AppColors.onSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.onSurfaceMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: 14,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXxl),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surfaceVariant,
        contentTextStyle: TextStyle(color: AppColors.onSurface),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceVariant,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: AppColors.surface,
      ),
    );
  }
}
