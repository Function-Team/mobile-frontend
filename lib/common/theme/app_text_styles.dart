import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyle {
  static const TextTheme textTheme = TextTheme(
    // Used for main headlines on landing pages or major sections
    displayLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textColor,
    ),
    // Used for secondary headlines or important section titles
    displayMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.textColor,
    ),
    // Used for tertiary headlines or subsection titles
    displaySmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.textColor,
    ),
    // Used for card titles or important content headers
    headlineMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textColor,
    ),
    // Used for smaller headers or emphasized content
    headlineSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textColor,
    ),
    // Used for primary content titles or navigation items
    titleLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.textColor,
    ),
    // Used for main body text and primary content
    bodyLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textColor,
    ),
    // Used for secondary content, descriptions, or helper text
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    // Used for buttons and interactive elements
    labelLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.textColor,
    ),
    // Used for form labels and medium-emphasis interactive elements
    labelMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textColor,
    ),
    // Used for small labels, captions, or helper text
    labelSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.textColor,
    ),
  );
}
