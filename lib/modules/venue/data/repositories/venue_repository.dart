import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';

class VenueRepository {
  static final ApiService _apiService = ApiService();

  // Get all venues
  Future<List<VenueModel>> getVenues() async {
    try {
      final response = await _apiService.getRequest('/place');
      if (response is List) {
        return response.map((json) => VenueModel.fromJson(json)).toList();
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
      final response = await _apiService.getRequest('/place/$id');

      if (response is Map<String, dynamic>) {
        return VenueModel.fromJson(response);
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
      final response = await _apiService.getRequest('/img?place_id=$venueId');
      print('Response for venue images: $response');

      if (response is List) {
        final images =
            response.map((json) => PictureModel.fromJson(json)).toList();

        // Tambahkan log untuk debugging
        for (var img in images) {
          print('Image filename: ${img.filename}, URL: ${img.imageUrl}');
        }

        return images;
      } else {
        print('Invalid response format for images: $response');
        return [];
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

      // Bangun query string manual
      String queryString = '';
      if (queryParams.isNotEmpty) {
        queryString =
            '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      }

      final endpoint = '/place$queryString';
      print('Searching venues with endpoint: $endpoint');

      final response = await _apiService.getRequest(endpoint);

      if (response is List) {
        return response.map((json) => VenueModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to search venues. Status ${response.statusCode}');
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
          await _apiService.getRequest('/review?venue_id=$venueId');

      if (response is List) {
        return response.map((json) => ReviewModel.fromJson(json)).toList();
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
          await _apiService.getRequest('/facility?venue_id=$venueId');

      if (response is List) {
        return response.map((json) => FacilityModel.fromJson(json)).toList();
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
