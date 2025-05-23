import 'dart:convert';

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

  Future<void> checkLoginStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        // Pertama coba dapatkan data user dari local storage
        User? localUser = await _authService.getUserData();

        if (localUser != null) {
          user.value = localUser;
          print("User loaded from storage: ${user.value?.username}");
        }

        // Kemudian coba refresh dari API
        try {
          final userData = await _authService.fetchProtectedData('/user/me');
          if (userData != null) {
            user.value = User.fromJson(userData);
            await _authService.saveUserData(user.value!);
            print("User refreshed from API: ${user.value?.username}");
          }
        } catch (e) {
          print('Error refreshing user data: $e');
          // Tetap menggunakan data user lokal yang telah dimuat
        }

        Get.offAllNamed(MyRoutes.bottomNav);
      }
    } catch (e) {
      print('Error checking login status: $e');
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

      if (userData['access_token'] != null) {
        // Langsung fetch user info dari API
        final userInfo = await _authService.fetchProtectedData('/user/me');
        if (userInfo != null) {
          user.value = User.fromJson(userInfo);
          await _authService.saveUserData(user.value!);
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
        if (userData['user'] != null) {
          user.value = User.fromJson(userData['user']);
        } else {
          user.value = User(
              id: -1,
              username: usernameSignUpController.text.trim(),
              email: emailSignUpController.text.trim());
        }

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
      await _authService.logout();
      user.value = null;
      // Clear any stored error messages
      errorMessage.value = '';
      final secureStorage = SecureStorageService();
      await secureStorage.clearAllUserData();
      // Show logout message
      CustomSnackbar.show(
          context: Get.context!,
          message: 'You have been successfully logged out',
          type: SnackbarType.success);
      Get.offAllNamed(MyRoutes.login);
    } catch (e) {
      errorMessage.value = 'Error during logout. Please try again.';
      CustomSnackbar.show(
          context: Get.context!,
          message: 'Logout Failed: $e',
          type: SnackbarType.error);
    } finally {
      isLoading.value = false;
    }
  }

  String get username {
    if (user.value?.username != null && user.value!.username.isNotEmpty) {
      return user.value!.username;
    } else if (user.value?.email != null) {
      return user.value!.email.split('@')[0]; // Extract username from email
    }
    return 'Guest';
  }
}
