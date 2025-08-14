import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:function_mobile/modules/profile/services/profile_service.dart';
import 'package:function_mobile/modules/profile/controllers/profile_controller.dart';

class EditProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();
  final AuthController _authController = Get.find<AuthController>();

  // Form controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Form validation errors
  final RxString usernameError = ''.obs;
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;

  // Track if email change is pending
  final RxBool emailChangePending = false.obs;
  final RxString pendingEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeForm();
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    super.onClose();
  }

  void _initializeForm() {
    // Populate form with current user data
    final currentUser = _authController.user.value;
    if (currentUser != null) {
      usernameController.text = currentUser.username;
      emailController.text = currentUser.email;
    }
  }

  // ===== VALIDATION METHODS =====
  String? validateUsername(String username) {
    if (username.isEmpty) {
      return 'Username cannot be empty';
    }
    if (username.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    if (username.length > 30) {
      return 'Username must be less than 30 characters';
    }
    // Check if username contains only valid characters
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email cannot be empty';
    }
    if (!GetUtils.isEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validateCurrentPassword(String password) {
    if (password.isEmpty) {
      return 'Current password is required to save changes';
    }
    return null;
  }

  bool validateForm() {
    final usernameValidation = validateUsername(usernameController.text.trim());
    // Skip email validation since it's read-only
    final passwordValidation =
        validateCurrentPassword(currentPasswordController.text);

    usernameError.value = usernameValidation ?? '';
    // Clear any email errors since the field is read-only
    emailError.value = '';
    passwordError.value = passwordValidation ?? '';

    return usernameValidation == null && passwordValidation == null;
  }

  // ===== FIELD VALIDATION CALLBACKS =====
  void validateUsernameField(String value) {
    usernameError.value = validateUsername(value.trim()) ?? '';
  }

  void validateEmailField(String value) {
    // Email field is read-only, so no validation needed
    emailError.value = '';
  }

  void validatePasswordField(String value) {
    passwordError.value = validateCurrentPassword(value) ?? '';
  }

  // ===== UI ACTIONS =====
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  // ===== MAIN ACTIONS =====
  Future<void> saveProfile() async {
    if (!validateForm()) {
      errorMessage.value = 'Please fill in all required fields';

      return;
    }

    final currentUser = _authController.user.value;
    if (currentUser == null) {
      errorMessage.value = 'User not found. Please login again.';
      return;
    }

    // Check if any changes were made
    final newUsername = usernameController.text.trim();
    // Email is now read-only, so we don't need to check for changes

    if (newUsername == currentUser.username) {
      errorMessage.value = 'No changes detected';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      print('EditProfileController: Saving profile changes...');

      final response = await _profileService.editProfile(
        currentPassword: currentPasswordController.text,
        username: newUsername != currentUser.username ? newUsername : null,
        email: null,
      );

      if (response['success'] == true) {
        // Handle successful update
        final message = response['message'] ?? 'Profile updated successfully';
        final emailChangeRequired = response['email_change_required'] ?? false;

        if (emailChangeRequired) {
          // Email change requires confirmation
          emailChangePending.value = true;
          // pendingEmail.value = newEmail;
          successMessage.value = message;

          // Show dialog about email confirmation
          _showEmailConfirmationDialog();
        } else {
          // Profile updated successfully without email change
          successMessage.value = message;

          // Update local user data if username changed
          if (newUsername != currentUser.username) {
            await _authController.refreshUserData();
          }

          // Refresh profile controller if it exists
          try {
            final ProfileController? profileController =
                Get.find<ProfileController>();
            if (profileController != null) {
              await profileController.refreshProfile();
            }
          } catch (e) {
            print(
                'EditProfileController: ProfileController not found, skipping refresh');
          }

          // Clear password field for security
          currentPasswordController.clear();

          // Show success and go back
          CustomSnackbar.show(
              context: Get.context!,
              message: message,
              type: SnackbarType.success);

          // Go back after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
          });
        }
      } else {
        errorMessage.value = response['message'] ?? 'Failed to update profile';
      }
    } catch (e) {
      print('EditProfileController: Error saving profile: $e');
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void _showEmailConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Email Confirmation Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A confirmation email has been sent to:'),
            const SizedBox(height: 8),
            Text(
              pendingEmail.value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please check your email and click the confirmation link to complete the email change.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to profile page
            },
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ===== HELPER METHODS =====
  bool get hasChanges {
    final currentUser = _authController.user.value;
    if (currentUser == null) return false;

    return usernameController.text.trim() != currentUser.username ||
        emailController.text.trim() != currentUser.email;
  }

  void resetForm() {
    _initializeForm();
    currentPasswordController.clear();
    clearMessages();
    usernameError.value = '';
    emailError.value = '';
    passwordError.value = '';
    emailChangePending.value = false;
    pendingEmail.value = '';
  }
}
