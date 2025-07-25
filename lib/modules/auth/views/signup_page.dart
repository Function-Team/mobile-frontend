import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/outline_button.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () {
              authController.clearErrorMessage();
              authController.goToLogin();
            }),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Username Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Username",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            )),
                    SizedBox(height: 8),
                    Obx(() => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: authController
                                        .usernameSignUpError.isNotEmpty
                                    ? Colors.red
                                    : Colors.grey[300]!),
                            color: Colors.grey[50],
                          ),
                          child: TextField(
                            controller: authController.usernameSignUpController,
                            onChanged:
                                authController.validateUsernameSignUpField,
                            decoration: InputDecoration(
                              hintText: 'Enter your username',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                              prefixIcon: Container(
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  Icons.person_outline,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        )),
                    Obx(() => authController.usernameSignUpError.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              authController.usernameSignUpError.value,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : SizedBox.shrink()),
                  ],
                ),

                SizedBox(height: 20),

                // Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email (Optional)",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            )),
                    SizedBox(height: 8),
                    Obx(() => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color:
                                    authController.emailSignUpError.isNotEmpty
                                        ? Colors.red
                                        : Colors.grey[300]!),
                            color: Colors.grey[50],
                          ),
                          child: TextField(
                            controller: authController.emailSignUpController,
                            onChanged: authController.validateEmailSignUpField,
                            decoration: InputDecoration(
                              hintText: 'Enter your email',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                              prefixIcon: Container(
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  Icons.email_outlined,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        )),
                    Obx(() => authController.emailSignUpError.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              authController.emailSignUpError.value,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : SizedBox.shrink()),
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
                    Obx(() => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: authController
                                        .passwordSignUpError.isNotEmpty
                                    ? Colors.red
                                    : Colors.grey[300]!),
                            color: Colors.grey[50],
                          ),
                          child: TextField(
                            controller: authController.passwordSignUpController,
                            obscureText:
                                authController.obscureSignUpPassword.value,
                            onChanged:
                                authController.validatePasswordSignUpField,
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                              prefixIcon: Container(
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  Icons.lock_outline,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                              ),
                              suffixIcon: GestureDetector(
                                onTap: authController
                                    .toggleSignUpPasswordVisibility,
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(
                                    authController.obscureSignUpPassword.value
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        )),
                    Obx(() => authController.passwordSignUpError.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              authController.passwordSignUpError.value,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : SizedBox.shrink()),
                  ],
                ),

                SizedBox(height: 20),

                // Confirm Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Confirm Password",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            )),
                    SizedBox(height: 8),
                    Obx(() => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: authController
                                        .confirmPasswordSignUpError.isNotEmpty
                                    ? Colors.red
                                    : Colors.grey[300]!),
                            color: Colors.grey[50],
                          ),
                          child: TextField(
                            controller:
                                authController.confirmSignUpPasswordController,
                            obscureText: authController
                                .obscureSignUpConfirmPassword.value,
                            onChanged: authController
                                .validateConfirmPasswordSignUpField,
                            decoration: InputDecoration(
                              hintText: 'Confirm your password',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                              prefixIcon: Container(
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  Icons.lock_outline,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                              ),
                              suffixIcon: GestureDetector(
                                onTap: authController
                                    .toggleSignUpConfirmPasswordVisibility,
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(
                                    authController
                                            .obscureSignUpConfirmPassword.value
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        )),
                    Obx(() => authController
                            .confirmPasswordSignUpError.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              authController.confirmPasswordSignUpError.value,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : SizedBox.shrink()),
                  ],
                ),

                SizedBox(height: 30),

                // Sign Up Button
                Obx(() => PrimaryButton(
                  isLoading: authController.isLoading.value,
                      // Set the width to double.infinity to fill the parent widget,
                      width: double.infinity,
                      text: authController.isLoading.value
                          ? 'Creating Account...'
                          : 'Sign Up',
                      onPressed: authController.isLoading.value
                          ? null
                          : () {
                              authController.clearErrorMessage();
                              authController.signup();
                            },
                    )),

                SizedBox(height: 20),

                // Terms and Privacy
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text.rich(
                    TextSpan(
                      text: 'By signing up, you agree to our ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              authController.goToTermsOfService();
                            },
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              authController.goToPrivacyPolicy();
                            },
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 20),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        authController.clearErrorMessage();
                        authController.goToLogin();
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
