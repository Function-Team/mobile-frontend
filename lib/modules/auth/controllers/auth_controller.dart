import 'package:flutter/material.dart';
import 'package:function_mobile/modules/auth/models/auth_model.dart';
import 'package:function_mobile/modules/auth/services/auth_service.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<User?> user = Rx<User?>(null);

  // For login
  final TextEditingController usernameLoginController = TextEditingController();
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
    usernameLoginController.dispose();
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
        try {
          final userData =
              await _authService.fetchProtectedData('/api/user/me');
          if (userData != null) {
            user.value = User.fromJson(userData);
          }
        } catch (e) {
          print('Error getting user data: $e');
        }
        Get.offAllNamed(MyRoutes.bottomNav);
      }
    } catch (e) {
      print('Error checking login status: $e');
    }
  }

  Future<void> login() async {
    if (usernameLoginController.text.isEmpty) {
      errorMessage.value = 'Username cannot be empty';
      return;
    }

    if (passwordLoginController.text.isEmpty) {
      errorMessage.value = 'Password cannot be empty';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userData = await _authService.login(
        usernameLoginController.text.trim(),
        passwordLoginController.text,
      );

      if (userData['access_token'] != null) {
        if (userData['user'] != null) {
          user.value = User.fromJson(userData['user']);
        } else {
          user.value = User(
              id: 'temp_id',
              username: usernameLoginController.text.trim(),
              email: '');
        }
      }
      Get.offAllNamed(MyRoutes.bottomNav);
    } catch (e) {
      String message = e.toString();
      if (message.contains('Exception:')) {
        message = message.split('Exception:')[1].trim();
      }

      if (message.contains('FormatException') ||
          message.contains('Internal Server Error')) {
        message =
            'The server is currently unavailable. Please try again later.';
      }

      errorMessage.value = message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup() async {
    if (usernameSignUpController.text.isEmpty) {
      errorMessage.value = 'Username cannot be empty';
      return;
    }

    if (passwordSignUpController.text.isEmpty) {
      errorMessage.value = 'Password cannot be empty';
      return;
    }

    if (passwordSignUpController.text != confirmSignUpPasswordController.text) {
      errorMessage.value = 'Passwords do not match';
      return;
    }

    // Additional validation
    if (passwordSignUpController.text.length < 6) {
      errorMessage.value = 'Password must be at least 6 characters';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userData = await _authService.signup(
        usernameSignUpController.text.trim(),
        passwordSignUpController.text,
      );

      if (userData['access_token'] != null) {
        if (userData['user'] != null) {
          user.value = User.fromJson(userData['user']);
        } else {
          user.value = User(
              id: 'temp_id',
              username: usernameSignUpController.text.trim(),
              email: emailSignUpController.text.trim());
        }
      }
      Get.offAllNamed(MyRoutes.bottomNav);
    } catch (e) {
      String message = e.toString();
      if (message.contains('Exception:')) {
        message = message.split('Exception:')[1].trim();
      }

      if (message.contains('FormatException') ||
          message.contains('Internal Server Error')) {
        message =
            'The server is currently unavailable. Please try again later.';
      }

      errorMessage.value = message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      user.value = null;
      Get.offAllNamed(MyRoutes.login);
    } catch (e) {
      errorMessage.value = 'Error during logout: ${e.toString()}';
    }
  }

  String get username => user.value?.username ?? 'Guest';
}
