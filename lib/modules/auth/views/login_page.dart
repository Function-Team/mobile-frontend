import 'package:flutter/material.dart';
import 'package:function_mobile/components/buttons/primary_button.dart';
import 'package:function_mobile/components/inputs/custom_text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:function_mobile/components/buttons/outline_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Login', style: Theme.of(context).textTheme.displaySmall),
                SizedBox(height: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email/Username",
                        style: Theme.of(context).textTheme.bodyLarge),
                    SizedBox(height: 8),
                    CustomTextField(
                      hintText: 'Enter your email or username',
                      isPassword: false,
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
                  ),
                ]),
                SizedBox(height: 18),
                PrimaryButton(text: 'Login', onPressed: () {}),
                SizedBox(height: 18),
                TextButton(
                    onPressed: () {}, child: const Text('Forgot Password?')),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?",
                        style: TextStyle(fontSize: 16)),
                    TextButton(
                        onPressed: () {},
                        child: const Text('Signup',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ))),
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
