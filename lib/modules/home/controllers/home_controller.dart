import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';
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

  // Tambahkan property ini di class HomeController
  final Map<int, RatingStatsModel> _venueRatings =
      <int, RatingStatsModel>{}.obs;

  String ratingStats(VenueModel venue) {
    try {
      // Pastikan venue memiliki ID yang valid
      if (_venueRatings.containsKey(venue.id)) {
        final stats = _venueRatings[venue.id]!;
        final formattedRating = stats.averageRating.toStringAsFixed(1);

        if (stats.totalReviews > 0) {
          return "$formattedRating (${stats.totalReviews})";
        } else {
          return formattedRating;
        }
      }

      // Jika belum ada di cache, ambil dari API secara asynchronous
      _loadVenueRatingStats(venue.id);

      // Sementara gunakan nilai dari venue model sebagai fallback
      final rating = venue.rating ?? 0.0;
      final formattedRating = rating.toStringAsFixed(1);

      // Include rating count if available
      final ratingCount = venue.ratingCount ?? 0;
      if (ratingCount > 0) {
        return "$formattedRating ($ratingCount)";
      } else {
        return formattedRating;
      }
    } catch (e) {
      print('Error getting rating stats: $e');
      return "0.0";
    }
  }

  // Method baru untuk mengambil rating stats
  Future<void> _loadVenueRatingStats(int venueId) async {
    try {
      // Hindari request berulang untuk venue yang sama
      if (_venueRatings.containsKey(venueId)) {
        return;
      }

      final stats = await _venueRepository.getVenueRatingStats(venueId);

      if (stats != null) {
        _venueRatings[venueId] = stats;
        // Trigger refresh UI
        update();
        print(
            'Rating stats loaded for venue $venueId: ${stats.averageRating} (${stats.totalReviews} reviews)');
      } else {
        // Simpan nilai default jika gagal
        _venueRatings[venueId] =
            RatingStatsModel(averageRating: 0.0, totalReviews: 0);
      }
    } catch (e) {
      print('Error loading rating stats for venue $venueId: $e');
      _venueRatings[venueId] =
          RatingStatsModel(averageRating: 0.0, totalReviews: 0);
    }
  }

  Future<void> fetchRecommendedVenues() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final venues = await _venueRepository.getVenues();

      // Filter out venues with missing critical data
      final filteredVenues = venues
          .where((venue) => venue.name != null && venue.price != null)
          .toList();

      if (filteredVenues.isEmpty) {
        // If we have no venues after filtering, show a user-friendly message
        hasError.value = true;
        errorMessage.value =
            'No venues are available right now. Please try again later.';
        recommendedVenues.clear();
        return;
      }

      // Limit to 6 venues for the recommendation section
      final limitedVenues = filteredVenues.take(6).toList();
      recommendedVenues.assignAll(limitedVenues);

      // Preload rating stats for all recommended venues
      for (final venue in limitedVenues) {
        _loadVenueRatingStats(venue.id);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value =
          'Failed to load venues. Please check your connection and try again.';
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

  String get username {
    final authController = Get.find<AuthController>();
    return authController.username;
  }
}
