import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:get/get.dart';

class SearchFilterController extends GetxController {
  final activityController = TextEditingController();
  final locationController = TextEditingController();
  final capacityController = TextEditingController();
  final dateController = TextEditingController();

  void goToCapacitySelection() {
    Get.toNamed(MyRoutes.searchCapacity);
  }

  void goToSearchActivity() async {
    final result = await Get.toNamed(MyRoutes.searchActivity);

    if (result != null && result is Map<String, dynamic>) {
      final String searchQuery = result['searchQuery'] ?? '';
      final String type = result['type'] ?? '';

      // Update controller text
      activityController.text = searchQuery;

      if (searchQuery.isNotEmpty && (type == 'search' || type == 'venue')) {
        Get.toNamed(MyRoutes.venueList,
            arguments: {'searchQuery': searchQuery});
      }
    }
  }

  void goToSearchLocation() {
    Get.toNamed(MyRoutes.searchLocation);
  }

  void goToDateSelection() {
    Get.toNamed(MyRoutes.searchDate);
  }

//this is temporay function to navigate to venue list
  void goToSearchResults() {
    Get.toNamed(MyRoutes.venueList);
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
