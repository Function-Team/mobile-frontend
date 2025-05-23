// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/common/widgets/inputs/auth_text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:function_mobile/common/widgets/buttons/outline_button.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Login', style: Theme.of(context).textTheme.displaySmall),
                SizedBox(height: 18),
                Obx(() => authController.errorMessage.isNotEmpty
                    ? Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authController.errorMessage.value,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox()),

                // Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email Address",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            )),
                    SizedBox(height: 8),
                    AuthTextField(
                      hintText: 'Enter your email',
                      isPassword: false,
                      controller: authController.emailLoginController,
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Password",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            )),
                    SizedBox(height: 8),
                    AuthTextField(
                        hintText: 'Enter your password',
                        isPassword: true,
                        controller: authController.passwordLoginController),
                  ],
                ),

                SizedBox(height: 24),

                // Login Button
                Obx(() => PrimaryButton(
                      width: double.infinity,
                      text: authController.isLoading.value
                          ? 'Signing in...'
                          : 'Sign In',
                      onPressed: authController.isLoading.value
                          ? null
                          : () {
                              // Clear error message when user tries to login
                              authController.clearErrorMessage();
                              authController.login();
                            },
                    )),

                SizedBox(height: 16),

                // Forgot Password Link
                TextButton(
                    onPressed: authController.goToForgotPassword,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    )),

                SizedBox(height: 20),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        authController.clearErrorMessage();
                        authController.goToSignup();
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey[400],
                        thickness: 1,
                        height: 20,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey[400],
                        thickness: 1,
                        height: 20,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Google Login Button
                OutlineButton(
                  text: "Continue with Google",
                  icon: FontAwesomeIcons.google,
                  useFaIcon: true,
                  onPressed: () {
                    // TODO: Implement Google login
                    CustomSnackbar.show(
                      message: 'Google login will be available soon',
                      context: Get.context!,
                      type: SnackbarType.info,
                    );
                  },
                ),

                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
