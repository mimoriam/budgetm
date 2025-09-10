// ignore_for_file: file_names

import 'package:budgetm/constants/appColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final TextTheme _baseTextTheme = GoogleFonts.rubikTextTheme();

  static final TextTheme _lightTextTheme = _baseTextTheme.copyWith(
    displayLarge: _baseTextTheme.displayLarge?.copyWith(
      fontSize: 32.0,
      fontWeight: FontWeight.w700,
      color: AppColors.primaryTextColorLight,
    ),
    bodyLarge: _baseTextTheme.bodyLarge?.copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      color: AppColors.secondaryTextColorLight,
    ),
    bodyMedium: _baseTextTheme.bodyMedium?.copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      color: AppColors.secondaryTextColorLight,
    ),
    labelLarge: _baseTextTheme.labelLarge?.copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryTextColorLight,
    ),
    titleMedium: _baseTextTheme.titleMedium?.copyWith(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryTextColorLight,
    ),
  );

  static final TextTheme _darkTextTheme = _baseTextTheme.copyWith(
    displayLarge: _baseTextTheme.displayLarge?.copyWith(
      fontSize: 32.0,
      fontWeight: FontWeight.w700,
      color: AppColors.primaryTextColorDark,
    ),
    bodyLarge: _baseTextTheme.bodyLarge?.copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      color: AppColors.secondaryTextColorDark,
    ),
    bodyMedium: _baseTextTheme.bodyMedium?.copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      color: AppColors.secondaryTextColorDark,
    ),
    labelLarge: _baseTextTheme.labelLarge?.copyWith(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryTextColorLight,
    ),
    titleMedium: _baseTextTheme.titleMedium?.copyWith(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryTextColorDark,
    ),
  );

  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.gradientEnd,
      scaffoldBackgroundColor: AppColors.lightBackgroundColor,
      textTheme: _lightTextTheme,
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.gradientEnd,
        secondary: AppColors.gradientStart,
        background: AppColors.lightBackgroundColor,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.gradientEnd,
      scaffoldBackgroundColor: AppColors.darkBackgroundColor,
      textTheme: _darkTextTheme,
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gradientEnd,
        secondary: AppColors.gradientStart,
        background: AppColors.darkBackgroundColor,
      ),
    );
  }
}
