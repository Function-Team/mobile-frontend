import 'package:function_mobile/core/services/secure_storage_service.dart';
import 'package:function_mobile/core/services/api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  static final SecureStorageService _secureStorage = SecureStorageService();

  Future<void> saveToken(String token) async {
    await _secureStorage.saveToken(token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.getToken();
  }

  Future<void> removeToken() async {
    await _secureStorage.deleteToken();
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('Attempting login with username: $username');

      final response = await _apiService.postRequest(
        '/login',
        {
          'username': username,
          'password': password,
        },
      );

      print('Login response body: $response');

      // Pastikan response sudah berupa Map<String, dynamic>
      if (response != null && response['access_token'] != null) {
        await saveToken(response['access_token']);
        return Map<String, dynamic>.from(response);
      } else {
        String errorMessage = 'Login gagal. Data tidak valid dari server.';
        if (response != null && response['detail'] != null) {
          if (response['detail'] is List) {
            final details = response['detail'] as List;
            if (details.isNotEmpty) {
              errorMessage = details.map((e) => e['msg']).join(", ");
            }
          } else {
            errorMessage = response['detail'];
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error during login: $e');
      if (e.toString().contains('FormatException')) {
        throw Exception(
            'Server returned an invalid response. Please try again later.');
      } else {
        throw Exception('Error during login: $e');
      }
    }
  }

  Future<Map<String, dynamic>> signup(
      String username, String password, String email) async {
    try {
      final response = await _apiService.postRequest(
        '/signup',
        {
          'username': username,
          'password': password,
          'email': email,
        },
      );

      // Pastikan response sudah berupa Map<String, dynamic>
      if (response != null &&
          (response['access_token'] != null || response['user'] != null)) {
        if (response['access_token'] != null) {
          await saveToken(response['access_token']);
        }
        return Map<String, dynamic>.from(response);
      } else {
        String errorMessage = 'Signup gagal. Data tidak valid dari server.';
        if (response != null && response['detail'] != null) {
          errorMessage = response['detail'];
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error during signup: $e');
      if (e.toString().contains('FormatException')) {
        throw Exception(
            'Server returned an invalid response. Please try again later.');
      } else {
        throw Exception('Error during signup: $e');
      }
    }
  }

  // Rest of the methods remain the same
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> fetchProtectedData(String endPoint) async {
    try {
      final response = await _apiService.getRequest(endPoint);
      return response;
    } on Exception catch (e) {
      // Jika unauthorized, hapus token
      if (e.toString().contains('401')) {
        await removeToken();
        throw Exception('Unauthorized, please login again');
      }
      throw Exception('Failed to fetch data: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await removeToken();
  }
}
