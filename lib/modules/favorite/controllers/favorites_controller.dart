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
      print('Loading ${favoriteIds.length} favorites for user ${currentUser.id}');
      
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
        Get.snackbar(
          'Error',
          'Please log in to manage favorites',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      final favoriteIds = await _storageService.getFavorites(currentUser.id);
      
      if (favoriteIds.contains(venueId)) {
        // Remove from favorites
        await _storageService.removeFavorite(venueId, currentUser.id);
        favorites.removeWhere((favorite) => favorite.id == venueId);
        
        Get.snackbar(
          'Removed',
          'Removed from favorites',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 1),
        );
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
          
          Get.snackbar(
            'Added',
            'Added to favorites',
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 1),
          );
        } else {
          Get.snackbar(
            'Error',
            'Venue not found',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      Get.snackbar(
        'Error',
        'Failed to update favorites',
        snackPosition: SnackPosition.BOTTOM,
      );
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
      
      Get.snackbar(
        'Cleared',
        'All favorites cleared',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error clearing favorites: $e');
      Get.snackbar(
        'Error',
        'Failed to clear favorites',
        snackPosition: SnackPosition.BOTTOM,
      );
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
      
      Get.snackbar(
        'Removed',
        'Removed from favorites',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 1),
      );
    } catch (e) {
      print('Error removing favorite: $e');
      Get.snackbar(
        'Error',
        'Failed to remove favorite',
        snackPosition: SnackPosition.BOTTOM,
      );
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
}