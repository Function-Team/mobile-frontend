import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  // Choose which backend to use
  static const bool _useDirectFastApi = true; // true = FastAPI, false = Laravel

  // ==================== AUTO-GENERATED URLs ====================
  static String get baseUrl {
    final port = _useDirectFastApi ? _fastApiPort : _laravelPort;
    final scheme = _isHttps ? 'https' : 'http';
    return port.isEmpty
        ? '$scheme://$_deviceIP/api'
        : '$scheme://$_deviceIP:$port/api';
  }

  // Alternative URLs for reference
  static String get fastApiUrl => baseUrl;
  static String get laravelUrl => 'http://$_deviceIP:$_laravelPort/api';

  static String get testUrl {
    final port = _useDirectFastApi ? _fastApiPort : _laravelPort;
    final scheme = _isHttps ? 'https' : 'http';
    return port.isEmpty
        ? '$scheme://$_deviceIP/docs'
        : '$scheme://$_deviceIP:$port/docs';
  }

  // ==================== STORAGE & ASSETS ====================
  static const String imagePath = 'assets/images/';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // ==================== DEBUG HELPER ====================
  static void printConfig() {
    print("\n" + "=" * 50);
    print("🚀 API CONFIGURATION");
    print("=" * 50);
    print(
        "📱 Device Type: ${_isEmulator ? 'Android Studio Emulator' : 'Real Android Device'}");
    print("🌐 Target IP: $_deviceIP");
    print(
        "🔧 Backend: ${_useDirectFastApi ? 'Direct FastAPI' : 'Via Laravel'}");
    print("🎯 Active URL: $baseUrl");
    print("-" * 50);
    print("📋 Available URLs:");
    print("   FastAPI: $fastApiUrl");
    print("   Laravel: $laravelUrl");
    print("-" * 50);
    print("💡 To switch device:");
    print("   - Comment current device section");
    print("   - Uncomment desired device section");
    print("   - Hot reload or restart app");
    print("=" * 50 + "\n");
  }

  // ==================== NETWORK TESTING ====================


  static void printNetworkTest() {
    print("\n" + "=" * 50);
    print("🧪 NETWORK TESTING");
    print("=" * 50);
    print("1. Test server in browser:");
    print("   ${testUrl}");
    print("");
    print("2. Test API endpoint:");
    print("   $baseUrl/health");
    print("");
    print("3. Check if server is running on computer:");
    if (_isEmulator) {
      print(
          "   http://localhost:${_useDirectFastApi ? _fastApiPort : _laravelPort}/docs");
    } else {
      print(
          "   http://$_deviceIP:${_useDirectFastApi ? _fastApiPort : _laravelPort}/docs");
    }
    print("=" * 50 + "\n");
  }
}
