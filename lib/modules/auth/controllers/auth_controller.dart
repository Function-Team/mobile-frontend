import 'package:flutter/material.dart';
import 'package:function_mobile/core/services/secure_storage_service.dart';
import 'package:function_mobile/modules/settings/widgets/logout_bottom_sheet.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/modules/auth/models/auth_model.dart';
import 'package:function_mobile/modules/auth/services/auth_service.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<User?> user = Rx<User?>(null);

  // Login form
  final TextEditingController emailLoginController = TextEditingController();
  final TextEditingController passwordLoginController = TextEditingController();
  final RxBool obscureLoginPassword = true.obs;
  final RxString emailLoginError = ''.obs;
  final RxString passwordLoginError = ''.obs;

  // Signup form
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
  // Controllers untuk reset password
  final TextEditingController resetEmailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _authService.onSessionExpired = _handleSessionExpired;
    checkLoginStatus(autoNavigate: false);
  }

  @override
  void onClose() {
    // Dispose all controllers
    emailLoginController.dispose();
    passwordLoginController.dispose();
    usernameSignUpController.dispose();
    emailSignUpController.dispose();
    passwordSignUpController.dispose();
    confirmSignUpPasswordController.dispose();
    resetEmailController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.onClose();
  }

  // ===== MAIN AUTH ACTIONS =====
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

      if (response['access_token'] != null) {
        print('AuthController: Login successful, fetching user data...');

        // Get real user data from API (with correct username)
        try {
          final userData = await _authService.fetchUserInfo();
          if (userData != null) {
            final loggedInUser = User(
              id: userData['id'] ?? 0,
              username: userData['username'] ?? 'Unknown',
              email: userData['email'] ?? emailLoginController.text.trim(),
              isVerified: userData['is_verified'] ?? false,
              createdAt: userData['created_at'] != null
                  ? DateTime.parse(userData['created_at'])
                  : DateTime.now(),
            );

            user.value = loggedInUser;
            await _authService.saveUserData(loggedInUser);
            print(
                'AuthController: User data loaded with username: ${loggedInUser.username}');
          }
        } catch (e) {
          print('AuthController: Error getting user data: $e');
          // Fallback: create temporary user
          await _createUserFromToken();
        }

        // Clear form and navigate
        emailLoginController.clear();
        passwordLoginController.clear();
        Get.offAllNamed(MyRoutes.bottomNav);

        LocalizationHelper.showSnackbarSafe(
          message: 'Welcome back, ${username}!',
          type: SnackbarType.success,
        );
      }
    } catch (e) {
      print('AuthController: Login error: $e');
      final cleanErrorMessage = e.toString().replaceFirst('Exception: ', '');
      errorMessage.value = cleanErrorMessage;

      // Handle email verification error specifically
      if (cleanErrorMessage == 'EMAIL_NOT_VERIFIED') {
        // Store the email for verification page
        emailSignUpController.text = emailLoginController.text.trim();
        
        LocalizationHelper.showSnackbarSafe(
          message: 'Email belum diverifikasi. Silakan verifikasi email Anda terlebih dahulu.',
          type: SnackbarType.warning,
        );
        
        // Navigate to email verification page
        await goToEmailVerification();
        return;
      }
      
      // Handle generic authentication failure - check if it's an unverified email
      if (cleanErrorMessage == 'AUTHENTICATION_FAILED') {
        try {
          // Check if this email exists and is unverified
          emailSignUpController.text = emailLoginController.text.trim();
          final isVerified = await checkEmailVerificationStatus();
          
          if (!isVerified) {
            // Email exists but not verified
            LocalizationHelper.showSnackbarSafe(
              message: 'Email Anda belum diverifikasi. Silakan cek email Anda untuk link verifikasi.',
              type: SnackbarType.warning,
            );
            
            // Navigate to email verification page
            await goToEmailVerification();
            return;
          } else {
            // Email is verified, so it's actually wrong credentials
            LocalizationHelper.showSnackbarSafe(
              message: 'Email atau password salah. Silakan periksa kembali.',
              type: SnackbarType.error,
            );
            return;
          }
        } catch (e) {
          // If verification check fails, show generic error
          CustomSnackbar.show(
            context: Get.context!,
            message: 'Email atau password salah. Silakan periksa kembali.',
            type: SnackbarType.error,
            autoClear: true,
            enableDebounce: false,
          );
          return;
        }
      }

      // Show specific error message
      CustomSnackbar.show(
        context: Get.context!,
        message: cleanErrorMessage.isNotEmpty ? cleanErrorMessage : 'Login Failed',
        type: SnackbarType.error,
        autoClear: true,
        enableDebounce: false,
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

      if (response['access_token'] != null) {
        print('AuthController: Signup successful - email verification sent');

        CustomSnackbar.show(
          context: Get.context!,
          message: 'Account created! Check your email for verification link.',
          type: SnackbarType.success,
          autoClear: true,
          enableDebounce: false,
        );

        await goToEmailVerification();
      }
    } catch (e) {
      print('AuthController: Signup error: $e');
      final cleanErrorMessage = e.toString().replaceFirst('Exception: ', '');
      errorMessage.value = cleanErrorMessage;

      // Handle "email already registered" specifically
      if (cleanErrorMessage.contains('email already registered') ||
          cleanErrorMessage.contains('Email already registered')) {
        
        // Check if this email is already verified
        try {
          final isVerified = await checkEmailVerificationStatus();
          
          if (isVerified) {
            // Email exists and verified - redirect to login
            CustomSnackbar.show(
              context: Get.context!,
              message: 'Email already registered and verified. Please login instead.',
              type: SnackbarType.info,
              autoClear: true,
              enableDebounce: false,
            );
            goToLogin();
          } else {
            // Email exists but not verified - continue verification
            CustomSnackbar.show(
              context: Get.context!,
              message: 'Email already registered but not verified. Continue verification.',
              type: SnackbarType.info,
              autoClear: true,
              enableDebounce: false,
            );
            await goToEmailVerification();
          }
        } catch (e) {
          // If verification check fails, redirect to login (safer fallback)
          CustomSnackbar.show(
            context: Get.context!,
            message: 'Email already registered. Please try logging in.',
            type: SnackbarType.info,
            autoClear: true,
            enableDebounce: false,
          );
          goToLogin();
        }
        return;
      }

      CustomSnackbar.show(
        context: Get.context!,
        message: cleanErrorMessage.isNotEmpty ? cleanErrorMessage : 'Signup Failed',
        type: SnackbarType.error,
        autoClear: true,
        enableDebounce: false,
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
      await _executeLogout();

      CustomSnackbar.show(
        context: Get.context!,
        message: 'You have been successfully logged out',
        type: SnackbarType.success,
        autoClear: true,
        enableDebounce: false,
      );
    } catch (e) {
      print('AuthController: Logout error: $e');
      await _executeLogout();

      CustomSnackbar.show(
        context: Get.context!,
        message: 'Logout Failed',
        type: SnackbarType.error,
        autoClear: true,
        enableDebounce: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ===== EMAIL VERIFICATION =====
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
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkEmailVerificationStatus() async {
    if (emailSignUpController.text.trim().isEmpty) {
      return false;
    }

    try {
      final isVerified = await _authService.checkEmailVerificationStatus(
        emailSignUpController.text.trim(),
      );
      return isVerified;
    } catch (e) {
      print('AuthController: Error checking verification status: $e');
      rethrow;
    }
  }

  // ===== VALIDATION METHODS =====
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

  // Form validation
  bool validateLoginForm() {
    final emailError = validateEmail(emailLoginController.text.trim());
    final passwordError = validatePassword(passwordLoginController.text);

    emailLoginError.value = emailError ?? '';
    passwordLoginError.value = passwordError ?? '';

    return emailError == null && passwordError == null;
  }

  bool validateSignUpForm() {
    final usernameError = validateUsername(usernameSignUpController.text);
    final emailError = validateSignUpEmail(emailSignUpController.text);
    final passwordError = validatePassword(passwordSignUpController.text);
    final confirmPasswordError = validateConfirmPassword(
      passwordSignUpController.text,
      confirmSignUpPasswordController.text,
    );

    usernameSignUpError.value = usernameError ?? '';
    emailSignUpError.value = emailError ?? '';
    passwordSignUpError.value = passwordError ?? '';
    confirmPasswordSignUpError.value = confirmPasswordError ?? '';

    return usernameError == null &&
        emailError == null &&
        passwordError == null &&
        confirmPasswordError == null;
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
            value,
            confirmSignUpPasswordController.text,
          ) ??
          '';
    }
  }

  void validateConfirmPasswordSignUpField(String value) {
    confirmPasswordSignUpError.value = validateConfirmPassword(
          passwordSignUpController.text,
          value,
        ) ??
        '';
  }

  // ===== UI HELPERS =====
  void toggleLoginPasswordVisibility() {
    obscureLoginPassword.value = !obscureLoginPassword.value;
  }

  void toggleSignUpPasswordVisibility() {
    obscureSignUpPassword.value = !obscureSignUpPassword.value;
  }

  void toggleSignUpConfirmPasswordVisibility() {
    obscureSignUpConfirmPassword.value = !obscureSignUpConfirmPassword.value;
  }

  void clearErrorMessage() {
    errorMessage.value = '';
  }

  Future<void> clearSignupForm() async {
    try {
      usernameSignUpController.clear();
      emailSignUpController.clear();
      passwordSignUpController.clear();
      confirmSignUpPasswordController.clear();
      usernameSignUpError.value = '';
      emailSignUpError.value = '';
      passwordSignUpError.value = '';
      confirmPasswordSignUpError.value = '';
    } catch (e) {
      print('AuthController: Error clearing signup form: $e');
      // Don't rethrow, this shouldn't block logout
    }
  }

  // ===== NAVIGATION METHODS =====
  Future<void> goToEmailVerification() async {
    try {
      errorMessage.value = '';
      Get.toNamed(MyRoutes.emailVerification);
    } catch (e) {
      print('AuthController: Error navigating to email verification: $e');
      // Still navigate even if storage fails
      Get.toNamed(MyRoutes.emailVerification);
    }
  }

  void goToLogin() {
    errorMessage.value = '';
    Get.toNamed(MyRoutes.login);
  }

  void goToSignup() {
    errorMessage.value = '';
    Get.toNamed(MyRoutes.signup);
  }

  void goToPrivacyPolicy() {
    errorMessage.value = '';
    Get.toNamed(MyRoutes.privacyPolicy);
  }

  void goToTermsOfService() {
    errorMessage.value = '';
    Get.toNamed(MyRoutes.termsOfService);
  }

  // ===== UTILITY GETTERS & METHODS =====
  String get username {
    if (user.value?.username != null && user.value!.username.isNotEmpty) {
      return user.value!.username;
    } else if (user.value?.email != null) {
      return user.value!.email.split('@')[0];
    }
    return 'Guest';
  }

  bool get isAuthenticated => user.value != null;
  bool get hasValidUser => user.value != null && user.value!.id > 0;
  int? get userId => user.value?.id;
  String? get userEmail => user.value?.email;


  Future<void> refreshUserData() async {
    try {
      print('AuthController: Refreshing user data from API...');

      final userData = await _authService.fetchUserInfo();

      if (userData != null) {
        final refreshedUser = User(
          id: userData['id'] ?? user.value?.id ?? 0,
          username: userData['username'] ?? user.value?.username ?? 'Unknown',
          email:
              userData['email'] ?? user.value?.email ?? 'unknown@example.com',
          isVerified:
              userData['is_verified'] ?? user.value?.isVerified ?? false,
          createdAt: userData['created_at'] != null
              ? DateTime.parse(userData['created_at'])
              : user.value?.createdAt ?? DateTime.now(),
        );

        user.value = refreshedUser;
        await _authService.saveUserData(refreshedUser);

        print(
            'AuthController: User data refreshed with username: ${refreshedUser.username}');
      }
    } catch (e) {
      print('AuthController: Error refreshing user data: $e');
      throw Exception('Failed to refresh user data: ${e.toString()}');
    }
  }

  Future<bool> checkLoginStatus({bool autoNavigate = true}) async {
    try {
      print('AuthController: Checking login status...');

      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        print('AuthController: User appears to be logged in, loading data...');

        // Load user from local storage first (for immediate UI update)
        User? localUser = await _authService.getUserData();
        if (localUser != null) {
          user.value = localUser;
          print(
              'AuthController: User loaded from storage: ${user.value?.username}');
        }

        // Refresh from API to get latest data (including correct username)
        try {
          print('AuthController: Refreshing user data from API...');
          await refreshUserData();
        } catch (e) {
          print('AuthController: Error refreshing user data: $e');
          // If refresh fails but we have local user, continue
          if (localUser == null) {
            await _createUserFromToken();
          }
        }

        if (autoNavigate) {
          Get.offAllNamed(MyRoutes.bottomNav);
        } else {
          print('AuthController: User logged in with username: ${username}');
        }
        return true;
      } else {
        print('AuthController: User not logged in');
        await _cleanupExpiredTokens();
        return false;
      }
    } catch (e) {
      print('AuthController: Error checking login status: $e');
      return false;
    }
  }

  // ===== PRIVATE HELPER METHODS =====
  Future<void> _executeLogout() async {
    try {
      await _authService.clearAllUserData();
      user.value = null;
      errorMessage.value = '';
      
      try {
        emailLoginController.clear();
        passwordLoginController.clear();
        await clearSignupForm();
      } catch (e) {
        print('AuthController: Error clearing forms during logout: $e');
      }
      
      Get.offAllNamed(MyRoutes.login);
    } catch (e) {
      print('AuthController: Error during logout execution: $e');
      Get.offAllNamed(MyRoutes.login);
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

  Future<void> _createUserFromToken() async {
    try {
      final tokenInfo = await _authService.getUserInfoFromToken();
      if (tokenInfo != null) {
        final email = tokenInfo['sub'] as String?;
        final userId = tokenInfo['id'] as int?;

        if (email != null && userId != null) {
          // TRY API CALL FIRST to get real username
          try {
            final apiData = await _authService.fetchUserInfo();
            if (apiData != null && apiData['username'] != null) {
              final newUser = User(
                id: userId,
                email: email,
                username: apiData['username'],
                isVerified: apiData['is_verified'] ?? false,
                createdAt: apiData['created_at'] != null
                    ? DateTime.parse(apiData['created_at'])
                    : DateTime.now(),
              );

              user.value = newUser;
              await _authService.saveUserData(newUser);
              print(
                  'AuthController: User created from API with real username: ${newUser.username}');
              return;
            }
          } catch (e) {
            print('AuthController: API call failed, using fallback: $e');
          }

          // FALLBACK: Create with email-based username
          final tempUser = User(
            id: userId,
            email: email,
            username: email.split('@')[0],
            isVerified: tokenInfo['is_verified'] ?? false,
            createdAt: DateTime.now(),
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

  void _handleSessionExpired() {
    try {
      print(
          'AuthController: Session expired, clearing data and redirecting to login');
      _executeLogout();

      CustomSnackbar.show(
        context: Get.context!,
        message: 'Session expired. Please login again.',
        type: SnackbarType.warning,
        autoClear: true,
        enableDebounce: false,
      );
    } catch (e) {
      print('AuthController: Error handling session expiry: $e');
    }
  }
}

extension AuthControllerLogout on AuthController {
  Future<void> showLogoutConfirmation() async {
    final context = Get.context;
    if (context == null || !context.mounted) return;

    final shouldLogout = await LogoutBottomSheet.show(
      context,
      imagePath: 'assets/images/logout.png',
    );

    if (shouldLogout == true) {
      await logout();
    }
  }

  Future<void> requestPasswordReset() async {
    try {
      final email = resetEmailController.text.trim();

      // Validasi email
      if (email.isEmpty) {
        errorMessage.value = 'Please enter your email address';
        return;
      }

      isLoading.value = true;
      await _authService.requestPasswordReset(email);
      isLoading.value = false;

      // Tampilkan pesan sukses
      CustomSnackbar.show(
        context: Get.context!,
        message:
            'If your email is registered, you will receive a password reset link.',
        type: SnackbarType.success,
        autoClear: true,
        enableDebounce: false,
      );

      // Kembali ke halaman login
      Get.back();
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Validasi input
      if (currentPassword.isEmpty) {
        throw Exception('Please enter your current password');
      }

      if (newPassword.isEmpty) {
        throw Exception('Please enter a new password');
      }

      if (newPassword.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      if (currentPassword == newPassword) {
        throw Exception('New password must be different from current password');
      }

      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> requestPasswordChange({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      // Validate inputs
      if (currentPassword.isEmpty) {
        throw Exception('Current password is required');
      }

      if (newPassword.isEmpty) {
        throw Exception('New password is required');
      }

      if (confirmPassword.isEmpty) {
        throw Exception('Password confirmation is required');
      }

      if (newPassword.length < 8) {
        throw Exception('New password must be at least 8 characters long');
      }

      if (newPassword != confirmPassword) {
        throw Exception('New password and confirmation do not match');
      }

      if (currentPassword == newPassword) {
        throw Exception('New password must be different from current password');
      }

      // Call the auth service to request password change
      await _authService.requestPasswordChange(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> resetPassword(String token) async {
    try {
      final newPassword = newPasswordController.text;
      final confirmPassword = confirmNewPasswordController.text;

      // Validasi password
      if (newPassword.isEmpty) {
        errorMessage.value = 'Please enter a new password';
        return;
      }

      if (newPassword != confirmPassword) {
        errorMessage.value = 'Passwords do not match';
        return;
      }

      isLoading.value = true;
      await _authService.resetPassword(token, newPassword);
      isLoading.value = false;

      // Tampilkan pesan sukses
      CustomSnackbar.show(
        context: Get.context!,
        message:
            'Password reset successful. You can now login with your new password.',
        type: SnackbarType.success,
        autoClear: true,
        enableDebounce: false,
      );

      // Kembali ke halaman login
      Get.offAllNamed(MyRoutes.login);
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }
}
