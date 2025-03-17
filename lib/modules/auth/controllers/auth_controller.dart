import 'package:flutter/material.dart';
import 'package:function_mobile/modules/auth/models/auth_model.dart';
import 'package:function_mobile/modules/auth/services/auth_service.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  //untuk login
  final TextEditingController emailLoginController = TextEditingController();
  final TextEditingController passwordLoginController = TextEditingController();

  //untuk register
  final TextEditingController emailRegisterController = TextEditingController();
  final TextEditingController usernameRegisterController =
      TextEditingController();
  final TextEditingController passwordRegisterController =
      TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  @override
  void onClose() {
    emailLoginController.dispose();
    passwordLoginController.dispose();
    emailRegisterController.dispose();
    usernameRegisterController.dispose();
    passwordRegisterController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  //check apakah user sudah login saat buka aplikasi
  Future<void> checkLoginStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      Get.offAllNamed(MyRoutes.home);
    }
  }

  Future<void> login() async{
    try{
   // Reset error message
      errorMessage.value = '';
      
      // Validasi input
      if (emailLoginController.text.isEmpty || passwordLoginController.text.isEmpty) {
        errorMessage.value = 'Please fill in all fields';
        return;
      }
      
      // Set loading state
      isLoading.value = true;
      
      // Buat request
      final request = LoginRequest(
        email: emailLoginController.text.trim(),
        password: passwordLoginController.text,
      );
      
      // Panggil service
      final response = await _authService.login(request);
      
      // Handle response
      if (response.success && response.user != null) {
        user.value = response.user;
        Get.offAllNamed(MyRoutes.home);
        Get.snackbar(
          'Success',
          'Login successful',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
      Get.snackbar(
        'Error',
        'An error occurred during login',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

   Future<void> register() async {
    try {
      // Reset error message
      errorMessage.value = '';
      
      // Validasi input
      if (emailRegisterController.text.isEmpty ||
          usernameRegisterController.text.isEmpty ||
          passwordRegisterController.text.isEmpty ||
          confirmPasswordController.text.isEmpty) {
        errorMessage.value = 'Please fill in all fields';
        return;
      }
      
      // Validasi password match
      if (passwordRegisterController.text != confirmPasswordController.text) {
        errorMessage.value = 'Passwords do not match';
        return;
      }
      
      // Set loading state
      isLoading.value = true;
      
      // Buat request
      final request = RegisterRequest(
        email: emailRegisterController.text.trim(),
        username: usernameRegisterController.text.trim(),
        password: passwordRegisterController.text,
      );
      
      // Panggil service
      final response = await _authService.register(request);
      
      // Handle response
      if (response.success && response.user != null) {
        user.value = response.user;
        Get.offAllNamed(MyRoutes.home);
        Get.snackbar(
          'Success',
          'Registration successful',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        errorMessage.value = response.message;
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
      Get.snackbar(
        'Error',
        'An error occurred during registration',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      user.value = null;
      Get.offAllNamed(MyRoutes.login);
      Get.snackbar(
        'Success',
        'Logout successful',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred during logout',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void goToSignup() {
    // Reset controllers
    emailRegisterController.clear();
    usernameRegisterController.clear();
    passwordRegisterController.clear();
    confirmPasswordController.clear();
    
    Get.toNamed(MyRoutes.signup);
  }

  void goToLogin() {
    // Reset controllers
    emailLoginController.clear();
    passwordLoginController.clear();
    
    Get.toNamed(MyRoutes.login);
  }
}
