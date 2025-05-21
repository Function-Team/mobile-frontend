import 'package:function_mobile/modules/booking/controllers/booking_card_controller.dart';
import 'package:function_mobile/modules/booking/controllers/booking_controller.dart';
import 'package:function_mobile/modules/booking/controllers/booking_detail_controller.dart';
import 'package:get/get.dart';

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingController>(() => BookingController());
    Get.lazyPut<BookingCardController>(() => BookingCardController());
    Get.lazyPut<BookingDetailController>(() => BookingDetailController());
  }
}
