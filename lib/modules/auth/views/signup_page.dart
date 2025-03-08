import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:function_mobile/components/buttons/outline_button.dart';
import 'package:function_mobile/components/buttons/primary_button.dart';
import 'package:function_mobile/components/inputs/custom_text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Signup', style: Theme.of(context).textTheme.displaySmall),
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
                    CustomTextField(
                      hintText: 'Enter your username',
                      isPassword: false,
                      controller: authController.emailLoginController,
                    ),
                  ],
                ),
                SizedBox(height: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email", style: Theme.of(context).textTheme.bodyLarge),
                    SizedBox(height: 8),
                    CustomTextField(
                      hintText: 'Enter your email',
                      isPassword: false,
                      controller: authController.emailLoginController,
                    ),
                  ],
                ),
                SizedBox(height: 18),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Password",
                      style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 8),
                  CustomTextField(
                      hintText: 'Enter your password',
                      isPassword: true,
                      controller: authController.passwordLoginController),
                ]),
                SizedBox(height: 18),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Confirm Password",
                      style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 8),
                  CustomTextField(
                      hintText: 'Confirm your password',
                      isPassword: true,
                      controller: authController.passwordLoginController),
                ]),
                SizedBox(height: 18),
                Obx(() => PrimaryButton(
                      text: authController.isLoading.value
                          ? 'Signing up...'
                          : 'Signup',
                      onPressed: authController.isLoading.value
                          ? null
                          : () {
                              authController.login();
                            },
                    )),
                SizedBox(height: 18),
                Text.rich(
                  TextSpan(
                    text: 'By signing up, you agree to our ',
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.toNamed('/termsOfService');
                          },
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.toNamed('/privacyPolicy');
                          },
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?",
                        style: Theme.of(context).textTheme.bodyLarge),
                    TextButton(
                      onPressed: () => authController.goToLogin(),
                      child: Text(
                        'Login',
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
                      child: Text('Or Signup With',
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
                  text: "Signup dengan Google",
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
