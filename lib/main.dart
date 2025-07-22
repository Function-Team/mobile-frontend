import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:function_mobile/common/bindings/app_binding.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:function_mobile/modules/payment/services/payment_service.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');
  debugPaintSizeEnabled = false;
  Get.put(ApiService());
  // PaymentService.initializeMidtrans(
  //   clientKey: 'SB-Mid-client-xDq_e8A2BNHKg_je',
  //   merchantId: 'G796043912',
  //   enableLog: true,
  // );

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
