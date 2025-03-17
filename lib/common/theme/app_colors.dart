// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryColor = Color(0xFF0A4EFA);
  static const Color primaryDark = Color(0xFF0943D6);
  static const Color primaryDarker = Color(0xFF0736AD);

  // Secondary Colors
  static const Color accentColor = Color(0xFFF9C509);

  // Status Colors
  static const Color errorColor = Color(0xFFE2360F);
  static const Color successColor = Color(0xFF29A900);

  // Background Colors
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color surfaceColor = Colors.white;

  // Text Colors
  static const Color textColor = Color(0xFF000000);
  static const Color textSecondary = Color(0x73000000); // 45% hitam

  // ColorScheme Colors
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onSurface = Colors.black;
  static const Color onBackground = textColor;
  static const Color onError = Colors.white;
  static const Color tertiary = textSecondary;

  // Static ColorScheme
  static const ColorScheme colorScheme = ColorScheme(
    primary: primaryColor,
    primaryContainer: primaryDark,
    secondary: accentColor,
    secondaryContainer: successColor,
    surface: surfaceColor,
    background: backgroundColor,
    error: errorColor,
    onPrimary: onPrimary,
    onSecondary: onSecondary,
    onSurface: onSurface,
    onBackground: onBackground,
    onError: onError,
    tertiary: tertiary,
    brightness: Brightness.light,
  );
}
