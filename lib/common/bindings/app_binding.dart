import 'package:function_mobile/modules/favorite/controllers/favorites_controller.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
import 'package:function_mobile/modules/home/controllers/search_filter_controller.dart';
import 'package:function_mobile/modules/home/controllers/home_controller.dart';
import 'package:function_mobile/modules/navigation/controllers/bottom_nav_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Core controllers that are used across multiple screens
    Get.put(AuthController(), permanent: true);
    Get.put(SearchFilterController(), permanent: true);
    Get.put(BottomNavController(), permanent: true);
    Get.put(FavoritesController(), permanent: true);

    // Non-permanent controllers that can be lazy-loaded
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);

    // Add other app-wide dependencies here
    // For example: API services, shared utilities, etc.
  }
}
