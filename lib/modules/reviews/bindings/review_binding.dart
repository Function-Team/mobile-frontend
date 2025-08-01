import 'package:function_mobile/modules/reviews/controllers/review_controller.dart';
import 'package:function_mobile/modules/reviews/services/review_service.dart';
import 'package:get/get.dart';

class ReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewService>(() => ReviewService());
    Get.lazyPut<ReviewController>(() => ReviewController());
  }
}