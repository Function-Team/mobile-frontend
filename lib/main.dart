import 'package:flutter/material.dart';
import 'package:function_mobile/modules/auth/bindings/auth_binding.dart';
import 'package:function_mobile/modules/auth/views/login_page.dart';
import 'package:function_mobile/routes/routes.dart';
import 'package:function_mobile/theme/theme_data.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: LoginPage(),
      initialRoute: MyRoutes.login,
      initialBinding: AuthBinding(),
      getPages: MyRoutes.pages,
    );
  }
}
