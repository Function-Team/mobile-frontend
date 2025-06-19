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

  final RxBool isRefreshingToken = false.obs;
  final RxString refreshTokenStatus = ''.obs;

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
    _authService.onSessionExpired = _handleSessionExpired;
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

        // Load user from local storage first
        User? localUser = await _authService.getUserData();

        if (localUser != null) {
          user.value = localUser;
          print(
              "AuthController: User loaded from storage: ${user.value?.username}");
        }

        // Try to refresh user data with better error handling
        try {
          print('AuthController: Attempting to refresh user data from API...');
          await refreshUserData();
        } catch (e) {
          print('AuthController: Error refreshing user data: $e');
          // Continue with local user data if API call fails
          if (localUser == null) {
            await _createUserFromToken();
          }
        }

        Get.offAllNamed(MyRoutes.bottomNav);
      } else {
        print('AuthController: User not logged in, staying on current page');

        // NEW: Check if we have expired tokens that need cleanup
        await _cleanupExpiredTokens();
      }
    } catch (e) {
      print('AuthController: Error checking login status: $e');
    }
  }

  Future<void> _cleanupExpiredTokens() async {
    try {
      final tokenInfo = await _authService.getTokenInfo();
      if (tokenInfo['requiresReauth'] == true) {
        print('AuthController: Cleaning up expired tokens');
        await _authService.clearAllUserData();
      }
    } catch (e) {
      print('AuthController: Error cleaning up tokens: $e');
    }
  }

  // Create user from token if API fails
  Future<void> _createUserFromToken() async {
    try {
      final tokenInfo = await _authService.getUserInfoFromToken();
      if (tokenInfo != null) {
        final email = tokenInfo['sub'] as String?;
        if (email != null) {
          final tempUser = User(
            id: 0,
            username: email.split('@')[0],
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

  Future<void> login() async {
    if (!_validateLoginForm()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('AuthController: Starting login process...');

      final response = await _authService.login(
        emailLoginController.text.trim(),
        passwordLoginController.text.trim(),
      );

      print('AuthController: Login response received');

      // Handle successful login
      if (response['access_token'] != null) {
        print('AuthController: Login successful, processing user data...');

        // Create AuthResponse to handle the response properly
        final authResponse = AuthResponse.fromLoginResponse(response);

        // If user data is included in response, save it
        if (authResponse.user != null) {
          user.value = authResponse.user;
          await _authService.saveUserData(authResponse.user!);
        } else {
          // Try to fetch user data from API
          await refreshUserData();
        }

        // Clear form
        emailLoginController.clear();
        passwordLoginController.clear();

        // Navigate to main app
        Get.offAllNamed(MyRoutes.bottomNav);

        // Show success message
        CustomSnackbar.show(
          context: Get.context!,
          message: 'Login successful',
          type: SnackbarType.success,
        );
      }
    } catch (e) {
      print('AuthController: Login error: $e');
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');

      CustomSnackbar.show(
        context: Get.context!,
        message: 'Login Failed',
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup() async {
    if (!_validateSignupForm()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('AuthController: Starting signup process...');

      final response = await _authService.signup(
        usernameSignUpController.text.trim(),
        passwordSignUpController.text.trim(),
        emailSignUpController.text.trim(),
      );

      print('AuthController: Signup response received');

      // Handle successful signup
      if (response['access_token'] != null || response['user'] != null) {
        print('AuthController: Signup successful');

        // Create AuthResponse to handle the response properly
        final authResponse = AuthResponse.fromJson(response);

        // If tokens are provided, user is auto-logged in
        if (authResponse.accessToken != null) {
          if (authResponse.user != null) {
            user.value = authResponse.user;
            await _authService.saveUserData(authResponse.user!);
          } else {
            await refreshUserData();
          }

          // Clear form
          _clearSignupForm();

          // Navigate to main app
          Get.offAllNamed(MyRoutes.bottomNav);

          CustomSnackbar.show(
              context: Get.context!,
              message: 'Account created successfully',
              type: SnackbarType.success);
        } else {
          // Account created but not logged in (email verification required)
          _clearSignupForm();

          CustomSnackbar.show(
              context: Get.context!,
              message: 'Please check your email to verify your account',
              type: SnackbarType.success);

          goToLogin();
        }
      }
    } catch (e) {
      print('AuthController: Signup error: $e');
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');

      CustomSnackbar.show(
        context: Get.context!,
        message: 'Signup Failed',
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      print('AuthController: Starting logout process...');

      await _authService.logout();

      user.value = null;
      errorMessage.value = '';

      emailLoginController.clear();
      passwordLoginController.clear();
      _clearSignupForm();

      print('AuthController: Logout successful, clearing user data...');

      Get.offAllNamed(MyRoutes.login);

      CustomSnackbar.show(
        context: Get.context!,
        message: 'You have been successfully logged out',
        type: SnackbarType.success,
      );
    } catch (e) {
      print('AuthController: Logout error: $e');

      await _executeLogout();

      CustomSnackbar.show(
        context: Get.context!,
        message: 'Logout Failed',
        type: SnackbarType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _executeLogout() async {
   try{
    await _authService.clearAllUserData();
    user.value = null;
    errorMessage.value = '';
    emailLoginController.clear();
    passwordLoginController.clear();
    _clearSignupForm();
    Get.offAllNamed(MyRoutes.login);
   }catch (e) {
     print('AuthController: Error during logout execution: $e');
   }
  }


  void _clearSignupForm() {
    usernameSignUpController.clear();
    emailSignUpController.clear();
    passwordSignUpController.clear();
    confirmSignUpPasswordController.clear();
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

  // Method to refresh user data
  Future<void> refreshUserData() async {
    try {
     print('AuthController: Refreshing user data...');
      
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
      
      // If refresh fails due to auth issues, handle session expiry
      if (e.toString().contains('session has expired') || 
          e.toString().contains('Authentication required')) {
        await _handleSessionExpired();
      }
    }
  }

   Future<void> _handleSessionExpired() async {
    print('AuthController: Handling expired session...');

    try {
      await _authService.clearAllUserData();
      user.value = null;
      errorMessage.value = '';

      Get.offAllNamed(MyRoutes.login);

      CustomSnackbar.show(
          context: Get.context!,
          message: 'Please login again to continue',
          type: SnackbarType.warning);
    } catch (e) {
      print('AuthController: Error handling session expiry: $e');
    }
  }

   // Force refresh token (for testing or manual refresh)
  Future<bool> forceRefreshToken() async {
    try {
      isRefreshingToken.value = true;
      refreshTokenStatus.value = 'Refreshing...';
      
      final success = await _authService.forceRefreshToken();
      
      if (success) {
        refreshTokenStatus.value = 'Token refreshed successfully';
        
        // Refresh user data after token refresh
        await refreshUserData();
        
        return true;
      } else {
        refreshTokenStatus.value = 'Token refresh failed';
        return false;
      }
    } catch (e) {
      refreshTokenStatus.value = 'Token refresh error: $e';
      return false;
    } finally {
      isRefreshingToken.value = false;
      
      // Clear status after delay
      Future.delayed(const Duration(seconds: 3), () {
        refreshTokenStatus.value = '';
      });
    }
  }

  Future<Map<String, dynamic>> getTokenInfo() async {
    return await _authService.getTokenInfo();
  }

    bool _validateLoginForm() {
    final email = emailLoginController.text.trim();
    final password = passwordLoginController.text.trim();

    if (email.isEmpty) {
      errorMessage.value = 'Please enter your email';
      return false;
    }

    if (!_isValidEmail(email)) {
      errorMessage.value = 'Please enter a valid email address';
      return false;
    }

    if (password.isEmpty) {
      errorMessage.value = 'Please enter your password';
      return false;
    }

    if (password.length < 6) {
      errorMessage.value = 'Password must be at least 6 characters';
      return false;
    }

    return true;
  }

  bool _validateSignupForm() {
    final username = usernameSignUpController.text.trim();
    final email = emailSignUpController.text.trim();
    final password = passwordSignUpController.text.trim();
    final confirmPassword = confirmSignUpPasswordController.text.trim();

    if (username.isEmpty) {
      errorMessage.value = 'Please enter a username';
      return false;
    }

    if (username.length < 3) {
      errorMessage.value = 'Username must be at least 3 characters';
      return false;
    }

    if (email.isEmpty) {
      errorMessage.value = 'Please enter your email';
      return false;
    }

    if (!_isValidEmail(email)) {
      errorMessage.value = 'Please enter a valid email address';
      return false;
    }

    if (password.isEmpty) {
      errorMessage.value = 'Please enter a password';
      return false;
    }

    if (password.length < 6) {
      errorMessage.value = 'Password must be at least 6 characters';
      return false;
    }

    if (confirmPassword.isEmpty) {
      errorMessage.value = 'Please confirm your password';
      return false;
    }

    if (password != confirmPassword) {
      errorMessage.value = 'Passwords do not match';
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  
 bool get isAuthenticated => user.value != null;
  bool get hasValidUser => user.value != null && user.value!.id > 0;
  int? get userId => user.value?.id;
  String? get userEmail => user.value?.email;

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

  Future<bool> validateCurrentSession() async {
    try {
      final tokenInfo = await getTokenInfo();
      if (tokenInfo['hasTokens'] != true) {
        print('❌ No tokens found');
        return false;
      }

      if (tokenInfo['requiresReauth'] == true) {
        print('❌ Tokens expired, requires re-authentication');
        return false;
      }

      print('🔍 Tokens found, testing API connectivity...');
      return await testApiConnection();
    } catch (e) {
      print('❌ Session validation error: $e');
      return false;
    }
  }

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
      'isRefreshingToken': isRefreshingToken.value,
      'refreshTokenStatus': refreshTokenStatus.value,
    };
  }

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

  void clearErrorState() {
    errorMessage.value = '';
    refreshTokenStatus.value = '';
    print('🧹 Error state cleared');
  }

  // Enhanced diagnostics with refresh token info
  Future<Map<String, bool>> runAuthDiagnostics() async {
    final diagnostics = <String, bool>{};

    print('🔬 Running Enhanced Auth Diagnostics...');

    // Test 1: Token existence
    final tokenInfo = await getTokenInfo();
    diagnostics['hasTokens'] = tokenInfo['hasTokens'] == true;
    diagnostics['hasAccessToken'] = tokenInfo['accessTokenValid'] == true;
    diagnostics['hasRefreshToken'] = tokenInfo['refreshTokenValid'] == true;
    print('Has Tokens: ${diagnostics['hasTokens']}');
    print('Access Token Valid: ${diagnostics['hasAccessToken']}');
    print('Refresh Token Valid: ${diagnostics['hasRefreshToken']}');

    // Test 2: User data existence
    final userData = await _authService.getUserData();
    diagnostics['hasUserData'] = userData != null;
    print('User data exists: ${diagnostics['hasUserData']}');

    // Test 3: API connectivity (if tokens exist)
    if (diagnostics['hasTokens'] == true) {
      diagnostics['apiConnectivity'] = await testApiConnection();
      print('API connectivity: ${diagnostics['apiConnectivity']}');
    } else {
      diagnostics['apiConnectivity'] = false;
      print('API connectivity: SKIPPED (no tokens)');
    }

    // Test 4: Session validity
    diagnostics['sessionValid'] = await validateCurrentSession();
    print('Session valid: ${diagnostics['sessionValid']}');

    // Test 5: Token refresh capability
    if (tokenInfo['needsRefresh'] == true) {
      diagnostics['canRefresh'] = await forceRefreshToken();
      print('Can refresh: ${diagnostics['canRefresh']}');
    } else {
      diagnostics['canRefresh'] = diagnostics['hasRefreshToken'] == true;
      print('Can refresh: ${diagnostics['canRefresh']} (refresh not needed)');
    }

    print('🔬 Enhanced diagnostics complete: $diagnostics');
    return diagnostics;
  }

  // NEW: Debug token information
  Future<void> debugPrintTokenInfo() async {
    await _authService.debugPrintTokenInfo();
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
