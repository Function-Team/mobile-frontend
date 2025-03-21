import 'package:get/get.dart';
import 'package:function_mobile/common/routes/routes.dart';

class ProfileOptionsController extends GetxController {
  void goToSettings() {
    Get.toNamed(MyRoutes.settings);
  }
}
