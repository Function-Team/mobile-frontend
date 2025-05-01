import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheService {
  final SharedPreferences _prefs;

  CacheService(this._prefs);

  Future<void> cacheVenues(List<VenueModel> venues) async {
    final venuesJson = venues.map((v) => v.toJson()).toList();
    await _prefs.setString('cached_venues', jsonEncode(venuesJson));
  }

  Future<List<VenueModel>> getCachedVenues() async {
    final venuesString = _prefs.getString('cached_venues');
    if (venuesString == null) return [];

    final venuesJson = jsonDecode(venuesString) as List;
    return venuesJson.map((json) => VenueModel.fromJson(json)).toList();
  }
}
