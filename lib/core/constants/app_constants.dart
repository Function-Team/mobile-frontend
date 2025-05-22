import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API URLs with better fallbacks and debugging
  static String get baseUrlProd {
    final url = dotenv.env['API_URL'];
    if (url == null || url.isEmpty) {
      print("Warning: API_URL not found in .env file");
      return 'https://your-production-api.com/api';
    }
    return url;
  }
  
  static String get baseUrlLocal {
    final url = dotenv.env['API_URL_LOCAL'];
    if (url == null || url.isEmpty) {
      print("Warning: API_URL_LOCAL not found in .env file, using default");
      // Default for Android emulator
      return 'http://10.0.2.2:8000/api';
    }
    return url;
  }

  // Enhanced base URL selection with debugging
  static String get baseUrl {
    // Change this based on your development needs
    const bool useLocal = true; // Set to false for production
    
    final selectedUrl = useLocal ? baseUrlLocal : baseUrlProd;
    print("Using API base URL: $selectedUrl");
    print("Environment: ${useLocal ? 'LOCAL' : 'PRODUCTION'}");
    
    return selectedUrl;
  }

  // Alternative URLs for different environments
  static String get baseUrlEmulator => 'http://10.0.2.2:8000/api';
  static String get baseUrlLocalhost => 'http://localhost:8000/api';
  
  // Method to get URL based on device type
  static String getApiUrlForDevice() {
    // You can implement device detection logic here
    // For now, return emulator URL which works for most Android development
    return baseUrlEmulator;
  }

  // Asset Paths
  static const String imagePath = 'assets/images/';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Debug method to test different URLs
  static void printAvailableUrls() {
    print("Available API URLs:");
    print("Local (from .env): $baseUrlLocal");
    print("Production (from .env): $baseUrlProd");
    print("Emulator default: $baseUrlEmulator");
    print("Localhost: $baseUrlLocalhost");
    print("Currently using: $baseUrl");
  }
  
  // Method to validate URL format
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
  
  // Get troubleshooting info
  static Map<String, dynamic> getTroubleshootingInfo() {
    return {
      'current_base_url': baseUrl,
      'is_valid_url': isValidUrl(baseUrl),
      'suggested_urls': {
        'android_emulator': baseUrlEmulator,
        'localhost': baseUrlLocalhost,
        'custom_ip': 'http://YOUR_COMPUTER_IP:8000/api',
      },
      'environment_variables': {
        'API_URL': dotenv.env['API_URL'],
        'API_URL_LOCAL': dotenv.env['API_URL_LOCAL'],
      },
      'troubleshooting_steps': [
        '1. Make sure your FastAPI server is running',
        '2. Check if you can access the API in your browser',
        '3. For Android emulator, use 10.0.2.2 instead of localhost',
        '4. For physical device, use your computer\'s IP address',
        '5. Check your firewall settings',
        '6. Verify the port number (default: 8000)',
      ],
    };
  }
}