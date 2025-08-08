import 'package:function_mobile/common/bindings/localization_binding.dart';
import 'package:function_mobile/modules/auth/services/auth_service.dart';
import 'package:function_mobile/modules/booking/controllers/booking_list_controller.dart';
import 'package:function_mobile/modules/favorite/controllers/favorites_controller.dart';
import 'package:function_mobile/modules/notification/controllers/notification_controllers.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:function_mobile/modules/home/controllers/search_filter_controller.dart';
import 'package:function_mobile/modules/home/controllers/home_controller.dart';
import 'package:function_mobile/modules/navigation/controllers/bottom_nav_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize localization controller first
    LocalizationBinding().dependencies();

    // Core controllers that are used across multiple screens
    Get.put(AuthController(), permanent: true);
    Get.put(SearchFilterController(), permanent: true);
    Get.put(BottomNavController(), permanent: true);
    Get.put(FavoritesController(), permanent: true);
    Get.put(BookingListController(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(NotificationController(), permanent: true);
    Get.put(HomeController(), permanent: true);

    // Non-permanent controllers that can be lazy-loaded

    // Add other app-wide dependencies here
  }
}
