import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:function_mobile/common/bindings/app_binding.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/theme/app_theme.dart';
import 'package:function_mobile/core/constants/app_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:get/get.dart';

Future main() async {
  // Ensure Flutter is initialized before anything else
  WidgetsFlutterBinding.ensureInitialized();

  // Validate translation files first to detect issues early
  await _validateTranslationFiles();

  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  // Set up Flutter error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    print('Flutter Error: ${details.exception}');
    print('Stack: ${details.stack}');
  };

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Disable debug paint
  debugPaintSizeEnabled = false;

  // Initialize services
  Get.put(ApiService());

  // Run the app inside EasyLocalization
  runApp(
    EasyLocalization(
      supportedLocales: AppConstants.supportedLocales,
      path: 'assets/translations', // Path to your translation files
      fallbackLocale: const Locale('en', 'US'),
      useOnlyLangCode: false, // Use full locale with country code
      useFallbackTranslations:
          true, // Use fallback translations if key is missing
      saveLocale: true, // Save selected locale to device
      child: const MyApp(),
    ),
  );
}

// Helper method to validate translation files early
Future<void> _validateTranslationFiles() async {
  try {
    print("🔍 Validating translation files...");

    // Check if files exist
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final enUsExists =
        manifestContent.contains('assets/translations/en-US.json');
    final idIdExists =
        manifestContent.contains('assets/translations/id-ID.json');

    print("Translation files validation results:");
    print("- en-US.json exists: $enUsExists");
    print("- id-ID.json exists: $idIdExists");

    if (!enUsExists || !idIdExists) {
      print("⚠️ WARNING: One or more translation files not found!");
      print("Make sure you have the following files:");
      print("- assets/translations/en-US.json");
      print("- assets/translations/id-ID.json");
      print("And they are included in pubspec.yaml assets section.");
    }
  } catch (e) {
    print("⚠️ Error validating translation files: $e");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Force refresh counter to help rebuild the app when language changes
  final RxInt _forceRefresh = 0.obs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Force rebuild when locale changes
    context.locale;
    setState(() {
      _forceRefresh.value++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,

      // EasyLocalization setup
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // App routing
      initialRoute: MyRoutes.splash,
      initialBinding: AppBinding(),
      getPages: MyRoutes.pages,

      // Key based on locale to force rebuild (lighter approach)
      key: ValueKey('app_${context.locale.languageCode}'),
    );
  }
}
