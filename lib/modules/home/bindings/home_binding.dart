import 'package:function_mobile/modules/home/controllers/home_controller.dart';
import 'package:function_mobile/modules/home/controllers/search_filter_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchFilterController>(() => SearchFilterController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
