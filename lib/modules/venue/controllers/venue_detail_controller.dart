import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/modules/venue/data/repositories/venue_repository.dart';

class VenueDetailController extends GetxController {
  final VenueRepository _venueRepository = VenueRepository();

  // Observable variables
  final Rx<VenueModel?> venue = Rx<VenueModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<PictureModel> venueImages = <PictureModel>[].obs;
  final RxBool isLoadingImages = true.obs;
  final RxInt currentImageIndex = 0.obs;

  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxBool isLoadingReviews = true.obs;

  final RxList<FacilityModel> facilities = <FacilityModel>[].obs;
  final RxBool isLoadingFacilities = true.obs;

  final Map<String, IconData> facilityIcons = {
    'Chair': Icons.chair,
    'Table': Icons.table_bar,
    'Speaker': Icons.speaker,
    'Wifi': Icons.wifi,
    'Parking': Icons.local_parking,
    'AC': Icons.ac_unit,
    'Projector': Icons.videocam,
    'Whiteboard': Icons.edit,
    'Coffee': Icons.coffee,
    'Food': Icons.restaurant,
    'Power Outlets': Icons.power,
  };

  @override
  void onInit() {
    super.onInit();
    // Get the venue ID from route parameters
    final venueId =
        Get.arguments?['venueId'] ?? 1; // Default to 1 if not provided
    loadVenueDetails(venueId);
  }

  Future<void> loadVenueDetails(int venueId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final venueData = await _venueRepository.getVenueById(venueId);

      if (venueData != null) {
        venue.value = venueData;

        await Future.wait([
          loadVenueReviews(venueId),
          loadVenueFacilities(venueId),
          loadVenueImages(venueId),
        ]);
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to load venue details';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadVenueReviews(int venueId) async {
    try {
      isLoadingReviews.value = true;
      final reviewsData = await _venueRepository.getVenueReviews(venueId);
      reviews.assignAll(reviewsData);
    } catch (e) {
      print('Error loading reviews: $e');
    } finally {
      isLoadingReviews.value = false;
    }
  }

  Future<void> loadVenueImages(int venueId) async {
  try {
    isLoadingImages.value = true;
    final imagesData = await _venueRepository.getVenueImages(venueId);
    print("Images data received: $imagesData");
    
    if (imagesData.isNotEmpty && imagesData[0].imageUrl != null) {
      print("First image URL: ${imagesData[0].imageUrl}");
    }
    
    venueImages.assignAll(imagesData);
  } catch (e) {
    print('Error loading venue images: ${e}');
  } finally {
    isLoadingImages.value = false;
  }
}

  Future<void> loadVenueFacilities(int venueId) async {
    try {
      isLoadingFacilities.value = true;
      final facilitiesData = await _venueRepository.getVenueFacilities(venueId);

      // Assign icons to facilities based on their names
      final facilitiesWithIcons = facilitiesData.map((facility) {
        if (facility.name != null && facilityIcons.containsKey(facility.name)) {
          return FacilityModel(
            id: facility.id,
            name: facility.name,
            isAvailable: facility.isAvailable,
            icon: facilityIcons[facility.name],
          );
        }
        return facility;
      }).toList();

      facilities.assignAll(facilitiesWithIcons);
    } catch (e) {
      print('Error loading facilities: $e');
    } finally {
      isLoadingFacilities.value = false;
    }
  }

  void bookVenue() {
    if (venue.value?.id != null) {
      Get.toNamed(MyRoutes.bookingList,
          arguments: {'venueId': venue.value!.id});
    } else {
      Get.snackbar(
        'Error',
        'Cannot book this venue at the moment',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void contactHost() {
    if (venue.value?.host?.id != null) {
      Get.toNamed('/chat', arguments: {'hostId': venue.value!.host!.id});
    } else {
      Get.snackbar(
        'Error',
        'Cannot contact host at the moment',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Retry loading data
  void retryLoading() {
    if (venue.value?.id != null) {
      loadVenueDetails(venue.value!.id!);
    } else {
      final venueId = Get.arguments?['venueId'] ?? 1;
      loadVenueDetails(venueId);
    }
  }
}
