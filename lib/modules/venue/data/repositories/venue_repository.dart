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
      print(' Error fetching venues: $e');
      return [];
    }
  }

  // Get venue by ID
  Future<VenueModel?> getVenueById(int id) async {
    try {
      final response = await _apiService.getRequest('/place/$id');

      if (response is Map<String, dynamic>) {
        return VenueModel.fromJson(response);
      }
    } catch (e) {
      print('Error fetching venue: $e');
      return null;
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
      // Ubah endpoint ke endpoint yang benar
      final response = await _apiService.getRequest('/place/$venueId/reviews');

      if (response is List) {
        return response.map((json) => ReviewModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load reviews. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching reviews for venue $venueId: $e');
      // Return empty list rather than throwing
      return [];
    }
  }

  Future<List<VenueModel>> searchAvailableVenues(
      Map<String, dynamic> searchParams) async {
    try {
      // Build query string from searchParams
      String queryString = '';
      if (searchParams.isNotEmpty) {
        final queryParts = searchParams.entries
            .where((entry) =>
                entry.value != null && entry.value.toString().isNotEmpty)
            .map((entry) =>
                '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}')
            .toList();

        if (queryParts.isNotEmpty) {
          queryString = '?${queryParts.join('&')}';
        }
      }

      final response =
          await _apiService.getRequest('/places/search$queryString');

      if (response is List) {
        return response.map((json) => VenueModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('Error searching available venues: $e');
      throw Exception('Failed to search venues: $e');
    }
  }

  // Get all cities
  Future<List<CityModel>> getCities() async {
    try {
      final response = await _apiService.getRequest('/city');
      if (response is List) {
        return response.map((json) => CityModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load cities. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cities: $e');
      return [];
    }
  }

  // Get all activities
  Future<List<CategoryModel>> getActivities() async {
    try {
      final response = await _apiService.getRequest('/activity');
      if (response is List) {
        return response.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        print('Invalid response format for activities: $response');
        return [];
      }
    } catch (e) {
      print('Error fetching activities: $e');
      return [];
    }
  }

  Future<List<FacilityModel>> getFacilities() async {
    try {
      final response = await _apiService.getRequest('/facility');
      if (response is List) {
        return response.map((json) => FacilityModel.fromJson(json)).toList();
      } else {
        print('Invalid response format for facilities: $response');
        return [];
      }
    } catch (e) {
      print('Error fetching facilities: $e');
      return [];
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiService.getRequest('/category');
      if (response is List) {
        return response.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        print('Invalid response format for categories: $response');
        return [];
      }
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // Testing method untuk debug ketiga endpoint
  Future<void> debugActivityFacilityCategory() async {
    print('=== DEBUG ACTIVITY, FACILITY, CATEGORY ===');

    try {
      // Test Activity
      final activities = await getActivities();
      print('Activities count: ${activities.length}');
      if (activities.isNotEmpty) {
        print('First activity: ${activities[0].toJson()}');
      }

      // Test Facility
      final facilities = await getFacilities();
      print('Facilities count: ${facilities.length}');
      if (facilities.isNotEmpty) {
        print('First facility: ${facilities[0].toJson()}');
      }

      // Test Category
      final categories = await getCategories();
      print('Categories count: ${categories.length}');
      if (categories.isNotEmpty) {
        print('First category: ${categories[0].toJson()}');
      }
    } catch (e) {
      print('Debug error: $e');
    }

    print('==========================================');
  }
}
