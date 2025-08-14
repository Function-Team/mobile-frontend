import 'package:flutter/material.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationHelper.tr(LocaleKeys.auth_forgotPassword)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              LocalizationHelper.tr(LocaleKeys.auth_resetPassword),
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Enter your email address and we will send you instructions to reset your password.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: authController.resetEmailController,
              decoration: InputDecoration(
                labelText: LocalizationHelper.tr(LocaleKeys.auth_email),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
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
                      : () => authController.requestPasswordReset(),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: authController.isLoading.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Send Reset Link',
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
