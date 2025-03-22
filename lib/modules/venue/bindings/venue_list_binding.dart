import 'package:function_mobile/modules/venue/controllers/venue_list_controller.dart';
import 'package:get/get.dart';

class VenueListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VenueListController>(() => VenueListController());
  }
}
