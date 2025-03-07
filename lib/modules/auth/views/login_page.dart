import 'package:flutter/material.dart';
import 'package:function_mobile/components/buttons/primary_button.dart';
import 'package:function_mobile/components/inputs/custom_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 18),
            Column(
              children: [
                Text("Email/Username",
                    style: Theme.of(context).textTheme.bodyMedium),
                SizedBox(height: 18),
                CustomTextField(
                  hintText: 'Enter your email or username',
                  isPassword: false,
                ),
              ],
            ),
            SizedBox(height: 18),
            Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Text("Password", style: Theme.of(context).textTheme.bodyMedium),
              CustomTextField(
                hintText: 'Enter your password',
                isPassword: true,
              ),
            ]),
            SizedBox(height: 18),
            PrimaryButton(text: 'Login', onPressed: () {}),
          ],
        ),
      ),
    ));
  }
}
