import 'package:function_mobile/core/constants/app_constants.dart';
import 'package:function_mobile/core/services/secure_storage_service.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:function_mobile/modules/auth/models/auth_model.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService extends GetxService {
  late final ApiService _apiService;
  static final SecureStorageService _secureStorage = SecureStorageService();
  bool _isRefreshingToken = false;
  final List<Function> _pendingRequests = [];
  Function? onSessionExpired;

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

  Future<void> saveRefreshToken(String refreshToken) async {
    await _secureStorage.saveRefreshToken(refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.getRefreshToken();
  }

  Future<void> removeRefreshToken() async {
    await _secureStorage.deleteRefreshToken();
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> removeAllTokens() async {
    await _secureStorage.deleteTokens();
  }

  // Token Validation and refresh logic
  Future<bool> isTokenValid() async {
    try {
      final token = await getToken();
      if (token == null) return false;
      
      // Check if token is expired
      if (JwtDecoder.isExpired(token)) {
        print('AuthService: Access token is expired, attempting refresh...');
        return await _attemptTokenRefresh();
      }
      
      // Check if token is about to expire (within threshold)
      final timeToExpiry = JwtDecoder.getRemainingTime(token);
      if (timeToExpiry.inMinutes <= AppConstants.tokenRefreshThreshold.inMinutes) {
        print('AuthService: Access token expires soon, refreshing proactively...');
        // Attempt refresh but don't block if it fails
        _attemptTokenRefresh().catchError((e) {
          print('AuthService: Proactive refresh failed: $e');
          return false;
        });
      }
      
      return true;
    } catch (e) {
      print('AuthService: Token validation failed: $e');
      return false;
    }
  }

  // try to refresh access token using refresh token
  Future<bool> _attemptTokenRefresh() async {
    if (_isRefreshingToken) {
      // Already refreshing, wait for completion
      return await _waitForRefreshCompletion();
    }

    _isRefreshingToken = true;
    
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        print('AuthService: No refresh token available');
        return false;
      }

      // Check if refresh token is expired
      if (JwtDecoder.isExpired(refreshToken)) {
        print('AuthService: Refresh token is expired, requiring re-authentication');
        await _handleExpiredRefreshToken();
        return false;
      }

      print('AuthService: Attempting to refresh access token...');
      
      // Call refresh endpoint
      final response = await _apiService.getRequest('/refresh?refresh_token=$refreshToken');
      
      if (response != null && 
          response['access_token'] != null && 
          response['refresh_token'] != null) {
        
        await saveTokens(
          accessToken: response['access_token'],
          refreshToken: response['refresh_token'],
        );
        
        print('AuthService: Token refresh successful');

        try{
          await createUserFromToken();
          print('AuthService: User created from token successfully');
        } catch (e) {
          print('AuthService: Error creating user from token: $e');
        }
        
        // Execute pending requests
        _executePendingRequests();
        
        return true;
      } else {
        throw Exception('Invalid refresh response');
      }
      
    } catch (e) {
      print('AuthService: Token refresh failed: $e');
      
      // If refresh fails, handle as expired session
      await _handleExpiredRefreshToken();
      
      return false;
    } finally {
      _isRefreshingToken = false;
    }
  }

  Future<bool> _waitForRefreshCompletion() async {
    int attempts = 0;
    while (_isRefreshingToken && attempts < AppConstants.maxRefreshRetries) {
      await Future.delayed(AppConstants.refreshTokenRetryDelay);
      attempts++;
    }
    
    // Check if refresh was successful
    final token = await getToken();
    return token != null && !JwtDecoder.isExpired(token);
  }

   Future<void> _handleExpiredRefreshToken() async {
    print('AuthService: Refresh token expired, clearing all auth data');
    await clearAllUserData();
    
    // Call the callback if set
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

   void _executePendingRequests() {
    for (final request in _pendingRequests) {
      try {
        request();
      } catch (e) {
        print('AuthService: Error executing pending request: $e');
      }
    }
    _pendingRequests.clear();
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

      final response = await _apiService.postFormRequest(
        '/login',
        {
          'username': email,
          'password': password,
        },
      );

      print('Login response body: $response');

      if (response != null && response['access_token'] != null) {
        if (response['refresh_token'] != null) {
          await saveTokens(
            accessToken: response['access_token'],
            refreshToken: response['refresh_token'],
          );
        } else {
          await saveToken(response['access_token']);
        }

        try{
          await createUserFromToken();
          print('AuthService: User created from token successfully');
        }catch (e) {
          print('AuthService: Error creating user from token: $e');
        }
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
        if (response['access_token'] != null && response['refresh_token'] != null) {
          await saveTokens(
            accessToken: response['access_token'],
            refreshToken: response['refresh_token'],
          );
          try{
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
          'DioException during signup: ${e.response?.statusCode} - ${e.response?.data}');

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
      // try to get user from stored data
      final userData = await getUserData();
      
      if (userData?.id != null) {
        print('AuthService: Calling /user/me with ID: ${userData!.id}');
        
        try {
          final response = await _apiService.getRequest('/user/me?id=${userData.id}');
          return response;
        } catch (e) {
          print('AuthService: API call failed, using stored data: $e');
          return userData.toJson();
        }
      } else {
        print('AuthService: No stored user data, creating from token...');
        
        // Create user from token if no stored data
        final userFromToken = await createUserFromToken();
        if (userFromToken != null) {
          try {
            // Try API call with new user ID
            final response = await _apiService.getRequest('/user/me?id=${userFromToken.id}');
            return response;
          } catch (e) {
            print('AuthService: API call failed, returning token data: $e');
            return userFromToken.toJson();
          }
        }
      }

      return null;
    } catch (e) {
      print('AuthService: Error in fetchUserInfo: $e');
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
      await removeAllTokens();
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
      await removeAllTokens();
      await _secureStorage.clearAllUserData();
      print('AuthService: All user data cleared');
    } catch (e) {
      print('AuthService: Error clearing user data: $e');
      throw Exception('Failed to clear user data: ${e.toString()}');
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

  Future<User?> createUserFromToken() async {
    try {
      final tokenInfo = await getUserInfoFromToken();
      if (tokenInfo == null) return null;

      // Extract data from token
      final email = tokenInfo['sub'] as String?;
      final userId = tokenInfo['id'] as int?;
      final isAdmin = tokenInfo['is_admin'] as bool? ?? false;

      if (email == null || userId == null) {
        print('AuthService: Missing required user data in token');
        return null;
      }

      // Create user object from token
      final user = User(
        id: userId,
        email: email,
        username: email.split('@')[0], 
        isVerified: true, 
        createdAt: DateTime.now(),
      );

      // Save user data
      await saveUserData(user);
      print('AuthService: Created and saved user from token: ${user.username}');

      return user;
    } catch (e) {
      print('AuthService: Error creating user from token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getTokenInfo() async {
    try {
      final accessToken = await getToken();
      final refreshToken = await getRefreshToken();
      
      if (accessToken == null || refreshToken == null) {
        return {
          'hasTokens': false,
          'accessTokenValid': false,
          'refreshTokenValid': false,
        };
      }
      
      final accessTokenExpired = JwtDecoder.isExpired(accessToken);
      final refreshTokenExpired = JwtDecoder.isExpired(refreshToken);
      
      Duration? accessTokenTimeToExpiry;
      Duration? refreshTokenTimeToExpiry;
      
      if (!accessTokenExpired) {
        accessTokenTimeToExpiry = JwtDecoder.getRemainingTime(accessToken);
      }
      
      if (!refreshTokenExpired) {
        refreshTokenTimeToExpiry = JwtDecoder.getRemainingTime(refreshToken);
      }
      
      return {
        'hasTokens': true,
        'accessTokenValid': !accessTokenExpired,
        'refreshTokenValid': !refreshTokenExpired,
        'accessTokenTimeToExpiry': accessTokenTimeToExpiry?.inMinutes,
        'refreshTokenTimeToExpiry': refreshTokenTimeToExpiry?.inDays,
        'needsRefresh': accessTokenExpired && !refreshTokenExpired,
        'requiresReauth': accessTokenExpired && refreshTokenExpired,
      };
    } catch (e) {
      print('AuthService: Error getting token info: $e');
      return {
        'hasTokens': false,
        'error': e.toString(),
      };
    }
  }
// Force refresh token (for testing)
  Future<bool> forceRefreshToken() async {
    return await _attemptTokenRefresh();
  }

  // Debug method for token information testing
    Future<void> debugPrintTokenInfo() async {
    final tokenInfo = await getTokenInfo();
    print('=== TOKEN DEBUG INFO ===');
    print('Has Tokens: ${tokenInfo['hasTokens']}');
    print('Access Token Valid: ${tokenInfo['accessTokenValid']}');
    print('Refresh Token Valid: ${tokenInfo['refreshTokenValid']}');
    print('Access Token TTL: ${tokenInfo['accessTokenTimeToExpiry']} minutes');
    print('Refresh Token TTL: ${tokenInfo['refreshTokenTimeToExpiry']} days');
    print('Needs Refresh: ${tokenInfo['needsRefresh']}');
    print('Requires Re-auth: ${tokenInfo['requiresReauth']}');
    print('========================');
  }
}
