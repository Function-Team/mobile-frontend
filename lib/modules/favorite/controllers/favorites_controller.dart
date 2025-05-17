import 'package:get/get.dart';
import 'package:function_mobile/core/services/secure_storage_service.dart';
import 'package:function_mobile/modules/favorite/models/favorite_model.dart';
import 'package:function_mobile/modules/venue/data/repositories/venue_repository.dart';

class FavoritesController extends GetxController {
  final SecureStorageService _storageService = SecureStorageService();
  final VenueRepository _venueRepository = VenueRepository();
  
  final RxList<FavoriteModel> favorites = <FavoriteModel>[].obs;
  final RxBool isLoading = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }
  
  Future<void> loadFavorites() async {
    try {
      isLoading.value = true;
      final favoriteIds = await _storageService.getFavorites();
      favorites.clear();
      
      for (var id in favoriteIds) {
        final venue = await _venueRepository.getVenueById(id);
        if (venue != null) {
          favorites.add(FavoriteModel(
            id: id,
            venue: venue,
            createdAt: DateTime.now(),
          ));
        }
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> toggleFavorite(int venueId) async {
    final favoriteIds = await _storageService.getFavorites();
    if (favoriteIds.contains(venueId)) {
      await _storageService.removeFavorite(venueId);
      favorites.removeWhere((favorite) => favorite.id == venueId);
    } else {
      final venue = await _venueRepository.getVenueById(venueId);
      if (venue != null) {
        await _storageService.addFavorite(venueId);
        favorites.add(FavoriteModel(
          id: venueId,
          venue: venue,
          createdAt: DateTime.now(),
        ));
      }
    }
  }
  
  Future<bool> isFavorite(int venueId) async {
    final favoriteIds = await _storageService.getFavorites();
    return favoriteIds.contains(venueId);
  }
}