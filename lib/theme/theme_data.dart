import 'package:flutter/material.dart';

class AppTheme {
  // Warna utama dalam aplikasi
  static const Color primaryColor = Color(0xFF0A4EFA);
  static const Color primaryDark = Color(0xFF0943D6);
  static const Color primaryDarker = Color(0xFF0736AD);
  static const Color accentColor = Color(0xFFF9C509);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFE2360F);
  static const Color successColor = Color(0xFF29A900);
  static const Color textColor = Color(0xFF000000);
  static const Color textSecondary = Color(0x73000000); // 45% hitam

  static final ThemeData themeData = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,

    // Gunakan ColorScheme baru
    colorScheme: ColorScheme(
      primary: primaryColor,
      primaryContainer: primaryDark,
      secondary: accentColor,
      secondaryContainer: successColor,
      surface: Colors.white,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      tertiary: textSecondary,
      brightness: Brightness.light,
    ),

    // Typography dengan font Inter
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor),
      displayMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor),
      displaySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor),
      headlineMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textColor),
      headlineSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor),
      titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textColor),
      bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textColor),
      bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary),
      labelLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textColor),
      labelMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor),
    ),

    // Theme untuk tombol
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
            fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        side: const BorderSide(color: primaryDark, width: .5),
        textStyle: const TextStyle(
            fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryDark,
        textStyle: const TextStyle(
            fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
