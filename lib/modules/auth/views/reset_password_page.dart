import 'package:flutter/material.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:function_mobile/modules/auth/services/auth_service.dart';
import 'package:get/get.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final AuthController authController = Get.find<AuthController>();
  final AuthService _authService = AuthService();
  final String token = Get.parameters['token'] ?? '';
  bool isValidToken = false;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    verifyToken();
  }

  Future<void> verifyToken() async {
    try {
      final valid = await _authService.verifyResetToken(token);
      setState(() {
        isValidToken = valid;
        isLoading = false;
        if (!valid) {
          errorMessage =
              'Invalid or expired token. Please request a new password reset link.';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isValidToken = false;
        errorMessage = 'Failed to verify token. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationHelper.tr(LocaleKeys.auth_resetPassword)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : !isValidToken
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Get.offAllNamed('/login'),
                          child: Text(LocalizationHelper.tr('buttons.backToLogin')),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Create New Password',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Your new password must be different from previous used passwords.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 40),
                      TextField(
                        controller: authController.newPasswordController,
                        decoration: InputDecoration(
                          labelText: LocalizationHelper.tr(
                              LocaleKeys.auth_newPassword),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: authController.confirmNewPasswordController,
                        decoration: InputDecoration(
                          labelText: LocalizationHelper.tr('forms.confirmNewPassword'),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      Obx(() => authController.errorMessage.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text(
                                authController.errorMessage.value,
                                style: TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : SizedBox.shrink()),
                      Obx(() => ElevatedButton(
                            onPressed: authController.isLoading.value
                                ? null
                                : () => authController.resetPassword(token),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: authController.isLoading.value
                                  ? CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text(
                                      'Reset Password',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          )),
                    ],
                  ),
      ),
    );
  }
}
