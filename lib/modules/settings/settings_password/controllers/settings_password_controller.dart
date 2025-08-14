import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';

class SettingsPasswordController extends GetxController {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final RxBool _isCurrentPasswordVisible = false.obs;
  final RxBool _isNewPasswordVisible = false.obs;
  final RxBool _isConfirmPasswordVisible = false.obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _successMessage = ''.obs;

  // Getters
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get currentPasswordController =>
      _currentPasswordController;
  TextEditingController get newPasswordController => _newPasswordController;
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;

  RxBool get isCurrentPasswordVisible => _isCurrentPasswordVisible;
  RxBool get isNewPasswordVisible => _isNewPasswordVisible;
  RxBool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  RxBool get isLoading => _isLoading;
  RxString get errorMessage => _errorMessage;
  RxString get successMessage => _successMessage;

  @override
  void onClose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleCurrentPasswordVisibility() {
    _isCurrentPasswordVisible.toggle();
  }

  void toggleNewPasswordVisibility() {
    _isNewPasswordVisible.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible.toggle();
  }

  void clearMessages() {
    _errorMessage.value = '';
    _successMessage.value = '';
  }

  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your current password';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    clearMessages();
    _isLoading.value = true;

    try {
      final AuthController authController = Get.find();

      // Call the request password change method from auth controller
      await authController.requestPasswordChange(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      _successMessage.value =
          'Verification email sent! Please check your email to confirm the password change.';

      // Clear form after successful request
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      // Show success snackbar
      Get.snackbar(
        'Email Sent',
        'Please check your email to verify the password change.',
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade800,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }
}
