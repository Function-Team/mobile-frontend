import 'package:function_mobile/modules/navigation/controllers/bottom_nav_controller.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/modules/venue/data/repositories/venue_repository.dart';

class HomeController extends GetxController {
  final VenueRepository _venueRepository = VenueRepository();
  final RxList<VenueModel> recommendedVenues = <VenueModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecommendedVenues();
  }

  void goToVenueDetails(VenueModel venue) {
    Get.toNamed(MyRoutes.venueDetail, arguments: {'venueId': venue.id});
  }

  void goToProfile() {
    Get.find<BottomNavController>().changePage(2);
  }

  Future<void> fetchRecommendedVenues() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final venues = await _venueRepository.getVenues();

      // Filter out venues with missing critical data
      final filteredVenues = venues.where((venue) => 
        venue.id != null && 
        venue.name != null && 
        venue.price != null
      ).toList();


      if (filteredVenues.isEmpty) {
        // If we have no venues after filtering, show a user-friendly message
        hasError.value = true;
        errorMessage.value = 'No venues are available right now. Please try again later.';
        recommendedVenues.clear();
        return;
      }

      // Limit to 6 venues for the recommendation section
      recommendedVenues.assignAll(filteredVenues.take(6).toList());
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load venues. Please check your connection and try again.';
      recommendedVenues.clear();
      print('Error fetching recommended venues: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add proper error-handled refresh function
  Future<void> refreshVenues() async {
    // Clear existing state
    recommendedVenues.clear();
    // Start fresh fetch
    return fetchRecommendedVenues();
  }
}