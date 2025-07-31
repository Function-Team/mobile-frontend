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
  final RxBool obscureLoginPassword = true.obs;
  final RxString emailLoginError = ''.obs;
  final RxString passwordLoginError = ''.obs;

  // For register
  final TextEditingController usernameSignUpController =
      TextEditingController();
  final TextEditingController emailSignUpController = TextEditingController();
  final TextEditingController passwordSignUpController =
      TextEditingController();
  final TextEditingController confirmSignUpPasswordController =
      TextEditingController();
  final RxBool obscureSignUpPassword = true.obs;
  final RxBool obscureSignUpConfirmPassword = true.obs;
  final RxString usernameSignUpError = ''.obs;
  final RxString emailSignUpError = ''.obs;
  final RxString passwordSignUpError = ''.obs;
  final RxString confirmPasswordSignUpError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _authService.onSessionExpired = _handleSessionExpired;
    checkLoginStatus(autoNavigate: false);
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

  // Toggle password visibility
  void toggleLoginPasswordVisibility() {
    obscureLoginPassword.value = !obscureLoginPassword.value;
  }

  void toggleSignUpPasswordVisibility() {
    obscureSignUpPassword.value = !obscureSignUpPassword.value;
  }

  void toggleSignUpConfirmPasswordVisibility() {
    obscureSignUpConfirmPassword.value = !obscureSignUpConfirmPassword.value;
  }

  // Login validation methods
  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Please enter your email address';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Please enter your password';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Signup validation methods
  String? validateUsername(String username) {
    if (username.trim().isEmpty) {
      return 'Please enter a username';
    }
    if (username.trim().length < 3) {
      return 'Username must be at least 3 characters long';
    }
    return null;
  }

  String? validateSignUpEmail(String email) {
    if (email.trim().isNotEmpty &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Real-time validation for login
  void validateEmailLoginField(String value) {
    emailLoginError.value = validateEmail(value) ?? '';
  }

  void validatePasswordLoginField(String value) {
    passwordLoginError.value = validatePassword(value) ?? '';
  }

  // Real-time validation for signup
  void validateUsernameSignUpField(String value) {
    usernameSignUpError.value = validateUsername(value) ?? '';
  }

  void validateEmailSignUpField(String value) {
    emailSignUpError.value = validateSignUpEmail(value) ?? '';
  }

  void validatePasswordSignUpField(String value) {
    passwordSignUpError.value = validatePassword(value) ?? '';
    if (confirmPasswordSignUpError.isNotEmpty) {
      confirmPasswordSignUpError.value = validateConfirmPassword(
              value, confirmSignUpPasswordController.text) ??
          '';
    }
  }

  void validateConfirmPasswordSignUpField(String value) {
    confirmPasswordSignUpError.value =
        validateConfirmPassword(passwordSignUpController.text, value) ?? '';
  }

  // Submit validation for login
  bool validateLoginForm() {
    final emailError = validateEmail(emailLoginController.text.trim());
    final passwordError = validatePassword(passwordLoginController.text);

    emailLoginError.value = emailError ?? '';
    passwordLoginError.value = passwordError ?? '';

    return emailError == null && passwordError == null;
  }

  // Submit validation for signup
  bool validateSignUpForm() {
    final usernameError = validateUsername(usernameSignUpController.text);
    final emailError = validateSignUpEmail(emailSignUpController.text);
    final passwordError = validatePassword(passwordSignUpController.text);
    final confirmPasswordError = validateConfirmPassword(
        passwordSignUpController.text, confirmSignUpPasswordController.text);

    usernameSignUpError.value = usernameError ?? '';
    emailSignUpError.value = emailError ?? '';
    passwordSignUpError.value = passwordError ?? '';
    confirmPasswordSignUpError.value = confirmPasswordError ?? '';

    return usernameError == null &&
        emailError == null &&
        passwordError == null &&
        confirmPasswordError == null;
  }

  // email verification
  Future<void> resendVerificationEmail() async {
    if (emailSignUpController.text.trim().isEmpty) {
      throw Exception('Email address is required');
    }

    isLoading.value = true;
    try {
      await _authService
          .resendVerificationEmail(emailSignUpController.text.trim());
      print('AuthController: Verification email resent successfully');
    } catch (e) {
      print('AuthController: Error resending verification email: $e');
      rethrow; // Let the UI handle the specific error message
    } finally {
      isLoading.value = false;
    }
  }

// Method for check verification status
  Future<bool> checkEmailVerificationStatus() async {
    if (emailSignUpController.text.trim().isEmpty) {
      return false;
    }

    try {
      final isVerified = await _authService
          .checkEmailVerificationStatus(emailSignUpController.text.trim());
      return isVerified;
    } catch (e) {
      print('AuthController: Error checking verification status: $e');
      rethrow; // Let the UI handle the specific error message
    }
  }

// Navigate to email verification page
  void goToEmailVerification() {
    errorMessage.value = '';
    Get.toNamed(MyRoutes.emailVerification);
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
  Future<bool> checkLoginStatus({bool autoNavigate = true}) async {
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

        // Refresh from API
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
        if (autoNavigate) {
          Get.offAllNamed(MyRoutes.bottomNav);
        } else {
          print('AuthController: User logged in, but not auto-navigating');
        }
        return true;
      } else {
        print('AuthController: User not logged in, staying on current page');

        // Check if we have expired tokens that need cleanup
        await _cleanupExpiredTokens();
        return false;
      }
    } catch (e) {
      print('AuthController: Error checking login status: $e');
      return false;
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
    if (!validateLoginForm()) return;

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
          Get.offAllNamed(MyRoutes.bottomNav);
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
    if (!validateSignUpForm()) return;

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

      // Handle successful signup - backend kirim email otomatis
      if (response['access_token'] != null) {
        print('AuthController: Signup successful - email verification sent');

        // JANGAN simpan tokens atau login user - mereka perlu verify email dulu
        // Jangan clear form juga - user mungkin perlu ubah email

        CustomSnackbar.show(
            context: Get.context!,
            message: 'Account created! Check your email for verification link.',
            type: SnackbarType.success);

        // Always navigate to email verification page after successful signup
        goToEmailVerification();
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
      clearSignupForm();

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
    try {
      await _authService.clearAllUserData();
      user.value = null;
      errorMessage.value = '';
      emailLoginController.clear();
      passwordLoginController.clear();
      clearSignupForm();
      Get.offAllNamed(MyRoutes.login);
    } catch (e) {
      print('AuthController: Error during logout execution: $e');
    }
  }

  void clearSignupForm() {
    usernameSignUpController.clear();
    emailSignUpController.clear();
    passwordSignUpController.clear();
    confirmSignUpPasswordController.clear();
    usernameSignUpError.value = '';
    emailSignUpError.value = '';
    passwordSignUpError.value = '';
    confirmPasswordSignUpError.value = '';
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
}
