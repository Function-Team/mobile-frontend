import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;

  const AuthTextField({
    required this.hintText,
    this.isPassword = false,
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final PasswordController passwordController = Get.put(PasswordController());

    return TextField(
      controller: controller,
      obscureText: isPassword ? passwordController.isObscured.value : false,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 16,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
        suffixIcon: isPassword
            ? Obx(
                () => IconButton(
                  icon: Icon(
                    passwordController.isObscured.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    passwordController.toggleVisibility();
                  },
                ),
              )
            : null,
      ),
    );
  }
}

// Controller GetX untuk mengelola state password
class PasswordController extends GetxController {
  var isObscured = true.obs;

  void toggleVisibility() {
    isObscured.value = !isObscured.value;
  }
}
