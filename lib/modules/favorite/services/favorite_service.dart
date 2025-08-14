import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/modules/favorite/models/favorite_model.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';

import 'package:dio/dio.dart' as dio;

class FavoriteService {
  final ApiService _apiService = ApiService();

  /// Toggle favorite status untuk venue tertentu
  /// Jika sudah favorite akan dihapus, jika belum akan ditambahkan
  Future<Map<String, dynamic>> toggleFavorite(String placeId) async {
    try {
      print('FavoriteService: Toggling favorite for place $placeId');
      final response = await _apiService.postRequest(
        '/favorites/$placeId/toggle',
        {},
      );

      if (response != null) {
        final result = Map<String, dynamic>.from(response);
        print(
            'FavoriteService: Toggle result for place $placeId - action: ${result['action']}, is_favorited: ${result['is_favorited']}');
        return result;
      } else {
        print(
            'FavoriteService: Empty response when toggling favorite for place $placeId');
        throw Exception('Failed to toggle favorite');
      }
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print(
            'FavoriteService: User not authenticated, cannot toggle favorite');
        throw Exception('Please log in to manage favorites');
      } else {
        print(
            'FavoriteService: DioException during toggle favorite: ${e.response?.statusCode} - ${e.response?.data}');
        throw Exception(
            'Failed to toggle favorite: ${e.response?.data?['detail'] ?? e.message}');
      }
    } catch (e) {
      print('FavoriteService: Error during toggle favorite: $e');
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  /// Menambahkan venue ke favorite
  Future<Map<String, dynamic>> addFavorite(String placeId) async {
    try {
      final response = await _apiService.postRequest(
        '/favorites/$placeId',
        {},
      );

      if (response != null) {
        return Map<String, dynamic>.from(response);
      } else {
        throw Exception('Failed to add favorite');
      }
    } on dio.DioException catch (e) {
      print(
          'FavoriteService: DioException during add favorite: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(
          'Failed to add favorite: ${e.response?.data?['detail'] ?? e.message}');
    } catch (e) {
      print('FavoriteService: Error during add favorite: $e');
      throw Exception('Failed to add favorite: $e');
    }
  }

  /// Menghapus venue dari favorite
  Future<Map<String, dynamic>> removeFavorite(String placeId) async {
    try {
      final response = await _apiService.deleteRequest('/favorites/$placeId');

      if (response != null) {
        return Map<String, dynamic>.from(response);
      } else {
        throw Exception('Failed to remove favorite');
      }
    } on dio.DioException catch (e) {
      print(
          'FavoriteService: DioException during remove favorite: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(
          'Failed to remove favorite: ${e.response?.data?['detail'] ?? e.message}');
    } catch (e) {
      print('FavoriteService: Error during remove favorite: $e');
      throw Exception('Failed to remove favorite: $e');
    }
  }

  /// Mengecek status favorite untuk venue tertentu
  Future<bool> checkFavoriteStatus(String placeId) async {
    try {
      print('FavoriteService: Checking favorite status for place $placeId');
      final response =
          await _apiService.getRequest('/favorites/$placeId/status');

      if (response != null && response['is_favorited'] != null) {
        final isFavorited = response['is_favorited'] as bool;
        print('FavoriteService: Place $placeId is favorited: $isFavorited');
        return isFavorited;
      } else {
        print('FavoriteService: Invalid response format for place $placeId');
        return false;
      }
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print(
            'FavoriteService: User not authenticated, cannot check favorite status');
      } else {
        print(
            'FavoriteService: DioException during check favorite status: ${e.response?.statusCode} - ${e.response?.data}');
      }
      return false;
    } catch (e) {
      print('FavoriteService: Error during check favorite status: $e');
      return false;
    }
  }

  /// Mendapatkan daftar favorite pengguna
  Future<List<FavoriteModel>> getFavorites(
      {int skip = 0, int limit = 100}) async {
    try {
      print(
          'FavoriteService: Getting favorites list with skip=$skip, limit=$limit');
      final response = await _apiService.getRequest(
        '/favorites?skip=$skip&limit=$limit',
      );

      if (response != null && response['favorites'] != null) {
        final List<dynamic> favoritesData = response['favorites'];
        print(
            'FavoriteService: Received ${favoritesData.length} favorites from backend');

        if (favoritesData.isEmpty) {
          print('FavoriteService: Empty favorites list returned from backend');
          return [];
        }

        final List<FavoriteModel> result = [];
        for (var favoriteJson in favoritesData) {
          try {
            final venueData = favoriteJson['place'];
            if (venueData == null) {
              print('FavoriteService: Missing place data in favorite item');
              continue;
            }

            final venue = VenueModel.fromJson(venueData);

            result.add(FavoriteModel(
              id: venue.id,
              venue: venue,
              createdAt: DateTime.parse(favoriteJson['created_at']),
            ));
          } catch (parseError) {
            print('FavoriteService: Error parsing favorite item: $parseError');
          }
        }

        print(
            'FavoriteService: Successfully parsed ${result.length} favorites');
        return result;
      } else {
        print(
            'FavoriteService: Invalid response format or empty favorites list');
        throw Exception('Invalid response format from server');
      }
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('FavoriteService: User not authenticated, cannot get favorites');
        throw Exception('Please log in to view favorites');
      } else if (e.response?.statusCode == 500) {
        print('FavoriteService: Server error (500) during get favorites');
        throw Exception('Server error occurred. Please try again later.');
      } else {
        print(
            'FavoriteService: DioException during get favorites: ${e.response?.statusCode} - ${e.response?.data}');
        throw Exception(
            'Failed to load favorites: ${e.response?.data?['detail'] ?? e.message}');
      }
    } catch (e) {
      print('FavoriteService: Error during get favorites: $e');
      throw Exception('Failed to load favorites: $e');
    }
  }

  /// Mendapatkan jumlah favorite untuk venue tertentu
  Future<int> getPlaceFavoritesCount(String placeId) async {
    try {
      final response =
          await _apiService.getRequest('/place/$placeId/favorites/count');

      if (response != null && response['favorites_count'] != null) {
        return response['favorites_count'] as int;
      } else {
        return 0;
      }
    } on dio.DioException catch (e) {
      print(
          'FavoriteService: DioException during get place favorites count: ${e.response?.statusCode} - ${e.response?.data}');
      return 0;
    } catch (e) {
      print('FavoriteService: Error during get place favorites count: $e');
      return 0;
    }
  }
}
