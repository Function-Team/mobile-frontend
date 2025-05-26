import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // Your computer's IP address - MUST BE CORRECT
  static const String _computerIP = '192.168.18.4';

  // Server ports
  static const String _laravelPort = '8000';
  static const String _fastApiPort = '8001';

  // CHANGE THIS LINE to select which backend to use
  static const bool _useDirectFastApi = true;

  // ACTIVE BASE URL - This is the one used by ApiService
  // For emulator, we use 10.0.2.2 which points to the host machine's localhost
  static String get baseUrl => _useDirectFastApi
      ? 'http://10.0.2.2:$_fastApiPort/api' // Direct to FastAPI
      : 'http://10.0.2.2:$_laravelPort/api'; // Via Laravel

  // For reference - real device URLs
  static String get realDeviceUrl => _useDirectFastApi
      ? 'http://$_computerIP:$_fastApiPort/api' // Direct to FastAPI
      : 'http://$_computerIP:$_laravelPort/api'; // Via Laravel

  // Asset Paths
  static const String imagePath = 'assets/images/';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Debug method to show configuration
  static void printConfig() {
    print("\n==== API CONFIGURATION ====");
    print("Mode: ${_useDirectFastApi ? 'Direct FastAPI' : 'Via Laravel'}");
    print("Base URL: $baseUrl");
    print("Using emulator configuration (10.0.2.2)");
    print("FastAPI: http://10.0.2.2:$_fastApiPort");
    print("Laravel: http://10.0.2.2:$_laravelPort");
    print("==========================\n");
  }
}
