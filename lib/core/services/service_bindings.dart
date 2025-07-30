import 'package:get/get.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/core/services/cache_service.dart';
import 'package:function_mobile/core/services/secure_storage_service.dart';
import 'package:function_mobile/core/services/notification_service.dart';

class ServiceBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut(() => CacheService(Get.find()));
    Get.lazyPut<SecureStorageService>(() => SecureStorageService());
    Get.lazyPut<NotificationService>(() => NotificationService());
  }
}