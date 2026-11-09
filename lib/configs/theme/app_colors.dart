import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFF0C0B09);
  static const surface = Color(0xFF171512);
  static const surfaceVariant = Color(0xFF211E1A);
  static const border = Color(0xFF2E2A24);

  static const onSurface = Color(0xFFF7F5F0);
  static const onSurfaceSecondary = Color(0xFFA39E94);
  static const onSurfaceMuted = Color(0xFF6F6A61);
  static const primary = Color(0xFF66D97A);
  static const primaryLight = Color(0xFFA3EBAE);
  static const onPrimary = Color(0xFF0A2E12);

  static const resultBackground = Color(0xFF172417);

  static const error = Color(0xFFF47A6E);

  static const calories = primary;
  static const protein = Color(0xFF6AA8F0); // azul: construção, força
  static const carbs = Color(0xFFFBBF24); // âmbar: energia (âncora da paleta)
  static const fat = Color(0xFFC88BF0); // lilás: neutro, sem conotação negativa

  static Color caloriesFor({required double consumed, required double goal}) =>
      consumed > goal ? error : calories;
}
