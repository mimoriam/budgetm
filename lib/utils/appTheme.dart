// ignore_for_file: file_names

import 'package:budgetm/constants/appColors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Converts a hex color string to a Color object.
///
/// Supports formats: #RRGGBB, #AARRGGBB, RRGGBB, AARRGGBB
/// Returns Colors.grey.shade100 if the hex string is null, empty, or invalid.
Color hexToColor(String? hexString) {
  if (hexString == null || hexString.isEmpty) {
    return Colors.grey.shade100;
  }
  
  // Remove the leading # if present
  String hex = hexString.replaceAll('#', '');
  
  // If the hex string is too short, pad it
  if (hex.length == 6) {
    hex = 'FF$hex'; // Add full opacity
  } else if (hex.length == 3) {
    hex = 'FF${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}'; // Expand and add opacity
  } else if (hex.length == 4) {
    hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}${hex[3]}${hex[3]}'; // Expand
  }
  
  // Validate the hex string
  if (hex.length != 8 || !RegExp(r'^[0-9A-Fa-f]+$').hasMatch(hex)) {
    return Colors.grey.shade100;
  }
  
  try {
    // Parse the hex string to an integer
    final colorValue = int.parse(hex, radix: 16);
    return Color(colorValue);
  } catch (e) {
    // If parsing fails, return the default color
    return Colors.grey.shade100;
  }
}

/// Determines if a color is light or dark to ensure good contrast.
///
/// Returns true if the color is light, false if it's dark.
bool isColorLight(Color color) {
  // Calculate the luminance of the color
  double luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
  return luminance > 0.5;
}

/// Returns a contrasting color (black or white) based on the background color.
///
/// Ensures text/icons have good contrast against the background.
Color getContrastingColor(Color backgroundColor) {
  return isColorLight(backgroundColor) ? Colors.black87 : Colors.white;
}

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
