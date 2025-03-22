import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:get/get.dart';


class SearchFilterController extends GetxController {

  final activityController = TextEditingController();
  final locationController = TextEditingController();
  final capacityController = TextEditingController();
  final dateController = TextEditingController();


  @override
  void onInit() {
    super.onInit();
  }

  void goToCapacitySelection() {
    Get.toNamed(MyRoutes.searchCapacity);
  }

  void goToSearchActivity() {
    Get.toNamed(MyRoutes.searchActivity);
  }

  void goToSearchLocation() {
    Get.toNamed(MyRoutes.searchLocation);
  }

  void goToDateSelection() {
    Get.toNamed(MyRoutes.searchDate);
  }
  

  void onClose() {
    activityController.dispose();
    locationController.dispose();
    capacityController.dispose();
    dateController.dispose();
    super.onClose();
  }
}
