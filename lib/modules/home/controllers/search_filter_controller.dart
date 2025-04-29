import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/modules/venue/data/repositories/venue_repository.dart';
import 'package:get/get.dart';

class SearchFilterController extends GetxController {
  final VenueRepository _venueRepository = VenueRepository();

  //Controllers
  final activityController = TextEditingController();
  final locationController = TextEditingController();
  final capacityController = TextEditingController();
  final dateController = TextEditingController();
  final searchQueryController = TextEditingController();

  //Observable state
  final RxList<VenueModel> searchResults = <VenueModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  //category filtering state
  final RxString selectedCategory = ''.obs;
  final RxList<String> categories = <String>[].obs;
  final RxMap<String, int> categoryMap = <String, int>{}.obs;

//------------FEATURE SEARCH BY CAPACITY--------------//

  void goToCapacitySelection() async {
    final result = await Get.toNamed(MyRoutes.searchCapacity);

    if (result != null && result is String && result.isNotEmpty) {
      capacityController.text = result;

      _updateSearchWithCapacity();
    }
  }

  void _updateSearchWithCapacity() {
    if (Get.currentRoute == MyRoutes.venueList) {
      performSearch();
    } else {
      Map<String, dynamic> args = {
        'minCapacity': _extraCapacityParameter(),
      };
      Get.toNamed(MyRoutes.venueList, arguments: args);
    }
  }

  int? _extraCapacityParameter() {
    int? minCapacity;

    if (capacityController.text.isNotEmpty) {
      final capacityText = capacityController.text;

      // Handle 1-10 people format
      if (capacityText.contains('-')) {
        final parts = capacityText.split('-');
        if (parts.length == 2) {
          final firstPart = parts[0].trim();
          final numericValue = firstPart.replaceAll(RegExp(r'[^0-9]'), '');
          try {
            minCapacity = int.parse(numericValue);
          } catch (_) {}
        }
      }
      // Handle 200+ people format
      else if (capacityText.contains('+')) {
        final parts = capacityText.split('+');
        if (parts.length > 0) {
          final numericValue =
              parts[0].trim().replaceAll(RegExp(r'[^0-9]'), '');
          try {
            minCapacity = int.parse(numericValue);
          } catch (_) {}
        }
      }
    }
    return minCapacity;
  }

  String? _extraSearchQuery(Map<String, dynamic>? args) {
    String? query;

    if (args != null && args.containsKey('searchQuery')) {
      query = args['searchQuery'] as String?;
      if (query != null && query.isNotEmpty) {
        searchQueryController.text = query;
      }
    } else if (searchQueryController.text.isNotEmpty) {
      query = searchQueryController.text;
    } else if (activityController.text.isNotEmpty) {
      query = activityController.text;
    }
    return query;
  }

  int? _extraCategoryParamater() {
    int? categoryId;

    if (selectedCategory.isNotEmpty) {
      categoryId = categoryMap[selectedCategory.value];
    }
    return categoryId;
  }

  Future<void> performSearch({Map<String, dynamic>? args}) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      String? query = _extraSearchQuery(args);
      int? minCapacity = _extraCapacityParameter();
      int? categoryId = _extraCategoryParamater();

      print('Searching with capacity: $minCapacity');

      //Run the search

      final results = await _venueRepository.searchVenues(
        searchQuery: query,
        categoryId: categoryId,
        minCapacity: minCapacity,
      );
      searchResults.assignAll(results);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Search failed, Please try again. ';
      print('Error during search $e');
    } finally {
      isLoading.value = false;
    }
  }
//------------FEATURE SEARCH BY VENUE NAME--------------//

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

//------------FEATURE SEARCH BY LOCATION--------------//

  void goToSearchLocation() {
    Get.toNamed(MyRoutes.searchLocation);
  }

  // void goToDateSelection() {
  //   Get.toNamed(MyRoutes.searchDate);
  // }

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
