import 'package:get/get.dart';
import 'package:function_mobile/modules/venue/controllers/venue_detail_controller.dart';
import 'package:function_mobile/modules/venue/controllers/venue_list_controller.dart';

class VenueBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VenueDetailController>(() => VenueDetailController());
    Get.lazyPut<VenueListController>(() => VenueListController());
  }
}
