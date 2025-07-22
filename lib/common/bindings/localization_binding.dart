import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocalizationBinding extends Bindings {
  @override
  void dependencies() {
    // Setup a controller that can notify when language changes
    Get.put(LocalizationController(), permanent: true);
  }
}

class LocalizationController extends GetxController {
  // Observable locale to help track changes
  final Rx<String> currentLocale = ''.obs;
  
  // Observable for language change state
  final RxBool isChangingLanguage = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeLocale();
  }
  
  void _initializeLocale() {
    try {
      if (Get.context != null) {
        final context = Get.context!;
        final locale = context.locale.toString();
        currentLocale.value = locale;
        
        debugPrint('🌍 LocalizationController initialized with locale: $locale');
        
        // Listen to locale changes and trigger UI updates
        ever(currentLocale, (String newLocale) {
          debugPrint('📢 Locale changed to: $newLocale');
          // Force a complete UI refresh
          Get.forceAppUpdate();
        });
      }
    } catch (e) {
      debugPrint('❌ Error initializing LocalizationController: $e');
      // Set fallback locale
      currentLocale.value = 'en';
    }
  }
  
  /// Update locale when changed - this triggers reactive UI updates
  void updateLocale(String locale) {
    if (currentLocale.value != locale) {
      isChangingLanguage.value = true;
      currentLocale.value = locale;
      
      // Reset the changing state after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        isChangingLanguage.value = false;
      });
    }
  }
  
  /// Get current locale as Locale object
  Locale get currentLocaleObject {
    final parts = currentLocale.value.split('_');
    if (parts.length > 1) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }
  
  /// Get current language code
  String get currentLanguageCode {
    return currentLocaleObject.languageCode;
  }
  
  /// Check if specific language is current
  bool isCurrentLanguage(String languageCode) {
    return currentLanguageCode == languageCode;
  }
  
  /// Get supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('id'),
  ];
  
  /// Get supported language codes
  static const List<String> supportedLanguageCodes = ['en', 'id'];
  
  /// Check if language is supported
  bool isLanguageSupported(String languageCode) {
    return supportedLanguageCodes.contains(languageCode);
  }
}