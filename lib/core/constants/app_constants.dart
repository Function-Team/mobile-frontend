import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API URLs
  static String baseUrlProd = dotenv.env['API_URL']!;
  // static String baseUrlLocal = dotenv.env['API_URL_LOCAL']!; android studio
  static String baseUrlLocal = "http://192.168.18.4:8000/api"; //ip adress, to get command prompt [ipconfig] -> search IPv4 Address.

  // Pilih baseUrl yang ingin digunakan
  static String baseUrl = baseUrlLocal;
  // Untuk development, bisa ganti ke:
  // static const String baseUrl = baseUrlLocal;

  // Asset Paths
  static const String imagePath = 'assets/images/';

  // Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}
