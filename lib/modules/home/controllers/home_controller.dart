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

  Future<void> fetchRecommendedVenues() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final venues = await _venueRepository.getVenues();

      // Filter out venues with missing critical data if needed
      final filteredVenues = venues
          .where((venue) =>
              venue.id != null && venue.name != null && venue.price != null)
          .toList();

      // Limit to 10 venues for the recommendation section
      recommendedVenues.assignAll(filteredVenues.take(6).toList());
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load venues: $e';
      print('Error fetching recommended venues: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void refreshVenues() {
    fetchRecommendedVenues();
  }
}
