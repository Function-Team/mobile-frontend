import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';

class VenueRepository {
  static const String baseUrl = 'http://backend.thefunction.id';

  // Get all venues
  Future<List<VenueModel>> getVenues() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/place'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => VenueModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load venues. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching venues: $e');
      return [];
    }
  }

  // Get venue by ID
  Future<VenueModel?> getVenueById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/place/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return VenueModel.fromJson(data);
      } else {
        throw Exception('Failed to load venue. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Log error
      print('Error fetching venue with id $id: $e');
      // Return null rather than throwing
      return null;
    }
  }

  //Get venue image
  Future<List<PictureModel>> getVenueImages(int venueId) async {
    try {
      final url = '$baseUrl/api/img?place_id=$venueId';
      print('Fetching images URL: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'accept': 'application/json'},
      );
      print('Response status: ${response.statusCode}, body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PictureModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'failed to load images. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching images for venue $venueId: $e');
      return [];
    }
  }

  Future<List<VenueModel>> searchVenues(
    {String? searchQuery,
    int? categoryId,
    int? cityId,
    int? minPrice,
    int? maxPrice,
    int? minCapacity,
    bool? sortByPrice,
    bool? reverseSort}) async {
      
  try {
    final queryParams = <String, String>{};

    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams['search'] = searchQuery;
    }
    if (categoryId != null) {
      queryParams['category_id'] = categoryId.toString();
    }
    if (cityId != null) {
      queryParams['city_id'] = cityId.toString();
    }
    if (minPrice != null) {
      queryParams['min_price'] = minPrice.toString();
    }
    if (maxPrice != null) {
      queryParams['max_price'] = maxPrice.toString();
    }
    if (sortByPrice != null) {
      queryParams['sort_price'] = sortByPrice.toString();
    }
    if (minCapacity != null) {
      queryParams['min_capacity'] = minCapacity.toString();
    }
    if (reverseSort != null) {
      queryParams['reverse'] = reverseSort.toString();
    }
    final uri =
        Uri.parse('$baseUrl/api/place').replace(queryParameters: queryParams);
    print('Searching venues with URL: $uri');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => VenueModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search venues. Status ${response.statusCode}');
    }
  } catch (e) {
    print('error searching venues :$e');
    return [];
  }
}

  // Get venue reviews
  Future<List<ReviewModel>> getVenueReviews(int venueId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/review?venue_id=$venueId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ReviewModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load reviews. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Log error
      print('Error fetching reviews for venue $venueId: $e');
      // Return empty list rather than throwing
      return [];
    }
  }

  // Get venue facilities
  Future<List<FacilityModel>> getVenueFacilities(int venueId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/facility?venue_id=$venueId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => FacilityModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load facilities. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Log error
      print('Error fetching facilities for venue $venueId: $e');
      // Return empty list rather than throwing
      return [];
    }
  }
}