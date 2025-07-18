import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalizationHelper {
  static String tr(String key) => easy.StringTranslateExtension(key).tr();

  // Translation with arguments
  static String trArgs(String key, Map<String, String> args) =>
      easy.StringTranslateExtension(key).tr(namedArgs: args);

  // Plural translation
  static String trPlural(String key, int count) =>
      easy.StringTranslateExtension(key).plural(count);

  // Get language name
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'id':
        return 'Bahasa Indonesia';
      default:
        return 'Unknown';
    }
  }

  // Get language flag
  static String getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'id':
        return '🇮🇩';
      default:
        return '🏳️';
    }
  }

  static Future<void> changeLanguage(
      BuildContext context, String languageCode) async {
    try {
      final locale = Locale(languageCode);

      await context.setLocale(locale);

      await Future.delayed(const Duration(milliseconds: 300));

    } catch (e) {
      print('Error changing language: $e');
    }
  }
}
