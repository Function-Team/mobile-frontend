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
    try {
      await _secureStorage.saveToken(token);
      print("Token saved successfully");
      print("Token preview: ${token.substring(0, 10)}...");
    } catch (e) {
      print("Error saving token: $e");
      throw Exception("Failed to save authentication token");
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _secureStorage.getToken();
      if (token != null) {
        print("Token retrieved from storage: ${token.substring(0, 10)}...");
      } else {
        print("No token found in storage");
      }
      return token;
    } catch (e) {
      print("Error getting token: $e");
      return null;
    }
  }

  Future<void> removeToken() async {
    try {
      await _secureStorage.deleteToken();
      print("Token removed from storage");
    } catch (e) {
      print("Error removing token: $e");
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print("Attempting login with email: $email");

      final response = await _apiService.postFormRequest(
        '/login',
        {
          'username': email, // FastAPI OAuth2 expects 'username' field
          'password': password,
        },
      );

      print("Login response received: ${response != null ? 'success' : 'null'}");

      if (response != null && response['access_token'] != null) {
        final token = response['access_token'];
        print("Access token received: ${token.substring(0, 10)}...");
        
        // Save token to secure storage
        await saveToken(token);
        
        // Verify token was saved
        final savedToken = await getToken();
        if (savedToken == null) {
          throw Exception("Failed to save authentication token");
        }
        
        return Map<String, dynamic>.from(response);
      } else {
        String errorMessage = 'Login failed. Invalid response from server.';
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
      print("Error during login: $e");
      if (e.toString().contains('FormatException')) {
        throw Exception('Server returned an invalid response. Please try again later.');
      } else {
        throw Exception('Error during login: $e');
      }
    }
  }

  Future<Map<String, dynamic>> signup(String username, String password, String email) async {
    try {
      final response = await _apiService.postRequest(
        '/signup',
        {
          'username': username,
          'password': password,
          'email': email,
        },
      );

      if (response != null && response['access_token'] != null) {
        final token = response['access_token'];
        await saveToken(token);
        return Map<String, dynamic>.from(response);
      } else {
        String errorMessage = 'Signup failed. Invalid response from server.';
        if (response != null && response['detail'] != null) {
          errorMessage = response['detail'];
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("Error during signup: $e");
      if (e.toString().contains('FormatException')) {
        throw Exception('Server returned an invalid response. Please try again later.');
      } else {
        throw Exception('Error during signup: $e');
      }
    }
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
    };
  }

  Future<void> saveUserData(User user) async {
    try {
      await _secureStorage.saveUserData(user);
      print("User data saved successfully");
    } catch (e) {
      print("Error saving user data: $e");
    }
  }

  Future<User?> getUserData() async {
    try {
      return await _secureStorage.getUserData();
    } catch (e) {
      print("Error getting user data: $e");
      return null;
    }
  }

  Future<dynamic> fetchProtectedData(String endPoint) async {
    try {
      // Remove /api/ prefix if present since it's already in baseUrl
      if (endPoint.startsWith('/api/')) {
        endPoint = endPoint.substring(4);
      }
      
      print("Fetching protected data from: $endPoint");
      
      // Check if we have a token before making request
      final token = await getToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login again.');
      }
      
      final response = await _apiService.getRequest(endPoint);
      print("Protected data fetched successfully");
      return response;
    } catch (e) {
      print("Error fetching protected data: $e");
      if (e.toString().contains('401') || e.toString().contains('Authentication required')) {
        await removeToken();
        throw Exception('Authentication expired. Please login again.');
      }
      throw Exception('Failed to fetch data: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final hasToken = token != null && token.isNotEmpty;
      print("Is logged in check: $hasToken");
      return hasToken;
    } catch (e) {
      print("Error checking login status: $e");
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await removeToken();
      await _secureStorage.deleteToken(); // Make sure token is deleted
      print("Logout completed");
    } catch (e) {
      print("Error during logout: $e");
    }
  }

  // Debug method to check authentication state
  Future<Map<String, dynamic>> debugAuthState() async {
    try {
      final token = await getToken();
      final userData = await getUserData();
      final isLoggedIn = await this.isLoggedIn();
      
      return {
        'has_token': token != null,
        'token_length': token?.length ?? 0,
        'token_preview': token != null ? '${token.substring(0, 10)}...' : 'none',
        'has_user_data': userData != null,
        'user_id': userData?.id,
        'username': userData?.username,
        'is_logged_in': isLoggedIn,
        'storage_key': AppConstants.tokenKey,
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'has_token': false,
        'is_logged_in': false,
      };
    }
  }

  // Method to validate token with server
  Future<bool> validateToken() async {
    try {
      final response = await fetchProtectedData('/user/me');
      return response != null;
    } catch (e) {
      print("Token validation failed: $e");
      return false;
    }
  }
}