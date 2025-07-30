import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:function_mobile/core/constant/app_constant.dart';

import 'dart:convert';

import 'package:function_mobile/modules/auth/models/auth_model.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

    Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
  }

  // Refresh token management
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.tokenKey, value: accessToken),
      _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<void> deleteTokens() async {
    await Future.wait([
      _storage.delete(key: AppConstants.tokenKey),
      _storage.delete(key: AppConstants.refreshTokenKey),
    ]);
  }

  // User-specific favorites methods
  String _getFavoritesKeyForUser(int userId) {
    return 'favorites_user_$userId';
  }

  Future<void> saveFavorites(List<int> favoriteIds, int userId) async {
    final key = _getFavoritesKeyForUser(userId);
    await _storage.write(key: key, value: jsonEncode(favoriteIds));
  }

  Future<List<int>> getFavorites(int userId) async {
    final key = _getFavoritesKeyForUser(userId);
    final favoritesJson = await _storage.read(key: key);
    if (favoritesJson == null) return [];

    try {
      return List<int>.from(jsonDecode(favoritesJson));
    } catch (e) {
      print('Error parsing favorites for user $userId: $e');
      return [];
    }
  }

  Future<void> addFavorite(int venueId, int userId) async {
    final favorites = await getFavorites(userId);
    if (!favorites.contains(venueId)) {
      favorites.add(venueId);
      await saveFavorites(favorites, userId);
    }
  }

  Future<void> removeFavorite(int venueId, int userId) async {
    final favorites = await getFavorites(userId);
    favorites.remove(venueId);
    await saveFavorites(favorites, userId);
  }

  // Clear favorites for a specific user (useful when user logs out)
  Future<void> clearFavoritesForUser(int userId) async {
    final key = _getFavoritesKeyForUser(userId);
    await _storage.delete(key: key);
  }

  // Clear all user-specific data (useful for complete logout)
  Future<void> clearAllUserData() async {
    // Get all keys
    final allKeys = await _storage.readAll();

    // Delete all user-specific keys (favorites_user_*)
    for (String key in allKeys.keys) {
      if (key.startsWith('favorites_user_')) {
        await _storage.delete(key: key);
      }
    }

    // Also clear user data and token
    await _storage.delete(key: AppConstants.userKey);
    await _storage.delete(key: AppConstants.tokenKey);  
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  // Migrate old favorites to user-specific storage (run once when user logs in)
  Future<void> migrateFavoritesToUser(int userId) async {
    try {
      // Check if old favorites exist
      final oldFavoritesJson = await _storage.read(key: 'favorites');
      if (oldFavoritesJson != null) {
        final oldFavorites = List<int>.from(jsonDecode(oldFavoritesJson));

        // Save to user-specific storage
        await saveFavorites(oldFavorites, userId);

        // Delete old storage
        await _storage.delete(key: 'favorites');

        print('Migrated ${oldFavorites.length} favorites for user $userId');
      }
    } catch (e) {
      print('Error migrating favorites: $e');
    }
  }

  // User data methods
  Future<void> saveUserData(User user) async {
    final jsonData = jsonEncode(user.toJson());
    await _storage.write(key: AppConstants.userKey, value: jsonData);

    // Migrate old favorites when user data is saved
    await migrateFavoritesToUser(user.id);
  }

  Future<User?> getUserData() async {
    final jsonData = await _storage.read(key: AppConstants.userKey);
    if (jsonData == null) return null;

    try {
      return User.fromJson(jsonDecode(jsonData));
    } catch (e) {
      print('Error parsing user data: $e');
      return null;
    }
  }

  // Get current user ID (helper method)
  Future<int?> getCurrentUserId() async {
    final user = await getUserData();
    return user?.id;
  }

  // Method to check if favorites exist for current user
  Future<bool> hasFavoritesForCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId == null) return false;

    final favorites = await getFavorites(userId);
    return favorites.isNotEmpty;
  }

  Future<bool> hasValidTokens() async{
    final accessToken = await getToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  // Debug method to list all stored data
   Future<void> debugPrintAllData() async {
    final allData = await _storage.readAll();
    print('=== Secure Storage Debug ===');
    for (var entry in allData.entries) {
      if (entry.key.startsWith('favorites_user_')) {
        try {
          final favorites = List<int>.from(jsonDecode(entry.value));
          print('${entry.key}: ${favorites.length} favorites');
        } catch (e) {
          print('${entry.key}: Invalid data');
        }
      } else if (entry.key == AppConstants.tokenKey) {
        print('Access Token: ${entry.value.length} characters');
      } else if (entry.key == AppConstants.refreshTokenKey) {
        print('Refresh Token: ${entry.value.length} characters');
      } else {
        print('${entry.key}: ${entry.value.length} characters');
      }
    }
    print('===========================');
  }
}
