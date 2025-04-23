import 'package:flutter/cupertino.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/modules/venue/data/repositories/venue_repository.dart';
import 'package:get/get.dart';

class VenueListController extends GetxController {
  final VenueRepository _venueRepository = VenueRepository();
  final RxList<VenueModel> venues = <VenueModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final TextEditingController searchController = TextEditingController();

  //selected filters
  final RxString selectedCategory = ''.obs;
  final RxList<String> categories = <String>[].obs;



  void navigateToVenueDetail(VenueModel venue) {
    if (venue.id != null) {
      Get.toNamed(MyRoutes.venueDetail, arguments: {'venueId': venue.id});
    } else {
      Get.snackbar('Error', 'Cannot open venue details',
          snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> loadVenues() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final loadedVenues = await _venueRepository.getVenues();

      if (selectedCategory.isNotEmpty) {
        venues.assignAll(loadedVenues
            .where((venue) =>
                venue.category?.name?.toLowerCase() ==
                selectedCategory.value.toLowerCase())
            .toList());
      } else {
        venues.assignAll(loadedVenues);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load venues. Please try again.';
      print('Error loading venues: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategories() async {
    try {
      final loadedVenues = await _venueRepository.getVenues();
      final uniqueCategories = loadedVenues
          .map((venue) => venue.category?.name ?? '')
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList();

      categories.assignAll(uniqueCategories);
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    loadVenues();
  }

  void clearCategory() {
    selectedCategory.value = '';
    loadVenues();
  }

  void searchVenues(String query) {
    loadVenues();
  }

  Future<void> refreshVenues() async {
    return loadVenues();
  }
}
