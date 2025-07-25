import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/buttons/primary_button.dart';
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
                SizedBox(height: 60),
                Container(
                  margin: EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.asset(
                          'assets/images/function_auth.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF2196F3),
                                    Color(0xFF1976D2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.business,
                                color: Colors.white,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            )),
                    SizedBox(height: 8),
                    Obx(() => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: authController.emailLoginError.isNotEmpty
                                    ? Colors.red
                                    : Colors.grey[300]!),
                            color: Colors.grey[50],
                          ),
                          child: TextField(
                            controller: authController.emailLoginController,
                            onChanged: authController.validateEmailLoginField,
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
                    Obx(() => authController.emailLoginError.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              authController.emailLoginError.value,
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
                                color: authController.passwordLoginError.isNotEmpty
                                    ? Colors.red
                                    : Colors.grey[300]!),
                            color: Colors.grey[50],
                          ),
                          child: TextField(
                            controller: authController.passwordLoginController,
                            obscureText: authController.obscureLoginPassword.value,
                            onChanged: authController.validatePasswordLoginField,
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
                                onTap: authController.toggleLoginPasswordVisibility,
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(
                                    authController.obscureLoginPassword.value
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
                    Obx(() => authController.passwordLoginError.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              authController.passwordLoginError.value,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : SizedBox.shrink()),
                  ],
                ),

                SizedBox(height: 12),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: authController.goToForgotPassword,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 14),

                // Login Button
                Obx(
                  () => PrimaryButton(
                    isLoading: authController.isLoading.value,
                    width: double.infinity,
                    text: authController.isLoading.value
                        ? 'Logging in...'
                        : 'Login',
                    onPressed: authController.isLoading.value
                        ? null
                        : () {
                            authController.clearErrorMessage();
                            authController.login();
                          },
                  ),
                ),
                SizedBox(height: 10),
                Text("or",
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
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

                SizedBox(height: 10),

                // Footer links
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: authController.goToTermsOfService,
                      child: Text(
                        'Terms and Conditions',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      ' | ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: authController.goToPrivacyPolicy,
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
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
