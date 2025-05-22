import 'dart:convert';
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
  final RxBool isLoggedIn = false.obs; // Add this for better state tracking

  // For login
  final TextEditingController emailLoginController = TextEditingController();
  final TextEditingController passwordLoginController = TextEditingController();

  // For register
  final TextEditingController usernameSignUpController = TextEditingController();
  final TextEditingController emailSignUpController = TextEditingController();
  final TextEditingController passwordSignUpController = TextEditingController();
  final TextEditingController confirmSignUpPasswordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Check login status immediately when controller is initialized
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
    errorMessage.value = '';
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
      print("Checking login status...");
      
      // Check if we have a token
      final hasToken = await _authService.isLoggedIn();
      
      if (hasToken) {
        print("Token found, loading user data...");
        
        // Try to load user from local storage first
        User? localUser = await _authService.getUserData();
        
        if (localUser != null) {
          user.value = localUser;
          isLoggedIn.value = true;
          print("User loaded from storage: ${user.value?.username}");
        }

        // Try to refresh from API (but don't fail if this doesn't work)
        try {
          final userData = await _authService.fetchProtectedData('/user/me');
          if (userData != null) {
            final refreshedUser = User.fromJson(userData);
            user.value = refreshedUser;
            await _authService.saveUserData(refreshedUser);
            isLoggedIn.value = true;
            print("User data refreshed from API: ${user.value?.username}");
          }
        } catch (e) {
          print('Could not refresh user data from API: $e');
          // If we have local user data, that's fine
          if (localUser != null) {
            print("Using cached user data");
          } else {
            // If no local data and API failed, consider not logged in
            await logout();
            return;
          }
        }

        // Navigate to main app if we have user data
        if (user.value != null) {
          Get.offAllNamed(MyRoutes.bottomNav);
        }
      } else {
        print("No token found, user not logged in");
        isLoggedIn.value = false;
        user.value = null;
      }
    } catch (e) {
      print('Error checking login status: $e');
      isLoggedIn.value = false;
      user.value = null;
    }
  }

  Future<void> login() async {
    if (emailLoginController.text.isEmpty) {
      errorMessage.value = 'Email cannot be empty';
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
        emailLoginController.text.trim(),
        passwordLoginController.text,
      );

      if (userData['access_token'] != null) {
        // Fetch user info from API
        final userInfo = await _authService.fetchProtectedData('/user/me');
        if (userInfo != null) {
          user.value = User.fromJson(userInfo);
          await _authService.saveUserData(user.value!);
          isLoggedIn.value = true;
          
          print("Login successful: ${user.value?.username}");
          Get.offAllNamed(MyRoutes.bottomNav);
        }
      }
    } catch (e) {
      String message = e.toString();
      if (message.contains('Exception:')) {
        message = message.split('Exception:')[1].trim();
      }

      if (message.contains('FormatException') ||
          message.contains('Internal Server Error')) {
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
        emailSignUpController.text.trim(),
      );

      if (userData['access_token'] != null) {
        // Try to get user data, or create from signup info
        try {
          final userInfo = await _authService.fetchProtectedData('/user/me');
          user.value = User.fromJson(userInfo);
        } catch (e) {
          // If API call fails, create user from signup data
          user.value = User(
            id: -1,
            username: usernameSignUpController.text.trim(),
            email: emailSignUpController.text.trim(),
          );
        }
        
        await _authService.saveUserData(user.value!);
        isLoggedIn.value = true;
        
        Get.offAllNamed(MyRoutes.bottomNav);
      }
    } catch (e) {
      String message = e.toString();
      if (message.contains('Exception:')) {
        message = message.split('Exception:')[1].trim();
      }

      if (message.contains('FormatException') ||
          message.contains('Internal Server Error')) {
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
      user.value = null;
      isLoggedIn.value = false;
      print("Logout completed");
      Get.offAllNamed(MyRoutes.login);
    } catch (e) {
      errorMessage.value = 'Error during logout: ${e.toString()}';
    }
  }

  String get username {
    if (user.value?.username != null && user.value!.username.isNotEmpty) {
      return user.value!.username;
    } else if (user.value?.email != null) {
      return user.value!.email.split('@')[0];
    }
    return 'Guest';
  }

  // Method to refresh user session
  Future<void> refreshSession() async {
    if (isLoggedIn.value) {
      try {
        final userData = await _authService.fetchProtectedData('/user/me');
        if (userData != null) {
          user.value = User.fromJson(userData);
          await _authService.saveUserData(user.value!);
        }
      } catch (e) {
        print('Could not refresh session: $e');
        // Don't logout on refresh failure, just log the error
      }
    }
  }
}