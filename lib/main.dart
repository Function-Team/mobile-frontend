import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:function_mobile/modules/auth/bindings/auth_binding.dart';
import 'package:function_mobile/modules/venue/views/venue_detail_page.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/theme/app_theme.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  debugPaintSizeEnabled = false;
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
      home: VenueDetailPage(),
      initialRoute: MyRoutes.detailVenue,
      initialBinding: AuthBinding(),
      getPages: MyRoutes.pages,
    );
  }
}
