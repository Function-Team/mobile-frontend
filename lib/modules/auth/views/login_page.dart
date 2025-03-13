import 'package:flutter/material.dart';
import 'package:function_mobile/components/buttons/primary_button.dart';
import 'package:function_mobile/components/inputs/auth_text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:function_mobile/components/buttons/outline_button.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

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
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          authController.errorMessage.value,
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    : SizedBox()),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Username",
                        style: Theme.of(context).textTheme.bodyLarge),
                    SizedBox(height: 8),
                    AuthTextField(
                      hintText: 'Enter your username',
                      isPassword: false,
                      controller: authController.usernameLoginController,
                    ),
                  ],
                ),
                SizedBox(height: 18),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Password",
                      style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 8),
                  AuthTextField(
                      hintText: 'Enter your password',
                      isPassword: true,
                      controller: authController.passwordLoginController),
                ]),
                SizedBox(height: 18),
                Obx(() => PrimaryButton(
                      text: authController.isLoading.value
                          ? 'Logging in...'
                          : 'Login',
                      onPressed: authController.isLoading.value
                          ? null
                          : () {
                              authController.login();
                            },
                    )),
                SizedBox(height: 18),
                TextButton(
                    onPressed: () {}, child: const Text('Forgot Password?')),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?",
                        style: TextStyle(fontSize: 16)),
                    TextButton(
                      onPressed: () => authController.goToSignup(),
                      child: const Text(
                        'Signup',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey[400],
                        thickness: 2,
                        height: 40,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Or Login With',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey[400],
                        thickness: 2,
                        height: 40,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18),
                OutlineButton(
                  text: "Login dengan Google",
                  icon: FontAwesomeIcons.google,
                  useFaIcon: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}