import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:function_mobile/common/bindings/app_binding.dart'; // New AppBinding
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:get/get.dart';

Future main() async {
  await dotenv.load(fileName: '.env');
  // Disable debug paint
  debugPaintSizeEnabled = false;
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Run the app
  runApp(const MainApp());
  Get.put(ApiService());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      initialRoute: MyRoutes.login,
      initialBinding: AppBinding(),
      getPages: MyRoutes.pages,
    );
  }
}
