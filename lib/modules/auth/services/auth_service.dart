import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/core/services/secure_storage_service.dart';
import 'package:function_mobile/modules/auth/models/auth_model.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class AuthService extends GetxService {
  final ApiService _apiService = ApiService();
  final SecureStorageService _secureStorage = SecureStorageService();
  Function? onSessionExpired;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.postFormRequest(
        '/login',
        {
          'username': email,
          'password': password,
        },
      );

      if (response != null && response['access_token'] != null) {
        // Save tokens
        if (response['refresh_token'] != null) {
          await saveTokens(
            accessToken: response['access_token'],
            refreshToken: response['refresh_token'],
          );
        } else {
          await saveToken(response['access_token']);
        }

        // Create user from token
        try {
          await createUserFromToken();
        } catch (e) {
          print('AuthService: Error creating user from token: $e');
        }

        return Map<String, dynamic>.from(response);
      } else {
        throw Exception(
            'Invalid credentials. Please check your email and password.');
      }
    } on dio.DioException catch (e) {
      print(
          'AuthService: DioException during login: ${e.response?.statusCode} - ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        throw Exception('Invalid email or password. Please try again.');
      } else if (e.response?.statusCode == 422) {
        throw Exception('Please check your email and password format.');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Too many login attempts. Please try again later.');
      } else if (e.response?.statusCode == null) {
        throw Exception('Please check your internet connection.');
      } else {
        throw Exception('Login failed. Please try again.');
      }
    } catch (e) {
      print('AuthService: General error during login: $e');

      if (e.toString().startsWith('Exception:')) {
        rethrow;
      }

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
      print(
          'AuthService: Attempting signup with username: $username, email: $email');

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
        // Save tokens if provided
        if (response['access_token'] != null &&
            response['refresh_token'] != null) {
          await saveTokens(
            accessToken: response['access_token'],
            refreshToken: response['refresh_token'],
          );

          try {
            await createUserFromToken();
            print('AuthService: User created from token successfully');
          } catch (e) {
            print('AuthService: Error creating user from token: $e');
          }
        } else if (response['access_token'] != null) {
          await saveToken(response['access_token']);
        }

        return Map<String, dynamic>.from(response);
      } else {
        throw Exception('Account creation failed. Please try again.');
      }
    } on dio.DioException catch (e) {
      print(
          'AuthService: DioException during signup: ${e.response?.statusCode} - ${e.response?.data}');

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
        throw Exception('Please check your input format and try again.');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Too many requests. Please wait before trying again.');
      } else if (e.response?.statusCode == null) {
        throw Exception('Please check your internet connection.');
      } else {
        throw Exception('Account creation failed. Please try again.');
      }
    } catch (e) {
      print('AuthService: General error during signup: $e');

      if (e.toString().startsWith('Exception:')) {
        rethrow;
      }

      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> logout() async {
    try {
      print('AuthService: Starting logout process...');

      // Clear token from secure storage
      await removeAllTokens();
      print('AuthService: Token removed from storage');

      try {
        print('AuthService: Server logout completed');
      } catch (e) {
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

  // ===== TOKEN MANAGEMENT =====
  Future<void> saveToken(String token) async {
    await _secureStorage.saveToken(token);
    print('AuthService: Token saved successfully');
  }

  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {
    await _secureStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    print('AuthService: Tokens saved successfully');
  }

  Future<String?> getToken() async {
    return await _secureStorage.getToken();
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.getRefreshToken();
  }

  Future<void> removeToken() async {
    await _secureStorage.removeToken();
  }

  Future<void> removeAllTokens() async {
    await _secureStorage.removeAllTokens();
  }

  Future<Map<String, dynamic>> getTokenInfo() async {
    try {
      final accessToken = await getToken();
      final refreshToken = await getRefreshToken();

      if (accessToken == null) {
        return {
          'hasTokens': false,
          'requiresReauth': true,
          'accessExpired': true,
          'refreshExpired': true,
        };
      }

      final accessExpired = JwtDecoder.isExpired(accessToken);
      bool refreshExpired = true;

      if (refreshToken != null) {
        refreshExpired = JwtDecoder.isExpired(refreshToken);
      }

      return {
        'hasTokens': true,
        'requiresReauth': accessExpired && refreshExpired,
        'accessExpired': accessExpired,
        'refreshExpired': refreshExpired,
      };
    } catch (e) {
      print('AuthService: Error getting token info: $e');
      return {
        'hasTokens': false,
        'requiresReauth': true,
        'accessExpired': true,
        'refreshExpired': true,
      };
    }
  }

  // ===== USER DATA MANAGEMENT =====
  Future<void> saveUserData(User user) async {
    await _secureStorage.saveUserData(user);
    print('AuthService: User data saved successfully');
  }

  Future<User?> getUserData() async {
    return await _secureStorage.getUserData();
  }

  Future<dynamic> fetchUserInfo() async {
    try {
      print('AuthService: Fetching user info...');

      // Get token to call API
      final token = await getToken();
      if (token == null) {
        print('AuthService: No token available');
        throw Exception('No authentication token available');
      }

      // Call API to get REAL user data with username
      try {
        final response = await _apiService.getRequest('/user/me');
        print('AuthService: API response received: $response');

        if (response != null) {
          // Create user from API response (has real username)
          final apiUser = User(
            id: response['id'] ?? 0,
            username: response['username'] ?? '',
            email: response['email'] ?? '',
            isVerified: response['is_verified'] ?? false,
            createdAt: response['created_at'] != null
                ? DateTime.parse(response['created_at'])
                : DateTime.now(),
          );

          // Save the complete user data
          await saveUserData(apiUser);
          print('AuthService: User data from API saved: ${apiUser.username}');

          return response;
        }
      } catch (e) {
        print('AuthService: API call failed: $e');
        // Continue to fallback logic below
      }

      // FALLBACK - Try to get user from stored data
      final userData = await getUserData();
      if (userData?.id != null) {
        print('AuthService: Using stored user data: ${userData!.username}');
        return userData.toJson();
      }

      // Create temporary user from token
      print('AuthService: Creating temporary user from token...');
      final userFromToken = await createUserFromToken();
      if (userFromToken != null) {
        return userFromToken.toJson();
      }

      throw Exception('No user data available');
    } catch (e) {
      print('AuthService: Error fetching user info: $e');

      if (e.toString().contains('401')) {
        _handleSessionExpired();
      }

      throw Exception('Failed to fetch user information: ${e.toString()}');
    }
  }

  Future<User?> createUserFromToken() async {
    try {
      final tokenInfo = await getUserInfoFromToken();
      if (tokenInfo == null) return null;

      // Extract data from token
      final email = tokenInfo['sub'] as String?;
      final userId = tokenInfo['id'] as int?;

      if (email == null || userId == null) {
        print('AuthService: Missing required user data in token');
        return null;
      }

      // Try API call first to get REAL username
      try {
        final response = await _apiService.getRequest('/user/me');
        if (response != null && response['username'] != null) {
          final newUser = User(
            id: userId,
            email: email,
            username: response['username'],
            isVerified: response['is_verified'] ?? false,
            createdAt: response['created_at'] != null
                ? DateTime.parse(response['created_at'])
                : DateTime.now(),
          );

          await saveUserData(newUser);
          print(
              'AuthService: User created from API with real username: ${newUser.username}');
          return newUser;
        }
      } catch (e) {
        print('AuthService: API call failed in createUserFromToken: $e');
      }

      // Create temporary user with email-based username
      final tempUser = User(
        id: userId,
        email: email,
        username: email.split('@')[0],
        isVerified: tokenInfo['is_verified'] ?? false,
        createdAt: DateTime.now(),
      );

      await saveUserData(tempUser);
      print(
          'AuthService: Created temporary user from token: ${tempUser.username}');

      return tempUser;
    } catch (e) {
      print('AuthService: Error creating user from token: $e');
      return null;
    }
  }

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

  Future<void> clearAllUserData() async {
    try {
      await removeAllTokens();
      await _secureStorage.clearAllUserData();
      print('AuthService: All user data cleared');
    } catch (e) {
      print('AuthService: Error clearing user data: $e');
      throw Exception('Failed to clear user data: ${e.toString()}');
    }
  }

  // ===== EMAIL VERIFICATION =====
  Future<void> resendVerificationEmail(String email) async {
    try {
      print('AuthService: Resending verification email to: $email');

      final response = await _apiService.postRequest(
        '/resend-verification',
        {'email': email},
      );

      if (response != null) {
        print('AuthService: Verification email resent successfully');
      } else {
        throw Exception('Failed to resend verification email');
      }
    } on dio.DioException catch (e) {
      print(
          'AuthService: DioException during resend verification: ${e.response?.statusCode} - ${e.response?.data}');

      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null && errorData['detail'] != null) {
          throw Exception(errorData['detail'].toString());
        }
        throw Exception('Invalid email address');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Email address not found. Please sign up first.');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Too many requests. Please wait before trying again.');
      }

      throw Exception(
          'Unable to resend verification email. Please try again later or contact support.');
    } catch (e) {
      print('AuthService: General error during resend verification: $e');

      if (e.toString().startsWith('Exception:')) {
        rethrow;
      }

      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<bool> checkEmailVerificationStatus(String email) async {
    try {
      print('AuthService: Checking verification status for: $email');

      final tokenInfo = await getUserInfoFromToken();
      if (tokenInfo == null) return false;

      final userEmail = tokenInfo['sub'] as String?;
      // final userId = tokenInfo['id'] as int?;

      // Use the passed email parameter or token email
      final emailToCheck = email.isNotEmpty ? email : userEmail;

      if (emailToCheck == null) {
        print('AuthService: No email available for verification check');
        return false;
      }

      final response = await _apiService.postRequest(
        '/check-verification',
        {'email': emailToCheck},
      );

      if (response != null && response['is_verified'] != null) {
        return response['is_verified'] as bool;
      }

      return false;
    } on dio.DioException catch (e) {
      print(
          'AuthService: DioException during verification check: ${e.response?.statusCode} - ${e.response?.data}');

      if (e.response?.statusCode == 404) {
        return false;
      }

      return false;
    } catch (e) {
      print('AuthService: General error during verification status check: $e');
      return false;
    }
  }

  // ===== UTILITY METHODS =====
  Future<bool> isLoggedIn() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final token = await getToken();
    final user = await getUserData();

    if (token == null || user == null) return false;

    // Validate token expiration
    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      print('AuthService: Token validation error: $e');
      return false;
    }
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<int?> getUserIdFromToken() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final userData = await getUserData();
      return userData?.id;
    } catch (e) {
      print('AuthService: Error extracting user ID from token: $e');
      return null;
    }
  }

  // ===== PRIVATE HELPER METHODS =====
  void _handleSessionExpired() {
    if (onSessionExpired != null) {
      try {
        onSessionExpired!();
      } catch (e) {
        print('AuthService: Error calling session expired callback: $e');
      }
    } else {
      // Fallback: Direct navigation
      try {
        Get.offAllNamed('/login');
        Get.snackbar(
          'Session Expired',
          'Please login again to continue',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      } catch (e) {
        print('AuthService: Error handling session expiry: $e');
      }
    }
  }

  // ===== PASSWORD RESET =====
  Future<void> requestPasswordReset(String email) async {
    try {
      print('AuthService: Requesting password reset for: $email');

      final response = await _apiService.postRequest(
        '/forgot-password',
        {'email': email},
      );

      print('AuthService: Password reset email sent');
      return response;
    } catch (e) {
      print('AuthService: Error requesting password reset: $e');
      throw Exception(
          'Failed to request password reset. Please try again later.');
    }
  }

  Future<bool> verifyResetToken(String token) async {
    try {
      print('AuthService: Verifying reset token');

      final response = await _apiService.getRequest(
        '/reset-password/$token',
      );

      return response['valid'] ?? false;
    } catch (e) {
      print('AuthService: Error verifying reset token: $e');
      return false;
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      print('AuthService: Resetting password');

      final response = await _apiService.postRequest(
        '/reset-password',
        {
          'token': token,
          'new_password': newPassword,
        },
      );

      print('AuthService: Password reset successful');
      return response;
    } catch (e) {
      print('AuthService: Error resetting password: $e');
      throw Exception('Failed to reset password. Please try again later.');
    }
  }
}
