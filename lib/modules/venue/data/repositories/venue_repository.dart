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
        throw Exception('Failed to load venues. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Log error
      print('Error fetching venues: $e');
      // Return empty list rather than throwing
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
  
  // Get venue reviews
  Future<List<ReviewModel>> getVenueReviews(int venueId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/review?venue_id=$venueId'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ReviewModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reviews. Status: ${response.statusCode}');
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
      final response = await http.get(Uri.parse('$baseUrl/api/facility?venue_id=$venueId'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => FacilityModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load facilities. Status: ${response.statusCode}');
      }
    } catch (e) {
      // Log error
      print('Error fetching facilities for venue $venueId: $e');
      // Return empty list rather than throwing
      return [];
    }
  }
}