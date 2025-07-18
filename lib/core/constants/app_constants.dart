import 'package:flutter/material.dart';

class AppConstants {
  // ==================== DEVICE CONFIGURATION ====================
  // UNCOMMENT ONLY ONE SECTION BELOW:

  // 🔥 FOR ANDROID STUDIO EMULATOR - UNCOMMENT THIS SECTION
  // static const bool _isEmulator = true;
  // static const String _deviceIP = 'railway.thefunction.id'; // Emulator uses this special IP

  // 🔥 FOR REAL DEVICE - UNCOMMENT THIS SECTION
  static const bool _isEmulator = false;
  // static const String _deviceIP = '192.168.198.61';
  static const String _deviceIP = 'railway.thefunction.id';
  static const bool _isHttps = true;

  // ==================== SERVER CONFIGURATION ====================
  // Server ports on your computer
  static const String _laravelPort = '';
  static const String _fastApiPort = '';

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('id'),
  ];

  // ==================== AUTO-GENERATED URLs ====================
  static String get baseUrl {
    final scheme = _isHttps ? 'https' : 'http';
    return _fastApiPort.isEmpty
        ? '$scheme://$_deviceIP/api'
        : '$scheme://$_deviceIP:$_fastApiPort/api';
  }

  // Alternative URLs for reference
  static String get fastApiUrl => baseUrl;
  static String get laravelUrl => 'http://$_deviceIP:$_laravelPort/api';

  static String get testUrl {
    final scheme = _isHttps ? 'https' : 'http';
    return _fastApiPort.isEmpty
        ? '$scheme://$_deviceIP/docs'
        : '$scheme://$_deviceIP:$_fastApiPort/docs';
  }

  // ==================== STORAGE & ASSETS ====================
  static const String imagePath = 'assets/images/';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String refreshTokenKey = 'refresh_token';
  static const Duration tokenRefreshThreshold =
      Duration(minutes: 5); // Refresh when token expires in 5 minutes
  static const Duration refreshTokenRetryDelay =
      Duration(seconds: 2); // Delay between refresh attempts
  static const int maxRefreshRetries = 3;


 static void printLanguageDebug(Locale currentLocale) {
    print("\n" + "=" * 50);
    print("🌍 LANGUAGE DEBUG INFO");
    print("=" * 50);
    print("Current Locale: ${currentLocale.toString()}");
    print("Language Code: ${currentLocale.languageCode}");
    print("Country Code: ${currentLocale.countryCode}");
    print("=" * 50 + "\n");
  }

}
