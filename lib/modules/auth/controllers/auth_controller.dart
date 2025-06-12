import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/bottom_sheets/logout_bottom_sheet.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/core/services/secure_storage_service.dart';
import 'package:function_mobile/modules/auth/models/auth_model.dart';
import 'package:function_mobile/modules/auth/services/auth_service.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/modules/navigation/controllers/bottom_nav_controller.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<User?> user = Rx<User?>(null);

  // For login
  final TextEditingController emailLoginController = TextEditingController();
  final TextEditingController passwordLoginController = TextEditingController();

  // For register
  final TextEditingController usernameSignUpController =
      TextEditingController();
  final TextEditingController emailSignUpController = TextEditingController();
  final TextEditingController passwordSignUpController =
      TextEditingController();
  final TextEditingController confirmSignUpPasswordController =
      TextEditingController();

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  @override
  void onClose() {
    usernameSignUpController.dispose();
    emailSignUpController.dispose();
    passwordSignUpController.dispose();
    confirmSignUpPasswordController.dispose();
    emailLoginController.dispose();
    passwordLoginController.dispose();
    super.onClose();
  }

  void goToLogin() {
    errorMessage.value = '';
    Get.toNamed(MyRoutes.login);
  }

  void goToSignup() {
    errorMessage.value = '';
    Get.toNamed(MyRoutes.signup);
  }

  void goToForgotPassword() {
    //TODO: Implement forgot password
    errorMessage.value = '';
    // Get.toNamed(MyRoutes.forgotPassword);
  }

  void goToPrivacyPolicy() {
    errorMessage.value = '';
    Get.toNamed(MyRoutes.privacyPolicy);
  }

  void goToTermsOfService() {
    errorMessage.value = '';
    Get.toNamed(MyRoutes.termsOfService);
  }

// login status check
  Future<void> checkLoginStatus() async {
    try {
      print('AuthController: Checking login status...');

      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        print('AuthController: User appears to be logged in, loading data...');

        // Pertama coba dapatkan data user dari local storage
        User? localUser = await _authService.getUserData();

        if (localUser != null) {
          user.value = localUser;
          print(
              "AuthController: User loaded from storage: ${user.value?.username}");
        }

        // Try to refresh user data with better error handling
        try {
          print('AuthController: Attempting to refresh user data from API...');
          final userData = await _authService.fetchUserInfo();

          if (userData != null) {
            // Create User object from API response
            final refreshedUser = User(
              id: userData['id'] ?? localUser?.id ?? 0,
              username:
                  userData['username'] ?? localUser?.username ?? 'Unknown',
              email:
                  userData['email'] ?? localUser?.email ?? 'unknown@email.com',
            );

            user.value = refreshedUser;
            await _authService.saveUserData(refreshedUser);
            print(
                "AuthController: User refreshed from API: ${user.value?.username}");
          } else {
            print(
                'AuthController: Could not refresh user data, using local data');
          }
        } catch (e) {
          print('AuthController: Error refreshing user data: $e');
          // Continue with local user data if API call fails
          if (localUser == null) {
            // If we have no local user data and API fails, create minimal user from token
            await _createUserFromToken();
          }
        }

        Get.offAllNamed(MyRoutes.bottomNav);
      } else {
        print('AuthController: User not logged in, staying on current page');
      }
    } catch (e) {
      print('AuthController: Error checking login status: $e');
    }
  }

  // Create user from token if API fails
  Future<void> _createUserFromToken() async {
    try {
      final tokenInfo = await _authService.getUserInfoFromToken();
      if (tokenInfo != null) {
        // Extract email from 'sub' field in token
        final email = tokenInfo['sub'] as String?;
        if (email != null) {
          final tempUser = User(
            id: 0, // Temporary ID
            username: email.split('@')[0], // Extract username from email
            email: email,
          );
          user.value = tempUser;
          await _authService.saveUserData(tempUser);
          print(
              'AuthController: Created temporary user from token: ${tempUser.username}');
        }
      }
    } catch (e) {
      print('AuthController: Error creating user from token: $e');
    }
  }

  // Clear error message when user starts typing
  void clearErrorMessage() {
    errorMessage.value = '';
  }

  // Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> login() async {
  // Clear previous error
  errorMessage.value = '';

  // Client-side validation
  if (emailLoginController.text.trim().isEmpty) {
    errorMessage.value = 'Please enter your email address';
    return;
  }

  if (!_isValidEmail(emailLoginController.text.trim())) {
    errorMessage.value = 'Please enter a valid email address';
    return;
  }

  if (passwordLoginController.text.isEmpty) {
    errorMessage.value = 'Please enter your password';
    return;
  }

  if (passwordLoginController.text.length < 6) {
    errorMessage.value = 'Password must be at least 6 characters long';
    return;
  }

  isLoading.value = true;

  try {
    final userData = await _authService.login(
      emailLoginController.text.trim(),
      passwordLoginController.text,
    );

    print('Login successful: ${userData['access_token'] != null}');

    if (userData['access_token'] != null) {
      try {
        print('Fetching user data after login...');
        final userInfo = await _authService.fetchProtectedData('/user/me');
        if (userInfo != null) {
          user.value = User.fromJson(userInfo);
          await _authService.saveUserData(user.value!);
          print('User data fetched and saved: ${user.value?.username}');
        }
      } catch (e) {
        print('ailed to fetch user data after login: $e');
        // Fallback: Create minimal user object from email
        user.value = User(
          id: -1,
          email: emailLoginController.text.trim(),
          username: emailLoginController.text.trim().split('@')[0],
        );
        await _authService.saveUserData(user.value!);
        print('Created fallback user data: ${user.value?.username}');
      }

      // Clear form fields on successful login
      emailLoginController.clear();
      passwordLoginController.clear();

      // Show success message
      CustomSnackbar.show(
        context: Get.context!,
        message: 'Welcome back, ${user.value?.username ?? 'User'}!',
        type: SnackbarType.success,
      );

      Get.offAllNamed(MyRoutes.bottomNav);
      Get.find<BottomNavController>().changePage(0);
    }
  } catch (e) {
    // Extract clean error message
    String message = e.toString();
    if (message.startsWith('Exception: ')) {
      message = message.substring(11);
    }

    errorMessage.value = message;
    print('Login error: $message');

    // Also show snackbar for better UX
    CustomSnackbar.show(
      context: Get.context!,
      message: 'Login Failed: $message',
      type: SnackbarType.error,
    );
  } finally {
    isLoading.value = false;
  }
}

  Future<void> signup() async {
  // Clear previous error
  errorMessage.value = '';

  // Client-side validation
  if (usernameSignUpController.text.trim().isEmpty) {
    errorMessage.value = 'Please enter a username';
    return;
  }

  if (usernameSignUpController.text.trim().length < 3) {
    errorMessage.value = 'Username must be at least 3 characters long';
    return;
  }

  if (emailSignUpController.text.trim().isEmpty) {
    errorMessage.value = 'Please enter an email address';
    return;
  }

  if (!_isValidEmail(emailSignUpController.text.trim())) {
    errorMessage.value = 'Please enter a valid email address';
    return;
  }

  if (passwordSignUpController.text.isEmpty) {
    errorMessage.value = 'Please enter a password';
    return;
  }

  if (passwordSignUpController.text.length < 6) {
    errorMessage.value = 'Password must be at least 6 characters long';
    return;
  }

  if (passwordSignUpController.text != confirmSignUpPasswordController.text) {
    errorMessage.value = 'Passwords do not match';
    return;
  }

  isLoading.value = true;

  try {
    final userData = await _authService.signup(
      usernameSignUpController.text.trim(),
      passwordSignUpController.text,
      emailSignUpController.text.trim(),
    );

    print('Signup successful: ${userData['access_token'] != null}');

    if (userData['access_token'] != null) {
      try {
        print('Fetching user data after signup...');
        final userInfo = await _authService.fetchProtectedData('/user/me');
        if (userInfo != null) {
          user.value = User.fromJson(userInfo);
          await _authService.saveUserData(user.value!);
          print('User data fetched and saved: ${user.value?.username}');
        }
      } catch (e) {
        print('Failed to fetch user data after signup: $e');
        user.value = User(
          id: -1,
          username: usernameSignUpController.text.trim(),
          email: emailSignUpController.text.trim(),
        );
        await _authService.saveUserData(user.value!);
        print('📝 Created fallback user data: ${user.value?.username}');
      }

      usernameSignUpController.clear();
      emailSignUpController.clear();
      passwordSignUpController.clear();
      confirmSignUpPasswordController.clear();

      // Show success message
      CustomSnackbar.show(
        context: Get.context!,
        message: 'Account created successfully! Welcome, ${user.value?.username ?? 'User'}!',
        type: SnackbarType.success,
      );

      Get.offAllNamed(MyRoutes.bottomNav);
    }
  } catch (e) {
    // Extract clean error message
    String message = e.toString();
    if (message.startsWith('Exception: ')) {
      message = message.substring(11);
    }

    errorMessage.value = message;
    print('Signup error: $message');

    // Also show snackbar for better UX
    CustomSnackbar.show(
      context: Get.context!,
      message: 'Registration Failed: $message',
      type: SnackbarType.error,
    );
  } finally {
    isLoading.value = false;
  }
}

  Future<void> logout() async {
    await _executeLogout();
  }

  Future<void> _executeLogout() async {
    try {
      isLoading.value = true;
      print('AuthController: Starting logout...');

      await _authService.logout();
      user.value = null;
      errorMessage.value = '';

      final secureStorage = SecureStorageService();
      await secureStorage.clearAllUserData();

      _showLogoutSuccess();
      Get.offAllNamed(MyRoutes.login);
    } catch (e) {
      await _handleLogoutError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _showLogoutSuccess() {
    CustomSnackbar.show(
      context: Get.context!,
      message: 'Berhasil keluar dari aplikasi',
      type: SnackbarType.success,
    );
  }

  Future<void> _handleLogoutError(dynamic error) async {
    print('Logout error: $error');

    // Force cleanup
    user.value = null;
    errorMessage.value = '';

    try {
      final secureStorage = SecureStorageService();
      await secureStorage.clearAllUserData();
    } catch (_) {}

    CustomSnackbar.show(
      context: Get.context!,
      message: 'Logout completed with warnings',
      type: SnackbarType.warning,
    );

    Get.offAllNamed(MyRoutes.login);
  }

  // username getter
  String get username {
    if (user.value?.username != null && user.value!.username.isNotEmpty) {
      return user.value!.username;
    } else if (user.value?.email != null) {
      return user.value!.email.split('@')[0]; // Extract username from email
    }
    return 'Guest';
  }

  // Helper methods for better state management
  bool get isAuthenticated => user.value != null;

  bool get hasValidUser => user.value != null && user.value!.id > 0;

  String? get userEmail => user.value?.email;

  int? get userId => user.value?.id;

  // Method to refresh user data
  Future<void> refreshUserData() async {
    try {
      if (!await _authService.isLoggedIn()) {
        await logout();
        return;
      }

      final userData = await _authService.fetchUserInfo();
      if (userData != null) {
        final refreshedUser = User(
          id: userData['id'] ?? user.value?.id ?? 0,
          username: userData['username'] ?? user.value?.username ?? 'Unknown',
          email: userData['email'] ?? user.value?.email ?? 'unknown@email.com',
        );

        user.value = refreshedUser;
        await _authService.saveUserData(refreshedUser);
        print("AuthController: User data refreshed successfully");
      }
    } catch (e) {
      print('AuthController: Error refreshing user data: $e');
      // Don't logout on refresh error, just log it
    }
  }

  // Method to check if session is still valid
  Future<bool> validateSession() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      return await _authService.isTokenValid();
    } catch (e) {
      print('AuthController: Session validation error: $e');
      return false;
    }
  }

  // Debug method to show current auth state
  void debugAuthState() {
    print('=== AUTH CONTROLLER DEBUG ===');
    print('Is Loading: ${isLoading.value}');
    print('Has Error: ${errorMessage.value.isNotEmpty}');
    print('Error Message: ${errorMessage.value}');
    print('User: ${user.value?.toJson()}');
    print('Is Authenticated: $isAuthenticated');
    print('Has Valid User: $hasValidUser');
    print('============================');
  }
}

extension AuthControllerLogout on AuthController {
  Future<void> showLogoutConfirmation() async {
    if (Get.context == null) return;

    final shouldLogout = await LogoutBottomSheet.show(
      Get.context!,
      imagePath: 'assets/images/logout.png',
    );

    if (shouldLogout == true) {
      await _executeLogout();
    }
  }

  Future<bool> testApiConnection() async {
    try {
      print('🧪 Testing API connection...');
      final userData = await _authService.fetchProtectedData('/user/me');
      print('✅ API Test Success: $userData');
      return true;
    } catch (e) {
      print('❌ API Test Failed: $e');
      return false;
    }
  }

  /// Validate current session without side effects
  Future<bool> validateCurrentSession() async {
    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        print('❌ No token found');
        return false;
      }

      print('🔍 Token found, testing validity...');
      return await testApiConnection();
    } catch (e) {
      print('❌ Session validation error: $e');
      return false;
    }
  }

  /// Get current auth state for debugging
  Map<String, dynamic> getAuthState() {
    return {
      'isLoading': isLoading.value,
      'isAuthenticated': isAuthenticated,
      'hasValidUser': hasValidUser,
      'userId': userId,
      'username': username,
      'userEmail': userEmail,
      'hasError': errorMessage.value.isNotEmpty,
      'errorMessage': errorMessage.value,
    };
  }

  /// Force refresh user data (for testing)
  Future<bool> forceRefreshUserData() async {
    try {
      print('🔄 Force refreshing user data...');
      await refreshUserData();
      print('✅ User data refreshed successfully');
      return true;
    } catch (e) {
      print('❌ Force refresh failed: $e');
      return false;
    }
  }

  /// Clear error state (for testing)
  void clearErrorState() {
    errorMessage.value = '';
    print('🧹 Error state cleared');
  }

  /// Test specific auth flow (for comprehensive testing)
  Future<Map<String, bool>> runAuthDiagnostics() async {
    final diagnostics = <String, bool>{};

    print('🔬 Running Auth Diagnostics...');

    // Test 1: Token existence
    final token = await _authService.getToken();
    diagnostics['hasToken'] = token != null && token.isNotEmpty;
    print('Token exists: ${diagnostics['hasToken']}');

    // Test 2: User data existence
    final userData = await _authService.getUserData();
    diagnostics['hasUserData'] = userData != null;
    print('User data exists: ${diagnostics['hasUserData']}');

    // Test 3: API connectivity (if token exists)
    if (diagnostics['hasToken'] == true) {
      diagnostics['apiConnectivity'] = await testApiConnection();
      print('API connectivity: ${diagnostics['apiConnectivity']}');
    } else {
      diagnostics['apiConnectivity'] = false;
      print('API connectivity: SKIPPED (no token)');
    }

    // Test 4: Session validity
    diagnostics['sessionValid'] = await validateCurrentSession();
    print('Session valid: ${diagnostics['sessionValid']}');

    print('🔬 Diagnostics complete: $diagnostics');
    return diagnostics;
  }
}
