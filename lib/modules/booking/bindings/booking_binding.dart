import 'package:function_mobile/modules/booking/controllers/booking_controller.dart';
import 'package:function_mobile/modules/booking/controllers/booking_detail_controller.dart';
import 'package:function_mobile/modules/booking/services/booking_service.dart';
import 'package:function_mobile/modules/booking/services/booking_validation_service.dart';
import 'package:get/get.dart';

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<BookingValidationService>(() => BookingValidationService());
    Get.lazyPut<BookingService>(() => BookingService());

    // Controllers
    Get.lazyPut<BookingController>(() => BookingController());
    Get.lazyPut<BookingDetailController>(() => BookingDetailController());

    // BookingListController is already in AppBinding since it's used globally
  }
}
