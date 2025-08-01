import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:function_mobile/common/bindings/app_binding.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/firebase_options.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/core/services/notification_service.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize services
  Get.put(ApiService());
  LocalizationHelper.debugLocalization;
  Get.put(NotificationService());

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('id'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      saveLocale: true,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,

      // automatically rebuilds when locale changes
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      initialRoute: MyRoutes.splash,
      initialBinding: AppBinding(),
      getPages: MyRoutes.pages,
      key: ValueKey(context.locale.toString()),
    );
  }
}
