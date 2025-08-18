import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/navigation/controllers/bottom_nav_controller.dart';
import 'package:get/get.dart';
import 'package:function_mobile/core/services/secure_storage_service.dart';
import 'package:function_mobile/modules/favorite/models/favorite_model.dart';
import 'package:function_mobile/modules/favorite/services/favorite_service.dart';
import 'package:function_mobile/modules/venue/data/repositories/venue_repository.dart';
import 'package:function_mobile/modules/auth/controllers/auth_controller.dart';

class FavoritesController extends GetxController {
  final SecureStorageService _storageService = SecureStorageService();
  final VenueRepository _venueRepository = VenueRepository();
  final FavoriteService _favoriteService = FavoriteService();
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
        isLoading.value = false;
        return;
      }

      print(
          'Loading favorites for user ${currentUser.id} (${currentUser.username})');

      // Load favorites from backend API
      try {
        final backendFavorites = await _favoriteService.getFavorites();
        favorites.addAll(backendFavorites);

        // Sync with local storage for offline access
        final favoriteIds = backendFavorites.map((fav) => fav.id).toList();
        await _storageService.saveFavorites(favoriteIds, currentUser.id);

        print(
            'Successfully loaded ${favorites.length} favorites from backend');
        debugPrintFavorites(); // Debug print favorites
      } catch (backendError) {
        print('Error loading favorites from backend: $backendError');

        CustomSnackbar.show(
            context: Get.context!,
            message: LocalizationHelper.tr(LocaleKeys.errors_networkError),
            type: SnackbarType.error,
            autoClear: true,
            enableDebounce: false);
      }
    } catch (e) {
      print('Unexpected error in loadFavorites: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite(int venueId) async {
    try {
      final currentUser = _authController.user.value;
      if (currentUser == null) {
        CustomSnackbar.show(
            context: Get.context!,
            message: LocalizationHelper.tr(LocaleKeys.errors_unauthorized),
            type: SnackbarType.error,
            autoClear: true,
            enableDebounce: false);
        return;
      }

      // Use backend API to toggle favorite
      final result = await _favoriteService.toggleFavorite(venueId.toString());

      if (result['action'] == 'added') {
        // Load venue details and add to favorites list
        final venue = await _venueRepository.getVenueById(venueId);
        if (venue != null) {
          favorites.add(FavoriteModel(
            id: venueId,
            venue: venue,
            createdAt: DateTime.now(),
          ));
        }

        // Update local storage
        await _storageService.addFavorite(venueId, currentUser.id);
        CustomSnackbar.show(
            context: Get.context!,
            message: LocalizationHelper.tr(LocaleKeys.venue_addToFavorites),
            type: SnackbarType.success,
            autoClear: true,
            enableDebounce: true);
      } else if (result['action'] == 'removed') {
        favorites.removeWhere((fav) => fav.id == venueId);

        // Update local storage
        await _storageService.removeFavorite(venueId, currentUser.id);
        CustomSnackbar.show(
            context: Get.context!,
            message: LocalizationHelper.tr(LocaleKeys.venue_removeFromFavorites),
            type: SnackbarType.success,
            autoClear: true,
            enableDebounce: true);
      }
    } catch (e) {
      print('Error toggling favorite: $e');

      // Fallback to local storage if backend fails
      try {
        final currentUser = _authController.user.value;
        if (currentUser != null) {
          final favoriteIds =
              await _storageService.getFavorites(currentUser.id);

          if (favoriteIds.contains(venueId)) {
            await _storageService.removeFavorite(venueId, currentUser.id);
            favorites.removeWhere((fav) => fav.id == venueId);
            CustomSnackbar.show(
                context: Get.context!,
                message: LocalizationHelper.tr(LocaleKeys.venue_removeFromFavorites),
                type: SnackbarType.success,
                autoClear: true,
                enableDebounce: true);
          } else {
            await _storageService.addFavorite(venueId, currentUser.id);

            final venue = await _venueRepository.getVenueById(venueId);
            if (venue != null) {
              favorites.add(FavoriteModel(
                id: venueId,
                venue: venue,
                createdAt: DateTime.now(),
              ));
            }

            CustomSnackbar.show(
                context: Get.context!,
                message: LocalizationHelper.tr(LocaleKeys.venue_addToFavorites),
                type: SnackbarType.success,
                autoClear: true,
                enableDebounce: true);
          }
        }
      } catch (localError) {
        print('Error with local storage fallback: $localError');
        CustomSnackbar.show(
            context: Get.context!,
            message: LocalizationHelper.tr(LocaleKeys.errors_networkError),
            type: SnackbarType.error,
            autoClear: true,
            enableDebounce: false);
      }
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



  /// Mengecek status favorite untuk venue tertentu dari backend API
  Future<bool> checkFavoriteStatus(String venueId) async {
    try {
      return await _favoriteService.checkFavoriteStatus(venueId);
    } catch (e) {
      print(
          'FavoritesController: Error checking favorite status from backend: $e');
      // Fallback ke pengecekan lokal jika backend gagal
      return isVenueInFavorites(int.parse(venueId));
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
          message: LocalizationHelper.tr(LocaleKeys.common_success),
          type: SnackbarType.success,
          autoClear: true,
          enableDebounce: false);
    } catch (e) {
      print('Error clearing favorites: $e');

      CustomSnackbar.show(
          context: Get.context!,
          message: LocalizationHelper.tr(LocaleKeys.errors_networkError),
          type: SnackbarType.error,
          autoClear: true,
          enableDebounce: false);
    }
  }

  // Get favorites count for current user
  int get favoritesCount => favorites.length;

  // Check if venue is in favorites list (from memory, faster than storage)
  bool isVenueInFavorites(int venueId) {
    final result = favorites.any((favorite) => favorite.id == venueId);
    print(
        'FavoritesController: Checking if venue $venueId is in favorites (memory): $result');
    return result;
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
          type: SnackbarType.success,
          autoClear: true,
          enableDebounce: true);
    } catch (e) {
      print('Error removing favorite: $e');
      CustomSnackbar.show(
          context: Get.context!,
          message: LocalizationHelper.tr(LocaleKeys.errors_networkError),
          type: SnackbarType.error,
          autoClear: true,
          enableDebounce: false);
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
