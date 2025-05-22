import 'package:function_mobile/core/services/secure_storage_service.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/modules/auth/models/auth_model.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;

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

  Future<dynamic> fetchProtectedData(String endPoint) async {
    try {
      if (endPoint.startsWith('/api/')) {
        endPoint = endPoint.substring(4);
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

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await removeToken();
  }
}
