import 'package:get/get.dart';
import 'package:function_mobile/modules/venue/controllers/venue_detail_controller.dart';


class VenueDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VenueDetailController>(() => VenueDetailController());
  }
}
