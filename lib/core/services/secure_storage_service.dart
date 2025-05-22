import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:function_mobile/core/constants/app_constants.dart';
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

  Future<void> saveFavorites(List<int> favoriteIds) async {
    await _storage.write(key: 'favorites', value: jsonEncode(favoriteIds));
  }

  Future<List<int>> getFavorites() async {
    final favoritesJson = await _storage.read(key: 'favorites');
    if (favoritesJson == null) return [];
    return List<int>.from(jsonDecode(favoritesJson));
  }

  Future<void> addFavorite(int venueId) async {
    final favorites = await getFavorites();
    if (!favorites.contains(venueId)) {
      favorites.add(venueId);
      await saveFavorites(favorites);
    }
  }

  Future<void> removeFavorite(int venueId) async {
    final favorites = await getFavorites();
    favorites.remove(venueId);
    await saveFavorites(favorites);
  }
  // Tambahkan method ini ke SecureStorageService
Future<void> saveUserData(User user) async {
  final jsonData = jsonEncode(user.toJson());
  await _storage.write(key: AppConstants.userKey, value: jsonData);
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
}
