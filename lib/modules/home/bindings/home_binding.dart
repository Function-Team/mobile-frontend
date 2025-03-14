import 'package:function_mobile/modules/home/views/home_page.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<HomePage>(() => HomePage());
  }
}
