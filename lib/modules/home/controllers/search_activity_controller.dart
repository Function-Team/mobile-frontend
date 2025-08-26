import 'dart:async';
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
  
  // Debounce timer for search
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Load activities and venues concurrently with timeout
      final results = await Future.wait([
        _venueRepository.getActivities(),
        _venueRepository.getVenues(),
      ]).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Loading data timed out', const Duration(seconds: 30));
        },
      );

      // Safe assignment with null checks
      if (results.isNotEmpty && results[0] is List<ActivityModel>) {
        final activities = results[0] as List<ActivityModel>;
        allActivities.assignAll(activities);
        filteredActivities.assignAll(activities);
      }

      if (results.length > 1 && results[1] is List<VenueModel>) {
        final venues = results[1] as List<VenueModel>;
        allVenues.assignAll(venues);
        filteredVenues.assignAll(venues);
      }
    } catch (e) {
      print('Error loading data: $e');
      errorMessage.value = 'Failed to load data: $e';
      
      // Safe fallback - ensure lists are not null
      if (allActivities.isEmpty) {
        allActivities.assignAll(<ActivityModel>[]);
        filteredActivities.assignAll(<ActivityModel>[]);
      }
      if (allVenues.isEmpty) {
        allVenues.assignAll(<VenueModel>[]);
        filteredVenues.assignAll(<VenueModel>[]);
      }
      
      // Show error message to user
      try {
        CustomSnackbar.show(
            context: Get.context!, 
            message: LocalizationHelper.tr(LocaleKeys.errors_networkError), 
            type: SnackbarType.error,
            autoClear: true,
            enableDebounce: false);
      } catch (snackbarError) {
        print('Error showing snackbar: $snackbarError');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void filterItems(String query) {
    // Cancel previous timer to implement debouncing
    _debounceTimer?.cancel();
    
    // Add debounce to prevent excessive filtering on every keystroke
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      try {
        if (query.isEmpty) {
          // Reset to full list
          filteredActivities.assignAll(allActivities);
          filteredVenues.assignAll(allVenues);
        } else {
          // Filter based on query with safety checks
          final lowercaseQuery = query.toLowerCase();

          // Safe filtering with null checks
          final safeActivities = allActivities.where((activity) {
            try {
              return (activity.name ?? '').toLowerCase().contains(lowercaseQuery);
            } catch (e) {
              print('Error filtering activity: $e');
              return false;
            }
          }).toList();

          final safeVenues = allVenues.where((venue) {
            try {
              return (venue.name ?? '').toLowerCase().contains(lowercaseQuery) ||
                     (venue.city?.name ?? '').toLowerCase().contains(lowercaseQuery);
            } catch (e) {
              print('Error filtering venue: $e');
              return false;
            }
          }).toList();

          filteredActivities.assignAll(safeActivities);
          filteredVenues.assignAll(safeVenues);
        }
      } catch (e) {
        print('Error in filterItems: $e');
        // Fallback to show all items if filtering fails
        filteredActivities.assignAll(allActivities);
        filteredVenues.assignAll(allVenues);
      }
    });
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
    _debounceTimer?.cancel(); // Clean up timer
    searchController.dispose();
    super.onClose();
  }
}
