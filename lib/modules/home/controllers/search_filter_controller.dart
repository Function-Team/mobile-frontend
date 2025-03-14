import 'package:flutter/material.dart';
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

  @override
  void onClose() {
    activityController.dispose();
    locationController.dispose();
    capacityController.dispose();
    dateController.dispose();
    super.onClose();
  }
}
