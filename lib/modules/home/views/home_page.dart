import 'package:flutter/material.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Column(
            children: [
              Text('Home', style: Theme.of(context).textTheme.displaySmall),
              SizedBox(height: 18),
              ElevatedButton(
                onPressed: () {
                  authController.logout();
                },
                child: Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
