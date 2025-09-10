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
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightLime,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        prefixIconColor: AppColors.secondaryTextColorLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBackground,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          textStyle: _lightTextTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gradientEnd,
          textStyle: _lightTextTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkGreyBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        prefixIconColor: AppColors.secondaryTextColorDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonBackground,
          foregroundColor: AppColors.primaryTextColorLight,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          textStyle: _darkTextTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gradientEnd,
          textStyle: _darkTextTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gradientEnd,
        secondary: AppColors.gradientStart,
        background: AppColors.darkBackgroundColor,
      ),
    );
  }
}
