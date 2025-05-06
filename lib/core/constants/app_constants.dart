class AppConstants {
  // API URLs
  static const String baseUrlProd = 'http://backend.thefunction.id/api';
  static const String baseUrlLocal = 'http://10.0.2.2:8000/api';

  // Pilih baseUrl yang ingin digunakan
  static const String baseUrl = baseUrlLocal;
  // Untuk development, bisa ganti ke:
  // static const String baseUrl = baseUrlLocal;

  // Asset Paths
  static const String imagePath = 'assets/images/';

  // Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}
