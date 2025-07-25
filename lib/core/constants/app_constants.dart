import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API URLs
  static String get baseUrl => dotenv.env['API_URL'] ?? '';
  static String get baseUrlLocal => dotenv.env['API_URL_LOCAL'] ?? '';
  
  // Secure Storage Keys
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  
  // Midtrans Payment Gateway
  static String get midtransClientKey => dotenv.env['MIDTRANS_CLIENT_KEY'] ?? '';
  static String get midtransMerchantBaseUrl => dotenv.env['MIDTRANS_MERCHANT_BASE_URL'] ?? '';
  static String get midtransSnapToken => dotenv.env['MIDTRANS_SNAP_TOKEN'] ?? '';
  
  // App Settings
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);

  static const Duration tokenRefreshThreshold =
      Duration(minutes: 5); // Refresh when token expires in 5 minutes
  static const Duration refreshTokenRetryDelay =
      Duration(seconds: 2); // Delay between refresh attempts
  static const int maxRefreshRetries = 3;
}