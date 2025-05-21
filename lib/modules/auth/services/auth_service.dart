import 'dart:convert';

import 'package:function_mobile/core/constants/app_constants.dart';
import 'package:function_mobile/core/services/secure_storage_service.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/modules/auth/models/auth_model.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  late final ApiService _apiService;
  static final SecureStorageService _secureStorage = SecureStorageService();

  AuthService() {
    _apiService = Get.find<ApiService>();
  }

  Future<void> saveToken(String token) async {
    await _secureStorage.saveToken(token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.getToken();
  }

  Future<void> removeToken() async {
    await _secureStorage.deleteToken();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Attempting login with email: $email');

      // Menggunakan postFormRequest untuk form data
      final response = await _apiService.postFormRequest(
        '/login',
        {
          'username': email, // Kirim email sebagai username
          'password': password,
        },
      );

      print('Login response body: $response');

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
      final response = await _apiService.postFormRequest(
        '/signup',
        {
          'username': username,
          'password': password,
          'email': email,
        },
      );

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

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

 Future<void> saveUserData(User user) async {
  await _secureStorage.saveUserData(user);
}

Future<User?> getUserData() async {
  return await _secureStorage.getUserData();
}
  Future<dynamic> fetchProtectedData(String endPoint) async {
  try {
    if (endPoint.startsWith('/api/')) {
      endPoint = endPoint.substring(4);
    }
    // Interceptor sudah handle token, jadi tidak perlu manual
    final response = await _apiService.getRequest(endPoint);
    return response;
  } catch (e) {
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