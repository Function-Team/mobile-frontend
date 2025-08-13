import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/modules/navigation/controllers/bottom_nav_controller.dart';
import 'package:get/get.dart';
import 'package:function_mobile/core/services/secure_storage_service.dart';
import 'package:function_mobile/modules/favorite/models/favorite_model.dart';
import 'package:function_mobile/modules/venue/data/repositories/venue_repository.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';

class FavoritesController extends GetxController {
  final SecureStorageService _storageService = SecureStorageService();
  final VenueRepository _venueRepository = VenueRepository();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<FavoriteModel> favorites = <FavoriteModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();

    // Listen to auth changes to reload favorites when user changes
    ever(_authController.user, (user) {
      if (user != null) {
        loadFavorites();
      } else {
        // Clear favorites when user logs out
        favorites.clear();
      }
    });
  }

  Future<void> loadFavorites() async {
    try {
      isLoading.value = true;
      favorites.clear();

      // Get current user
      final currentUser = _authController.user.value;
      if (currentUser == null) {
        print('No user logged in, cannot load favorites');
        return;
      }

      final favoriteIds = await _storageService.getFavorites(currentUser.id);
      print(
          'Loading ${favoriteIds.length} favorites for user ${currentUser.id}');

      for (var id in favoriteIds) {
        try {
          final venue = await _venueRepository.getVenueById(id);
          if (venue != null) {
            favorites.add(FavoriteModel(
              id: id,
              venue: venue,
              createdAt: DateTime.now(),
            ));
          } else {
            // Remove invalid venue ID from favorites
            await _storageService.removeFavorite(id, currentUser.id);
            print('Removed invalid venue $id from favorites');
          }
        } catch (e) {
          print('Error loading venue $id: $e');
          // Optionally remove problematic venue from favorites
          await _storageService.removeFavorite(id, currentUser.id);
        }
      }

      print('Successfully loaded ${favorites.length} favorites');
    } catch (e) {
      print('Error loading favorites: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite(int venueId) async {
    try {
      // Get current user
      final currentUser = _authController.user.value;
      if (currentUser == null) {
        CustomSnackbar.show(
            context: Get.context!,
            message: 'Please log in to manage favorites',
            type: SnackbarType.error);
        return;
      }

      final favoriteIds = await _storageService.getFavorites(currentUser.id);

      if (favoriteIds.contains(venueId)) {
        // Remove from favorites
        await _storageService.removeFavorite(venueId, currentUser.id);
        favorites.removeWhere((favorite) => favorite.id == venueId);

        CustomSnackbar.show(
            context: Get.context!,
            message: 'Removed from favorites',
            type: SnackbarType.success);
      } else {
        // Add to favorites
        final venue = await _venueRepository.getVenueById(venueId);
        if (venue != null) {
          await _storageService.addFavorite(venueId, currentUser.id);
          favorites.add(FavoriteModel(
            id: venueId,
            venue: venue,
            createdAt: DateTime.now(),
          ));

          CustomSnackbar.show(
              context: Get.context!,
              message: 'Added to favorites',
              type: SnackbarType.success);
        } else {
          CustomSnackbar.show(
              context: Get.context!,
              message: 'Venue not found',
              type: SnackbarType.error);
        }
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      CustomSnackbar.show(
          context: Get.context!,
          message: 'Failed to update favorites',
          type: SnackbarType.error);
    }
  }

  Future<bool> isFavorite(int venueId) async {
    try {
      final currentUser = _authController.user.value;
      if (currentUser == null) return false;

      final favoriteIds = await _storageService.getFavorites(currentUser.id);
      return favoriteIds.contains(venueId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Clear all favorites for current user
  Future<void> clearAllFavorites() async {
    try {
      final currentUser = _authController.user.value;
      if (currentUser == null) return;

      await _storageService.clearFavoritesForUser(currentUser.id);
      favorites.clear();
      CustomSnackbar.show(
          context: Get.context!,
          message: 'All favorites cleared',
          type: SnackbarType.success);
    } catch (e) {
      print('Error clearing favorites: $e');

      CustomSnackbar.show(
          context: Get.context!,
          message: 'Failed to clear favorites',
          type: SnackbarType.error);
    }
  }

  // Get favorites count for current user
  int get favoritesCount => favorites.length;

  // Check if venue is in favorites list (from memory, faster than storage)
  bool isVenueInFavorites(int venueId) {
    return favorites.any((favorite) => favorite.id == venueId);
  }

  // Remove specific favorite by ID
  Future<void> removeFavoriteById(int venueId) async {
    try {
      final currentUser = _authController.user.value;
      if (currentUser == null) return;

      await _storageService.removeFavorite(venueId, currentUser.id);
      favorites.removeWhere((favorite) => favorite.id == venueId);

      CustomSnackbar.show(
          context: Get.context!,
          message: 'Removed from favorites',
          type: SnackbarType.success);
    } catch (e) {
      print('Error removing favorite: $e');
      CustomSnackbar.show(
          context: Get.context!,
          message: 'Failed to remove favorite',
          type: SnackbarType.error);
    }
  }

  // Debug method
  void debugPrintFavorites() {
    final currentUser = _authController.user.value;
    print('=== Favorites Debug ===');
    print('Current user: ${currentUser?.id} (${currentUser?.username})');
    print('Favorites count: ${favorites.length}');
    for (var favorite in favorites) {
      print('- ${favorite.venue.name} (ID: ${favorite.id})');
    }
    print('=====================');
  }

  void goToHome() {
    Get.find<BottomNavController>().changePage(0);
  }
}
