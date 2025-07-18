import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:function_mobile/common/bindings/localization_binding.dart';
import 'package:get/get.dart';

class LocalizationHelper {
  /// Main translation method that uses the BuildContext
  static String tr(BuildContext context, String key) {
    try {
      // Explicitly use easy_localization to avoid ambiguity
      return easy.StringTranslateExtension(key).tr();
    } catch (e) {
      if (kDebugMode) {
        print('! Translation error for key: $key, error: $e');
      }
      return key;
    }
  }
  
  /// Translation with named arguments
  static String trArgs(BuildContext context, String key, Map<String, String> namedArgs) {
    try {
      return easy.StringTranslateExtension(key).tr(namedArgs: namedArgs);
    } catch (e) {
      if (kDebugMode) {
        print('! Translation error for key: $key with args: $namedArgs, error: $e');
      }
      return key;
    }
  }
  
  /// Plural translation
  static String trPlural(BuildContext context, String key, int count) {
    try {
      return easy.StringTranslateExtension(key).plural(count);
    } catch (e) {
      if (kDebugMode) {
        print('! Translation error for key: $key with count: $count, error: $e');
      }
      return '$key ($count)';
    }
  }
  
  /// Translation with fallback
  static String trSafe(BuildContext context, String key, {String? fallback}) {
    try {
      final translated = easy.StringTranslateExtension(key).tr();
      return translated != key ? translated : (fallback ?? key);
    } catch (e) {
      if (kDebugMode) {
        print('! Translation error for key: $key, error: $e');
      }
      return fallback ?? key;
    }
  }
  
  /// Change the app's language using a simpler approach that is less likely to cause ANR
  static Future<void> changeLanguage(BuildContext context, Locale locale) async {
    try {
      // First, set the locale using context to ensure proper dependency tracking
      await context.setLocale(locale);
      
      // Update the localization controller
      try {
        final localizationController = Get.find<LocalizationController>();
        localizationController.updateLocale(locale.toString());
      } catch (e) {
        print("⚠️ Could not update LocalizationController: $e");
      }
      
      // Show success message immediately
      _showSuccessMessage(context, locale);
      
      // SAFER APPROACH: Instead of complex navigation, simply restart the app
      // by rebuilding the UI from scratch
      final currentRoute = Get.currentRoute;
      
      // Only do a light refresh if we're on a simple page
      if (currentRoute == '/LanguageSettingsPage') {
        // Just go back to previous screen to avoid ANR
        await Future.delayed(const Duration(milliseconds: 100));
        Get.back();
      }
      
      if (kDebugMode) {
        debugCurrentLocale(context);
        print("✅ Language changed successfully to: ${locale.toString()}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error changing language: $e");
      }
    }
  }
  
  /// Show success message after language change
  static void _showSuccessMessage(BuildContext context, Locale locale) {
    try {
      final languageName = getLanguageName(locale.languageCode);
      Get.snackbar(
        tr(context, 'common.success'),
        trArgs(context, 'settings.language_changed', {'language': languageName}),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
    } catch (e) {
      print("⚠️ Could not show success message: $e");
    }
  }
  
  /// Debug current locale information
  static void debugCurrentLocale(BuildContext context) {
    try {
      final currentLocale = context.locale;
      
      print("==================================================");
      print("🌍 LANGUAGE DEBUG INFO");
      print("==================================================");
      print("Current Locale: ${currentLocale.toString()}");
      print("Language Code: ${currentLocale.languageCode}");
      print("Country Code: ${currentLocale.countryCode}");
      print("Language Name: ${getLanguageName(currentLocale.languageCode)}");
      print("Language Flag: ${getLanguageFlag(currentLocale.languageCode)}");
      print("==================================================");
    } catch (e) {
      print("❌ Debug locale error: $e");
    }
  }
  
  /// Get language name from language code
  static String getLanguageName(String languageCode) {
    final languageNames = {
      'en': 'English',
      'id': 'Bahasa Indonesia',
    };
    
    return languageNames[languageCode] ?? 'Unknown';
  }
  
  /// Get language flag from language code
  static String getLanguageFlag(String languageCode) {
    final languageFlags = {
      'en': '🇺🇸',
      'id': '🇮🇩',
    };
    
    return languageFlags[languageCode] ?? '🏳️';
  }
  
  /// Legacy method for backward compatibility
  /// @deprecated Use tr(context, key) instead for better rebuilding behavior
  static String t(String key) {
    try {
      final translated = easy.StringTranslateExtension(key).tr();
      if (kDebugMode && translated == key) {
        print('! Translation missing for key: $key');
      }
      return translated;
    } catch (e) {
      if (kDebugMode) {
        print('! Translation error for key: $key, error: $e');
      }
      return key;
    }
  }
}