import 'package:flutter/material.dart';
import 'package:function_mobile/modules/auth/views/login_page.dart';
import 'package:function_mobile/theme/theme_data.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: LoginPage(),
    );
  }
}
