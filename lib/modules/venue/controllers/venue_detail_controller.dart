import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/modules/venue/data/repositories/venue_repository.dart';
import 'package:function_mobile/modules/favorite/controllers/favorites_controller.dart';

class VenueDetailController extends GetxController {
  final VenueRepository _venueRepository = VenueRepository();
  final FavoritesController _favoritesController =
      Get.find<FavoritesController>();

  final RxBool isFavorite = false.obs;

  // Observable variables
  final Rx<VenueModel?> venue = Rx<VenueModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<PictureModel> venueImages = <PictureModel>[].obs;
  final RxBool isLoadingImages = true.obs;
  final RxInt currentImageIndex = 0.obs;

  final RxList<ActivityModel> activities = <ActivityModel>[].obs;
  final RxBool isLoadingActivities = true.obs;

  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxBool isLoadingReviews = true.obs;

  final RxList<FacilityModel> facilities = <FacilityModel>[].obs;
  final RxBool isLoadingFacilities = true.obs;

  final Rx<RatingStatsModel?> ratingStats = Rx<RatingStatsModel?>(null);
  final RxBool isLoadingRatingStats = true.obs;

  final Map<String, IconData> facilityIcons = {
    'Chair': Icons.chair,
    'Table': Icons.table_bar,
    'Speaker': Icons.speaker,
    'Wifi': Icons.wifi,
    'Parking': Icons.local_parking,
    'AC': Icons.ac_unit,
    'Projector': Icons.videocam,
    'Whiteboard': Icons.edit,
    'Power Outlets': Icons.power,
  };

  @override
  void onInit() {
    super.onInit();
    // Get the venue ID from route parameters
    final venueId = Get.arguments?['venueId'] ?? 1;
    loadVenueDetails(venueId);
    checkFavoriteStatus(venueId);
  }

  Future<void> checkFavoriteStatus(int venueId) async {
    isFavorite.value = await _favoritesController.isFavorite(venueId);
  }

  Future<void> toggleFavorite() async {
    if (venue.value?.id != null) {
      await _favoritesController.toggleFavorite(venue.value!.id);
      isFavorite.value = await _favoritesController.isFavorite(venue.value!.id);
    }
  }

  void _preloadImages() {
    if (venue.value?.pictures != null) {
      for (final picture in venue.value!.pictures!) {
        if (picture.imageUrl != null) {
          // Preload images in background
          precacheImage(
            CachedNetworkImageProvider(picture.imageUrl!),
            Get.context!,
          ).catchError((error) {
            print('Preload error: $error');
          });
        }
      }
    }
  }

  Future<void> loadVenueDetails(int venueId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final venueData = await _venueRepository.getVenueById(venueId);

      if (venueData != null) {
        venue.value = venueData;
        print(
            'Venue rating: ${venue.value?.rating}, count: ${venue.value?.ratingCount}');

        _extractVenueImages();
        _extractVenueCategory();
        _extractVenueFacilities();
        _extractVenueActivities();
        await loadVenueReviews(venueId);
        await loadVenueRatingStats(venueId);
        _preloadImages();
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to load venue details';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error: ${e.toString()}';
      print('Error loading venue details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add new method to load rating stats
  Future<void> loadVenueRatingStats(int venueId) async {
    try {
      isLoadingRatingStats.value = true;
      final stats = await _venueRepository.getVenueRatingStats(venueId);

      if (stats != null) {
        ratingStats.value = stats;
        print(
            'Rating stats loaded: ${stats.averageRating} (${stats.totalReviews} reviews)');
      } else {
        ratingStats.value =
            RatingStatsModel(averageRating: 0.0, totalReviews: 0);
      }
    } catch (e) {
      print('Error loading rating stats: $e');
      ratingStats.value = RatingStatsModel(averageRating: 0.0, totalReviews: 0);
    } finally {
      isLoadingRatingStats.value = false;
    }
  }

  void _extractVenueActivities() {
    try {
      isLoadingActivities.value = true;
      activities.clear();

      // Debug: Print raw venue data
      print('🔍 Debug venue activities data:');
      print('venue.value?.activities: ${venue.value?.activities}');
      print('venue.value?.activityIds: ${venue.value?.activityIds}');

      // Priority 1: Use activities array from backend (proper way)
      if (venue.value?.activities != null &&
          venue.value!.activities!.isNotEmpty) {
        activities.assignAll(venue.value!.activities!);
        print('✅ Loaded ${activities.length} activities from activities array');
        
        // Debug: Print each activity
        for (var activity in activities) {
          print('Activity: id=${activity.id}, name=${activity.name}');
        }
        return;
      }

      // Priority 2: Fallback to activity_ids - fetch from API
      if (venue.value?.activityIds != null &&
          venue.value!.activityIds!.isNotEmpty) {
        print('⚠️ Using activity_ids fallback for venue ${venue.value?.id}');
        _fetchActivitiesByIds(venue.value!.activityIds!);
        return;
      }

      print('❌ No activities available for venue ${venue.value?.id}');
    } catch (e) {
      print('❌ Error extracting venue activities: $e');
      activities.clear();
    } finally {
      isLoadingActivities.value = false;
    }
  }

  // Add this new method
  Future<void> _fetchActivitiesByIds(List<int> activityIds) async {
    try {
      isLoadingActivities.value = true;
      final List<ActivityModel> fetchedActivities = [];

      for (int id in activityIds) {
        final activity = await _venueRepository.getActivityById(id);
        if (activity != null) {
          fetchedActivities.add(activity);
          print('✅ Fetched activity: id=${activity.id}, name=${activity.name}');
        } else {
          print('❌ Failed to fetch activity with ID: $id');
        }
      }
      
      if (fetchedActivities.isNotEmpty) {
        activities.assignAll(fetchedActivities);
        print('✅ Successfully fetched ${fetchedActivities.length} activities from API');
      } else {
        print('⚠️ No activities fetched, using placeholder');
        // Fallback to placeholder if API fails
        final placeholderActivities = activityIds.map((id) {
          return ActivityModel(
            id: id,
            name: 'Activity $id',
          );
        }).toList();
        activities.assignAll(placeholderActivities);
      }
    } catch (e) {
      print('❌ Error fetching activities by IDs: $e');
      // Fallback to placeholder if API fails
      final placeholderActivities = activityIds.map((id) {
        return ActivityModel(
          id: id,
          name: 'Activity $id',
        );
      }).toList();
      activities.assignAll(placeholderActivities);
    } finally {
      isLoadingActivities.value = false;
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

  void _extractVenueImages() {
    try {
      isLoadingImages.value = true;
      venueImages.clear();

      // Priority 1: Use pictures array from backend (proper way)
      if (venue.value?.pictures != null && venue.value!.pictures!.isNotEmpty) {
        final validImages = venue.value!.pictures!
            .where((img) =>
                img.filename != null &&
                img.filename!.isNotEmpty &&
                img.filename != 'null' &&
                img.filename!.trim().isNotEmpty)
            .toList();

        if (validImages.isNotEmpty) {
          venueImages.assignAll(validImages);
          print('Loaded ${validImages.length} images from pictures array');
          return;
        }
      }

      // Priority 2: Use first_picture as fallback
      if (venue.value?.firstPicture != null &&
          venue.value!.firstPicture!.isNotEmpty &&
          venue.value!.firstPicture != 'null') {
        final mainImage = PictureModel(
          id: '0',
          filename: venue.value!.firstPicture,
          placeId: venue.value?.id,
        );
        venueImages.add(mainImage);
        print('Using first_picture as fallback: ${venue.value!.firstPicture}');
        return;
      }

      // No valid images found
      print('⚠️ No valid images found for venue ${venue.value?.id}');
    } catch (e) {
      print('❌ Error extracting venue images: $e');
      venueImages.clear();
    } finally {
      isLoadingImages.value = false;
    }
  }

  void _extractVenueFacilities() {
    try {
      isLoadingFacilities.value = true;
      facilities.clear();

      // Priority 1: Use facilities array from backend (proper way)
      if (venue.value?.facilities != null &&
          venue.value!.facilities!.isNotEmpty) {
        final facilitiesWithIcons = venue.value!.facilities!.map((facility) {
          // Find matching icon (case-insensitive and flexible matching)
          IconData? icon = _findFacilityIcon(facility.name);

          return FacilityModel(
            id: facility.id,
            name: facility.name,
            isAvailable: facility.isAvailable ?? true,
            icon: icon,
          );
        }).toList();

        facilities.assignAll(facilitiesWithIcons);
        print(
            'Loaded ${facilitiesWithIcons.length} facilities from facilities array');
        return;
      }

      // Priority 2: Fallback to facility_ids (legacy support)
      if (venue.value?.facilityIds != null &&
          venue.value!.facilityIds!.isNotEmpty) {
        print('Using facility_ids fallback for venue ${venue.value?.id}');

        final placeholderFacilities = venue.value!.facilityIds!.map((id) {
          String facilityName = _getFacilityNameById(id);
          IconData? icon = _findFacilityIcon(facilityName);

          return FacilityModel(
            id: id,
            name: facilityName,
            isAvailable: true,
            icon: icon,
          );
        }).toList();

        facilities.assignAll(placeholderFacilities);
        print('Created ${placeholderFacilities.length} facilities from IDs');
        return;
      }

      // No facilities found
      print('No facilities available for venue ${venue.value?.id}');
    } catch (e) {
      print('Error extracting venue facilities: $e');
      facilities.clear();
    } finally {
      isLoadingFacilities.value = false;
    }
  }

  void _extractVenueCategory() {
    try {
      print('🔍 Extracting venue category...');

      // Priority 1: Use category object from backend
      if (venue.value?.category != null) {
        print('✅ Found CategoryModel object: ${venue.value!.category!.name}');
        // Category is already properly loaded from API response
        return;
      }

      // Priority 2: Use categoryId (fallback)
      if (venue.value?.categoryId != null) {
        print('ℹ️ Using categoryId fallback: ${venue.value!.categoryId}');

        _fetchCategoryName(venue.value!.categoryId);
      }
    } catch (e) {
      print('❌ Error extracting venue category: $e');
    }
  }

  Future<void> _fetchCategoryName(int? categoryId) async {
    if (categoryId == null) return;

    try {
      print('🔍 Fetching category name for ID: $categoryId');
      final venueRepo = VenueRepository();
      final allCategories = await venueRepo.getCategories();

      final category = allCategories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () =>
            CategoryModel(id: categoryId, name: 'Category $categoryId'),
      );

      // Update venue category
      if (venue.value != null) {
        venue.value = VenueModel(
          id: venue.value!.id,
          name: venue.value!.name,
          address: venue.value!.address,
          description: venue.value!.description,
          mapsUrl: venue.value!.mapsUrl,
          categoryId: venue.value!.categoryId,
          facilityIds: venue.value!.facilityIds,
          activityIds: venue.value!.activityIds,
          cityId: venue.value!.cityId,
          hostId: venue.value!.hostId,
          rules: venue.value!.rules,
          rooms: venue.value!.rooms,
          firstPicture: venue.value!.firstPicture,
          pictures: venue.value!.pictures,
          host: venue.value!.host,
          category: category,
          city: venue.value!.city,
          facilities: venue.value!.facilities,
          activities: venue.value!.activities,
          rating: venue.value!.rating,
          ratingCount: venue.value!.ratingCount,
          reviews: venue.value!.reviews,
          schedules: venue.value!.schedules,
          price: venue.value!.price,
          maxCapacity: venue.value!.maxCapacity,
        );
      }

      print('✅ Updated category name: ${category.name}');
    } catch (e) {
      print('❌ Error fetching category name: $e');
    }
  }

  IconData? _findFacilityIcon(String? facilityName) {
    if (facilityName == null || facilityName.isEmpty) return Icons.help_outline;

    // Direct match first
    if (facilityIcons.containsKey(facilityName)) {
      return facilityIcons[facilityName];
    }

    // Case-insensitive search
    final lowerName = facilityName.toLowerCase();
    for (var entry in facilityIcons.entries) {
      if (entry.key.toLowerCase() == lowerName) {
        return entry.value;
      }
    }

    // Partial matching for common cases
    if (lowerName.contains('wifi') || lowerName.contains('internet')) {
      return Icons.wifi;
    } else if (lowerName.contains('chair') || lowerName.contains('seat')) {
      return Icons.chair;
    } else if (lowerName.contains('table')) {
      return Icons.table_bar;
    } else if (lowerName.contains('park')) {
      return Icons.local_parking;
    } else if (lowerName.contains('ac') || lowerName.contains('air')) {
      return Icons.ac_unit;
    } else if (lowerName.contains('toilet') ||
        lowerName.contains('restroom') ||
        lowerName.contains('wc')) {
      return Icons.wc;
    }

    // Default icon if no match found
    return Icons.check_circle_outline;
  }

  // Enhanced facility ID to name mapping
  String _getFacilityNameById(int id) {
    switch (id) {
      case 1:
        return 'Wifi';
      case 2:
        return 'Chairs';
      case 3:
        return 'Restroom';
      case 4:
        return 'Tables';
      case 5:
        return 'Parking';
      case 6:
        return 'AC';
      case 7:
        return 'Projector';
      case 8:
        return 'Speaker';
      case 9:
        return 'Kitchen';
      case 10:
        return 'Security';
      default:
        return 'Facility $id';
    }
  }

  void bookVenue() {
    if (venue.value?.id != null) {
      Get.toNamed(MyRoutes.bookingList,
          arguments: {'venueId': venue.value!.id});
    } else {
      CustomSnackbar.show(
          context: Get.context!,
          message: 'Cannot book this venue at the moment',
          type: SnackbarType.error);
    }
  }

  // Retry loading data
  void retryLoading() {
    // Method untuk refresh data venue
    refreshVenueDetails();
  }

  Future<void> refreshVenueDetails() async {
    if (venue.value?.id != null) {
      await loadVenueDetails(venue.value!.id);
    } else {
      final venueId = Get.arguments?['venueId'] ?? 1;
      await loadVenueDetails(venueId);
    }
  }

  void openGallery(BuildContext context, {int initialIndex = 0}) {
    if (venueImages.isEmpty) {
      print('No images available for gallery');
      return;
    }

    if (initialIndex < 0 || initialIndex >= venueImages.length) {
      print('Invalid image index: $initialIndex, using 0');
      initialIndex = 0;
    }

    Get.toNamed(MyRoutes.imageGallery,
        arguments: {'images': venueImages, 'initialIndex': initialIndex});
  }

  //  Method for opening gallery with specific index
  void openImageAtIndex(BuildContext context, int index) {
    if (venueImages.isEmpty) {
      print('No images available for gallery');
      return;
    }

    if (index < 0 || index >= venueImages.length) {
      print('Invalid image index: $index');
      return;
    }

    print('Opening gallery at index $index');

    Get.toNamed(MyRoutes.imageGallery,
        arguments: {'images': venueImages, 'initialIndex': index});
  }
}
