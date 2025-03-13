import 'package:flutter/material.dart';
import 'package:function_mobile/modules/auth/services/auth_service.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // For login
  final TextEditingController usernameLoginController = TextEditingController();
  final TextEditingController passwordLoginController = TextEditingController();

  // For register
  final TextEditingController usernameSignUpController = TextEditingController();
  final TextEditingController emailSignUpController = TextEditingController();
  final TextEditingController passwordSignUpController = TextEditingController();
  final TextEditingController confirmSignUpPasswordController = TextEditingController();

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
    Get.toNamed('/login');
  }

  void goToSignup() {
    errorMessage.value = '';
    Get.toNamed('/signup');
  }

  Future<void> checkLoginStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        Get.offAllNamed(MyRoutes.home);
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
      await _authService.login(
        usernameLoginController.text.trim(),
        passwordLoginController.text,
      );
      Get.offAllNamed('/home');
    } catch (e) {
      String message = e.toString();
      if (message.contains('Exception:')) {
        message = message.split('Exception:')[1].trim();
      }
      
      // error message user-friendly
      if (message.contains('FormatException') || message.contains('Internal Server Error')) {
        message = 'The server is currently unavailable. Please try again later.';
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
      await _authService.signup(
        usernameSignUpController.text.trim(),
        passwordSignUpController.text,
      );
      Get.offAllNamed('/home');
    } catch (e) {
      String message = e.toString();
      if (message.contains('Exception:')) {
        message = message.split('Exception:')[1].trim();
      }
      
      // error message user-friendly
      if (message.contains('FormatException') || message.contains('Internal Server Error')) {
        message = 'The server is currently unavailable. Please try again later.';
      }
      
      errorMessage.value = message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      Get.offAllNamed('/login');
    } catch (e) {
      errorMessage.value = 'Error during logout: ${e.toString()}';
    }
  }
}