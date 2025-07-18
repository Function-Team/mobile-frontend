import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';

class LocalizationBinding extends Bindings {
  @override
  void dependencies() {
    // Setup a controller that can notify when language changes
    Get.put(LocalizationController(), permanent: true);
  }
}

class LocalizationController extends GetxController {
  // Observable locale to help track changes
  final Rx<String> currentLocale = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Initialize with current locale
    try {
      if (Get.context != null) {
        final context = Get.context!;
        final locale = context.locale.toString();
        currentLocale.value = locale;
        
        // Listen to locale changes
        ever(currentLocale, (_) {
          print('📢 Locale changed to: ${currentLocale.value}');
          // This will trigger a rebuild in widgets that observe this variable
        });
      }
    } catch (e) {
      print('❌ Error initializing LocalizationController: $e');
    }
  }
  
  // Update locale when changed
  void updateLocale(String locale) {
    currentLocale.value = locale;
  }
}