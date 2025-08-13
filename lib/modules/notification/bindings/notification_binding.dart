import 'package:get/get.dart';
import 'package:function_mobile/modules/notification/controllers/notification_controllers.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}