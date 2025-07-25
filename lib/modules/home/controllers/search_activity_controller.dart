import 'package:flutter/material.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/modules/venue/data/repositories/venue_repository.dart';
import 'package:get/get.dart';

class SearchActivityController extends GetxController {
  final VenueRepository _venueRepository = VenueRepository();
  final TextEditingController searchController = TextEditingController();

  // Observable lists for dynamic data - renamed for clarity
  final RxList<CategoryModel> allActivities = <CategoryModel>[].obs;
  final RxList<CategoryModel> filteredActivities = <CategoryModel>[].obs;
  final RxList<VenueModel> allVenues = <VenueModel>[].obs;
  final RxList<VenueModel> filteredVenues = <VenueModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Load activities and venues concurrently
      final results = await Future.wait([
        _venueRepository.getActivities(),
        _venueRepository.getVenues(),
      ]);

      allActivities.assignAll(results[0] as List<CategoryModel>);
      filteredActivities.assignAll(results[0] as List<CategoryModel>);

      // Tampilkan semua venue, bukan hanya 5
      final venues = results[1] as List<VenueModel>;
      allVenues.assignAll(venues);
      filteredVenues.assignAll(venues);
    } catch (e) {
      print('Error loading data: $e');
      errorMessage.value = 'Failed to load data: $e';
      // Show error message to user
      Get.snackbar(
        'Error',
        'Failed to load data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterItems(String query) {
    if (query.isEmpty) {
      // Reset to full list
      filteredActivities.assignAll(allActivities);
      filteredVenues.assignAll(allVenues);
    } else {
      // Filter based on query
      final lowercaseQuery = query.toLowerCase();

      filteredActivities.assignAll(
        allActivities
            .where((activity) =>
                (activity.name ?? '').toLowerCase().contains(lowercaseQuery))
            .toList(),
      );

      // Tampilkan semua venue yang cocok, bukan hanya 5
      final filteredVenueList = allVenues
          .where((venue) =>
              (venue.name ?? '').toLowerCase().contains(lowercaseQuery) ||
              (venue.city?.name ?? '').toLowerCase().contains(lowercaseQuery))
          .toList();

      filteredVenues.assignAll(filteredVenueList);
    }
  }

  void clearSearch() {
    searchController.clear();
    filterItems('');
  }

  void onSearchSubmitted(String value) {
    if (value.isNotEmpty) {
      try {
        Get.back(result: {'searchQuery': value, 'type': 'search'});
      } catch (e) {
        print('Error navigating back: $e');
        Get.back();
      }
    }
  }

  void onActivitySelected(CategoryModel activity) {
    Get.back(result: {
      'searchQuery': activity.name ?? '',
      'type': 'activity',
      'activityId': activity.id,
    });
  }

  void onVenueSelected(VenueModel venue) {
    Get.back(result: {
      'searchQuery': venue.name ?? '',
      'type': 'venue',
      'venueId': venue.id,
    });
  }

  // Refresh data method
  Future<void> refreshData() async {
    await loadData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
