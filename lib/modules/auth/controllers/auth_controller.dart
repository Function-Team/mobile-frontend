import 'package:flutter/material.dart';
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
          print("AuthController: User loaded from storage: ${user.value?.username}");
        }

        // Try to refresh user data with better error handling
        try {
          print('AuthController: Attempting to refresh user data from API...');
          final userData = await _authService.fetchUserInfo();
          
          if (userData != null) {
            // Create User object from API response
            final refreshedUser = User(
              id: userData['id'] ?? localUser?.id ?? 0,
              username: userData['username'] ?? localUser?.username ?? 'Unknown',
              email: userData['email'] ?? localUser?.email ?? 'unknown@email.com',
            );
            
            user.value = refreshedUser;
            await _authService.saveUserData(refreshedUser);
            print("AuthController: User refreshed from API: ${user.value?.username}");
          } else {
            print('AuthController: Could not refresh user data, using local data');
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
          print('AuthController: Created temporary user from token: ${tempUser.username}');
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
      print('AuthController: Attempting login...');
      
      final userData = await _authService.login(
        emailLoginController.text.trim(),
        passwordLoginController.text,
      );

      if (userData['access_token'] != null) {
        print('AuthController: Login successful, token received');
        
        // Create user from login response and token
        await _handleSuccessfulLogin();
        
        // Clear form fields on successful login
        emailLoginController.clear();
        passwordLoginController.clear();
        
        // Show success message
        CustomSnackbar.show(
            context: Get.context!,
            message: 'Welcome back, ${user.value?.username ?? 'User'}!',
            type: SnackbarType.success);
            
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

      // Also show snackbar for better UX
      CustomSnackbar.show(
          context: Get.context!,
          message: 'Login Failed: $message',
          type: SnackbarType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleSuccessfulLogin() async {
    try {
      // First, try to get user info from API
      final userInfo = await _authService.fetchUserInfo();
      
      if (userInfo != null) {
        // Create user from API response
        user.value = User(
          id: userInfo['id'] ?? 0,
          username: userInfo['username'] ?? 'Unknown',
          email: userInfo['email'] ?? emailLoginController.text.trim(),
        );
        print('AuthController: User created from API response');
      } else {
        // Fallback: create user from token
        await _createUserFromToken();
        if (user.value == null) {
          // Last resort: create basic user
          user.value = User(
            id: 0,
            username: emailLoginController.text.split('@')[0],
            email: emailLoginController.text.trim(),
          );
          print('AuthController: Created basic user as fallback');
        }
      }
      
      // Save user data
      if (user.value != null) {
        await _authService.saveUserData(user.value!);
        print('AuthController: User data saved: ${user.value?.username}');
      }
      
    } catch (e) {
      print('AuthController: Error handling successful login: $e');
      // Even if user info fetch fails, create a basic user so app doesn't break
      user.value = User(
        id: 0,
        username: emailLoginController.text.split('@')[0],
        email: emailLoginController.text.trim(),
      );
      await _authService.saveUserData(user.value!);
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

    if (emailSignUpController.text.trim().isNotEmpty &&
        !_isValidEmail(emailSignUpController.text.trim())) {
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

      if (userData['access_token'] != null) {
        // IMPROVED: Handle signup user creation
        if (userData['user'] != null) {
          user.value = User.fromJson(userData['user']);
        } else {
          user.value = User(
              id: 0, // Will be updated when we fetch from API
              username: usernameSignUpController.text.trim(),
              email: emailSignUpController.text.trim());
        }

        // Save user data
        await _authService.saveUserData(user.value!);

        // Clear form fields on successful signup
        usernameSignUpController.clear();
        emailSignUpController.clear();
        passwordSignUpController.clear();
        confirmSignUpPasswordController.clear();

        // Show success message
        CustomSnackbar.show(
            context: Get.context!,
            message:
                'Account created successfully! Welcome, ${user.value?.username ?? 'User'}!',
            type: SnackbarType.success);

        Get.offAllNamed(MyRoutes.bottomNav);
      }
    } catch (e) {
      // Extract clean error message
      String message = e.toString();
      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }

      errorMessage.value = message;

      // Also show snackbar for better UX
      CustomSnackbar.show(
          context: Get.context!,
          message: 'Registration Failed: $message',
          type: SnackbarType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      
      print('AuthController: Starting logout...');
      
      // Call logout on service
      await _authService.logout();
      
      // Clear local user data
      user.value = null;
      
      // Clear any stored error messages
      errorMessage.value = '';
      
      // Clear all user-related data from secure storage
      final secureStorage = SecureStorageService();
      await secureStorage.clearAllUserData();

      print('AuthController: Logout completed');

      // Show logout message
      CustomSnackbar.show(
          context: Get.context!,
          message: 'You have been successfully logged out',
          type: SnackbarType.info);
          
      // Navigate to login page
      Get.offAllNamed(MyRoutes.login);
      
    } catch (e) {
      print('AuthController: Error during logout: $e');
      
      // Even if logout fails, clear local data and navigate
      user.value = null;
      errorMessage.value = '';
      
      try {
        final secureStorage = SecureStorageService();
        await secureStorage.clearAllUserData();
      } catch (storageError) {
        print('AuthController: Error clearing storage: $storageError');
      }
      
      CustomSnackbar.show(
          context: Get.context!,
          message: 'Logged out with warnings. Please restart the app if needed.',
          type: SnackbarType.warning);
          
      Get.offAllNamed(MyRoutes.login);
      
    } finally {
      isLoading.value = false;
    }
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