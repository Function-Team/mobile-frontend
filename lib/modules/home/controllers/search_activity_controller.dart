import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/modules/venue/data/repositories/venue_repository.dart';
import 'package:get/get.dart';

class SearchActivityController extends GetxController {
  final VenueRepository _venueRepository = VenueRepository();
  final TextEditingController searchController = TextEditingController();

  final RxList<ActivityModel> allActivities = <ActivityModel>[].obs;
  final RxList<ActivityModel> filteredActivities = <ActivityModel>[].obs;
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

      allActivities.assignAll(results[0] as List<ActivityModel>);
      filteredActivities.assignAll(results[0] as List<ActivityModel>);

      // Tampilkan semua venue, bukan hanya 5
      final venues = results[1] as List<VenueModel>;
      allVenues.assignAll(venues);
      filteredVenues.assignAll(venues);
    } catch (e) {
      print('Error loading data: $e');
      errorMessage.value = 'Failed to load data: $e';
      // Show error message to user
      CustomSnackbar.show(
          context: Get.context!, 
          message: LocalizationHelper.tr(LocaleKeys.errors_networkError), 
          type: SnackbarType.error,
          autoClear: true,
          enableDebounce: false);
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

  void onActivitySelected(ActivityModel activity) {
    Get.back(result: {
      'searchQuery': activity.name ?? '',
      'type': 'activity',
      'activityId': activity.id,
    });
  }

  void onVenueSelected(VenueModel venue) {
    Get.toNamed(MyRoutes.venueDetail, arguments: {'venueId': venue.id});
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
