import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:function_mobile/common/bindings/localization_binding.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:get/get.dart';

class LocalizationHelper {
  /// Simple translation using generated keys
  static String tr(String key) => easy.StringTranslateExtension(key).tr();

  /// Translation with named arguments
  static String trArgs(String key, Map<String, String> args) =>
      easy.StringTranslateExtension(key).tr(namedArgs: args);

  /// Plural translation
  static String trPlural(String key, int count) =>
      easy.StringTranslateExtension(key).plural(count);

  /// Get language name in the target language
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'id':
        return 'Bahasa Indonesia';
      default:
        return tr(LocaleKeys.common_unknown);
    }
  }

  /// Get language flag emoji
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

  /// Get current locale
  static Locale getCurrentLocale() {
    try {
      // Try to get locale from LocalizationController first (safer)
      if (Get.isRegistered<LocalizationController>()) {
        final controller = Get.find<LocalizationController>();
        return controller.currentLocaleObject;
      }
      
      // Fallback to Get.context only if controller is not available
      if (Get.context != null && Get.context!.mounted) {
        return Get.context!.locale;
      }
    } catch (e) {
      debugPrint('❌ Error getting current locale: $e');
    }
    
    return const Locale('en'); // fallback
  }

  /// Get current language code
  static String getCurrentLanguageCode() {
    return getCurrentLocale().languageCode;
  }

  /// Check if current language is RTL
  static bool isRTL() {
    final languageCode = getCurrentLanguageCode();
    return ['ar', 'he', 'fa', 'ur'].contains(languageCode);
  }

  /// Change app language with proper GetX integration
  static Future<void> changeLanguage(
    BuildContext context,
    String languageCode,
  ) async {
    if (!context.mounted) {
      debugPrint('❌ Context is not mounted, cannot change language');
      return;
    }

    try {
      final locale = Locale(languageCode);

      // Update GetX controller first to prevent context issues
      if (Get.isRegistered<LocalizationController>()) {
        final localizationController = Get.find<LocalizationController>();
        localizationController.updateLocale(locale.toString());
      }

      // Change the easy_localization locale
      await context.setLocale(locale);

      // Small delay to ensure the change is applied
      await Future.delayed(const Duration(milliseconds: 300));

      // Debug print
      debugPrint('🌍 Language changed to: $languageCode');

      // Show success message using generated keys - use safe context check
      if (context.mounted) {
        CustomSnackbar.show(
          context: context, 
          message: tr(LocaleKeys.settings_changeLanguageConfirm), 
          type: SnackbarType.success
        );
      }
    } catch (e) {
      debugPrint('❌ Error changing language: $e');
      if (context.mounted) {
        CustomSnackbar.show(
          context: context, 
          message: tr(LocaleKeys.common_error), 
          type: SnackbarType.error
        );
      }
    }
  }

  /// Get supported locales
  static List<Locale> getSupportedLocales() {
    return const [
      Locale('en'),
      Locale('id'),
    ];
  }

  /// Get supported language codes
  static List<String> getSupportedLanguageCodes() {
    return getSupportedLocales().map((locale) => locale.languageCode).toList();
  }

  /// Check if language is supported
  static bool isLanguageSupported(String languageCode) {
    return getSupportedLanguageCodes().contains(languageCode);
  }

  /// Get fallback locale
  static Locale getFallbackLocale() {
    return const Locale('en');
  }

  /// Format date according to current locale
  static String formatDate(DateTime date) {
    final locale = getCurrentLocale();
    return DateFormat.yMMMd(locale.toString()).format(date);
  }

  /// Format time according to current locale
  static String formatTime(DateTime time) {
    final locale = getCurrentLocale();
    return DateFormat.Hm(locale.toString()).format(time);
  }

  /// Format currency according to current locale
  static String formatCurrency(double amount) {
    final languageCode = getCurrentLanguageCode();
    final locale = getCurrentLocale().toString();

    switch (languageCode) {
      case 'id':
        return NumberFormat.currency(
          locale: locale,
          symbol: 'Rp ',
          decimalDigits: 0,
        ).format(amount);
      case 'en':
      default:
        return NumberFormat.currency(
          locale: locale,
          symbol: '\$ ',
          decimalDigits: 2,
        ).format(amount);
    }
  }

  /// Debug current locale info
  static void debugCurrentLocale() {
    final locale = getCurrentLocale();
    debugPrint('\n' + '=' * 50);
    debugPrint('🌍 LOCALIZATION DEBUG INFO');
    debugPrint('=' * 50);
    debugPrint('Current Locale: ${locale.toString()}');
    debugPrint('Language Code: ${locale.languageCode}');
    debugPrint('Country Code: ${locale.countryCode}');
    debugPrint('Is RTL: ${isRTL()}');
    debugPrint('Supported Locales: ${getSupportedLocales()}');
    debugPrint('=' * 50 + '\n');
  }

  static void debugLocalization(BuildContext context) {
  debugPrint('\n' + '=' * 50);
  debugPrint('🔍 LOCALIZATION DEBUG');
  debugPrint('=' * 50);
  debugPrint('Current Locale: ${context.locale}');
  debugPrint('Locale String: ${context.locale.toString()}');
  debugPrint('Language Code: ${context.locale.languageCode}');
  debugPrint('Country Code: ${context.locale.countryCode}');
  
  // Test beberapa key
  final testKeys = [
    'common.unknown',
    'venue.aboutVenue', 
    'booking.details'
  ];
  
  for (String key in testKeys) {
    final result = easy.StringTranslateExtension(key).tr();
    debugPrint('Key: $key -> Result: $result');
  }
  debugPrint('=' * 50 + '\n');
}

  /// Safe translation with fallback
  static String trSafe(String key, {String fallback = 'Missing Translation'}) {
    try {
      final result = tr(key);
      if (result == key) {
        // Translation not found, return fallback
        return fallback;
      }
      return result;
    } catch (e) {
      debugPrint('❌ Translation error for key: $key - $e');
      return fallback;
    }
  }

  /// Get booking status translation
  static String getBookingStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return tr(LocaleKeys.booking_completed);
      case 'pending':
        return tr(LocaleKeys.booking_paymentPending);
      case 'payment_pending':
        return tr(LocaleKeys.booking_paymentPending);
      case 'completed':
        return tr(LocaleKeys.booking_completed);
      case 'cancelled':
        return tr(LocaleKeys.booking_cancelBooking);
      case 'expired':
        return tr(LocaleKeys.common_unknown);
      default:
        return tr(LocaleKeys.common_unknown);
    }
  }

  /// Get venue status translation
  static String getVenueStatusText(bool isOpen) {
    return isOpen ? tr(LocaleKeys.venue_open) : tr(LocaleKeys.venue_closed);
  }

  /// Format venue price display
  static String formatVenuePrice(double? price) {
    if (price == null) return tr(LocaleKeys.common_unknown);
    return '${formatCurrency(price)} ${tr(LocaleKeys.venue_perHour)}';
  }

  /// Format venue capacity display
  static String formatCapacity(int? capacity) {
    if (capacity == null) return tr(LocaleKeys.common_unknown);
    return '$capacity ${tr(LocaleKeys.booking_capacity)}';
  }

  /// Format review count display
  static String formatReviewCount(int count) {
    if (count == 0) return tr(LocaleKeys.venue_noReviewsYet);
    return trPlural(LocaleKeys.venue_reviews, count);
  }

  /// Format distance display
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()}m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceInKm.round()}km';
    }
  }

  /// Format duration display
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return trArgs(LocaleKeys.booking_duration, {
        'hours': hours.toString(),
        'minutes': minutes.toString(),
      });
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Get greeting based on time of day
  static String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    final languageCode = getCurrentLanguageCode();

    if (languageCode == 'id') {
      if (hour < 12) return 'Selamat Pagi';
      if (hour < 15) return 'Selamat Siang';
      if (hour < 18) return 'Selamat Sore';
      return 'Selamat Malam';
    } else {
      if (hour < 12) return 'Good Morning';
      if (hour < 18) return 'Good Afternoon';
      return 'Good Evening';
    }
  }

  /// Validate and format phone number
  static String formatPhoneNumber(String? phone, {String? countryCode}) {
    if (phone == null || phone.isEmpty) return tr(LocaleKeys.common_unknown);

    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (countryCode == 'id' || getCurrentLanguageCode() == 'id') {
      // Indonesian format
      if (digits.startsWith('62')) {
        return '+${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5, 9)} ${digits.substring(9)}';
      } else if (digits.startsWith('0')) {
        return '+62 ${digits.substring(1, 4)} ${digits.substring(4, 8)} ${digits.substring(8)}';
      }
    }

    return phone; // Return original if no formatting applied
  }

  /// Check if text needs translation
  static bool needsTranslation(String text) {
    // Check if text contains translation key pattern
    return text.contains('.') && !text.contains(' ');
  }

  /// Auto-translate text if it's a key
  static String autoTranslate(String text) {
    if (needsTranslation(text)) {
      return trSafe(text, fallback: text);
    }
    return text;
  }

  /// Safely execute operations that require context
  static T? safeContextOperation<T>(T Function(BuildContext context) operation) {
    try {
      if (Get.context != null && Get.context!.mounted) {
        return operation(Get.context!);
      }
    } catch (e) {
      debugPrint('❌ Error in safe context operation: $e');
    }
    return null;
  }

  /// Show snackbar safely with context checks
  static void showSnackbarSafe({
    required String message,
    required SnackbarType type,
  }) {
    safeContextOperation((context) {
      CustomSnackbar.show(
        context: context,
        message: message,
        type: type,
      );
    });
  }
}

extension EasyLocalizationExtension on String {
  /// Translate this string using easy_localization (NOT GetX)
  String get easyTr => easy.StringTranslateExtension(this).tr();

  /// Translate with arguments
  String easyTrArgs(Map<String, String> args) =>
      easy.StringTranslateExtension(this).tr(namedArgs: args);

  /// Translate with plural
  String easyTrPlural(int count) => easy.StringTranslateExtension(this).plural(count);

  /// Safe translation with fallback
  String easyTrSafe({String? fallback}) {
    try {
      final result = easy.StringTranslateExtension(this).tr();
      // If translation not found, easy_localization returns the key itself
      if (result == this) {
        return fallback ?? this;
      }
      return result;
    } catch (e) {
      debugPrint('❌ Translation error for key: $this - $e');
      return fallback ?? this;
    }
  }
}

/// Extension for easy context access in widgets
extension LocalizationContextExtension on BuildContext {
  /// Quick access to translation
  String tr(String key) => LocalizationHelper.tr(key);

  /// Quick access to translation with args
  String trArgs(String key, Map<String, String> args) =>
      LocalizationHelper.trArgs(key, args);

  /// Quick access to plural translation
  String trPlural(String key, int count) =>
      LocalizationHelper.trPlural(key, count);

  /// Get current language code
  String get languageCode => LocalizationHelper.getCurrentLanguageCode();

  /// Check if current language is RTL
  bool get isRTL => LocalizationHelper.isRTL();

  /// Format currency for current locale
  String formatCurrency(double amount) =>
      LocalizationHelper.formatCurrency(amount);

  /// Format date for current locale
  String formatDate(DateTime date) => LocalizationHelper.formatDate(date);

  /// Format time for current locale
  String formatTime(DateTime time) => LocalizationHelper.formatTime(time);
}
