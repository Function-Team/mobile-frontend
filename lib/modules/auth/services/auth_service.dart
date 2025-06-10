import 'package:function_mobile/core/services/secure_storage_service.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/modules/auth/models/auth_model.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:jwt_decoder/jwt_decoder.dart';

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

  // Extract user ID from JWT token
  Future<int?> getUserIdFromToken() async {
    try {
      final token = await getToken();
      if (token == null) return null;
      
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      
      // The backend uses 'sub' field for email, we need to get user ID differently
      // For now, we'll store it when we login successfully
      final userData = await getUserData();
      return userData?.id;
    } catch (e) {
      print('Error extracting user ID from token: $e');
      return null;
    }
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
        throw Exception(
            'Invalid credentials. Please check your email and password.');
      }
    } on dio.DioException catch (e) {
      print(
          'DioException during login: ${e.response?.statusCode} - ${e.response?.data}');

      // Handle specific HTTP status codes
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid email or password. Please try again.');
      } else if (e.response?.statusCode == 422) {
        // Handle validation errors
        final errorData = e.response?.data;
        if (errorData != null && errorData['detail'] != null) {
          if (errorData['detail'] is List) {
            final details = errorData['detail'] as List;
            final errorMessages = details.map((error) {
              if (error is Map && error['msg'] != null) {
                return error['msg'].toString();
              }
              return error.toString();
            }).join(', ');
            throw Exception(errorMessages);
          } else {
            throw Exception(errorData['detail'].toString());
          }
        }
        throw Exception('Please check your input and try again.');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null && errorData['detail'] != null) {
          throw Exception(errorData['detail'].toString());
        }
        throw Exception('Bad request. Please check your credentials.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        throw Exception(
            'Connection timeout. Please check your internet connection.');
      } else if (e.type == dio.DioExceptionType.connectionError) {
        throw Exception(
            'Unable to connect to server. Please check your internet connection.');
      } else {
        throw Exception('Login failed. Please try again.');
      }
    } catch (e) {
      print('General error during login: $e');

      // If it's already our custom exception, re-throw it
      if (e.toString().startsWith('Exception:')) {
        rethrow;
      }

      // Handle other types of errors
      if (e.toString().contains('FormatException')) {
        throw Exception(
            'Server returned invalid data. Please try again later.');
      } else {
        throw Exception('An unexpected error occurred. Please try again.');
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

      if (response != null &&
          (response['access_token'] != null || response['user'] != null)) {
        if (response['access_token'] != null) {
          await saveToken(response['access_token']);
        }
        return Map<String, dynamic>.from(response);
      } else {
        throw Exception('Account creation failed. Please try again.');
      }
    } on dio.DioException catch (e) {
      print(
          'DioException during signup: ${e.response?.statusCode} - ${e.response?.data}');

      // Handle specific HTTP status codes
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null && errorData['detail'] != null) {
          final detail = errorData['detail'].toString();
          if (detail.toLowerCase().contains('username already registered')) {
            throw Exception(
                'This username is already taken. Please choose another.');
          } else if (detail
              .toLowerCase()
              .contains('email already registered')) {
            throw Exception(
                'This email is already registered. Please use a different email.');
          } else {
            throw Exception(detail);
          }
        }
        throw Exception('Invalid registration data. Please check your inputs.');
      } else if (e.response?.statusCode == 422) {
        // Handle validation errors
        final errorData = e.response?.data;
        if (errorData != null && errorData['detail'] != null) {
          if (errorData['detail'] is List) {
            final details = errorData['detail'] as List;
            final errorMessages = details.map((error) {
              if (error is Map && error['msg'] != null) {
                return error['msg'].toString();
              }
              return error.toString();
            }).join(', ');
            throw Exception(errorMessages);
          } else {
            throw Exception(errorData['detail'].toString());
          }
        }
        throw Exception('Please check your input and try again.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        throw Exception(
            'Connection timeout. Please check your internet connection.');
      } else if (e.type == dio.DioExceptionType.connectionError) {
        throw Exception(
            'Unable to connect to server. Please check your internet connection.');
      } else {
        throw Exception('Registration failed. Please try again.');
      }
    } catch (e) {
      print('General error during signup: $e');

      // If it's already our custom exception, re-throw it
      if (e.toString().startsWith('Exception:')) {
        rethrow;
      }

      // Handle other types of errors
      if (e.toString().contains('FormatException')) {
        throw Exception(
            'Server returned invalid data. Please try again later.');
      } else {
        throw Exception('An unexpected error occurred. Please try again.');
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

  // Fix user/me endpoint call with proper user ID
  Future<dynamic> fetchUserInfo() async {
    try {
      // Get user ID from stored user data
      final userData = await getUserData();
      if (userData?.id == null) {
        print('AuthService: No user ID available for /user/me call');
        return null;
      }

      print('AuthService: Calling /user/me with ID: ${userData!.id}');
      
      // Call the corrected endpoint with user ID as query parameter
      final response = await _apiService.getRequest('/user/me?id=${userData.id}');
      return response;
      
    } catch (e) {
      print('AuthService: Error fetching user info: $e');
      return null;
    }
  }

  Future<dynamic> fetchProtectedData(String endPoint) async {
    try {
      if (endPoint.startsWith('/api/')) {
        endPoint = endPoint.substring(4);
      }
      
      // Handle /user/me endpoint specially
      if (endPoint == '/user/me' || endPoint == 'user/me') {
        return await fetchUserInfo();
      }
      
      // Interceptor sudah handle token, jadi tidak perlu manual
      final response = await _apiService.getRequest(endPoint);
      return response;
      
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await removeToken();
        throw Exception('Your session has expired. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception(
            'Access denied. You don\'t have permission to access this resource.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Resource not found.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Failed to fetch data. Please try again.');
      }
    } catch (e) {
      if (e.toString().startsWith('Exception:')) {
        rethrow;
      }
      throw Exception('An unexpected error occurred while fetching data.');
    }
  }

  // login status check
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final user = await getUserData();
    
    if (token == null || user == null) return false;
    
    // Tambah validasi token
    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      print('AuthService: Starting logout process...');
      
      // Clear token from secure storage
      await removeToken();
      print('AuthService: Token removed from storage');
      
      // Optional: Call logout endpoint on server if available
      try {
        // Uncomment if your backend has a logout endpoint
        // await _apiService.postRequest('/logout', {});
        print('AuthService: Server logout completed');
      } catch (e) {
        // Server logout failed, but continue with local logout
        print('AuthService: Server logout failed (continuing anyway): $e');
      }
      
      print('AuthService: Logout completed successfully');
    } catch (e) {
      print('AuthService: Error during logout: $e');
      // Even if there's an error, we should still try to clear local data
      await removeToken();
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  // Clear all user data method
  Future<void> clearAllUserData() async {
    try {
      await removeToken();
      await _secureStorage.clearAllUserData();
      print('AuthService: All user data cleared');
    } catch (e) {
      print('AuthService: Error clearing user data: $e');
      throw Exception('Failed to clear user data: ${e.toString()}');
    }
  }

  // Check if token is valid (not expired)
  Future<bool> isTokenValid() async {
    try {
      final token = await getToken();
      if (token == null) return false;
      
      // Check if token is expired
      if (JwtDecoder.isExpired(token)) {
        print('AuthService: Token is expired');
        return false;
      }
      
      return true;
    } catch (e) {
      print('AuthService: Token validation failed: $e');
      return false;
    }
  }

  // Get user info from token
  Future<Map<String, dynamic>?> getUserInfoFromToken() async {
    try {
      final token = await getToken();
      if (token == null) return null;
      
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      print('AuthService: Decoded token: $decodedToken');
      
      return decodedToken;
    } catch (e) {
      print('AuthService: Error decoding token: $e');
      return null;
    }
  }
}