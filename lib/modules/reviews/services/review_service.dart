import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/modules/reviews/models/review_model.dart';
import 'package:get/get.dart';

class ReviewService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  // Get reviews by venue ID
  // Get reviews by venue ID
  Future<List<ReviewModel>> getReviewsByVenueId(int venueId) async {
    try {
      // Ubah endpoint ke endpoint yang benar
      final response = await _apiService.getRequest('/place/$venueId/reviews');

      if (response is List) {
        return response.map((json) => ReviewModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  // Get reviews by user ID
  Future<List<ReviewModel>> getReviewsByUserId(int userId) async {
    try {
      final response = await _apiService.getRequest('/review?user_id=$userId');

      if (response is List) {
        return response.map((json) => ReviewModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching user reviews: $e');
      return [];
    }
  }

  // Get a single review by ID
  Future<ReviewModel?> getReviewById(int reviewId) async {
    try {
      final response = await _apiService.getRequest('/review/$reviewId');
      return ReviewModel.fromJson(response);
    } catch (e) {
      print('Error fetching review: $e');
      return null;
    }
  }

  // Create a new review
  Future<ReviewModel?> createReview(
      int bookingId, int rating, String comment) async {
    try {
      final data = {
        'booking_id': bookingId,
        'rating': rating,
        'comment': comment
      };

      final response = await _apiService.postRequest('/review', data);
      return ReviewModel.fromJson(response);
    } catch (e) {
      print('Error creating review: $e');
      return null;
    }
  }

  // Update an existing review
  Future<ReviewModel?> updateReview(
      int reviewId, int bookingId, int rating, String comment) async {
    try {
      final data = {
        'booking_id': bookingId,
        'rating': rating, 
        'comment': comment
      };

      final response = await _apiService.putRequest('/review/$reviewId', data);
      return ReviewModel.fromJson(response);
    } catch (e) {
      print('Error updating review: $e');
      return null;
    }
  }

  // Delete a review
  Future<bool> deleteReview(int reviewId) async {
    try {
      await _apiService.deleteRequest('/review/$reviewId');
      return true;
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }

  // Check review eligibility for a booking
  Future<Map<String, dynamic>> checkReviewEligibility(int bookingId) async {
    try {
      final response = await _apiService
          .getRequest('/booking/$bookingId/review-eligibility');
      return response;
    } catch (e) {
      print('Error checking review eligibility: $e');
      return {
        'eligible': false,
        'message': 'Terjadi kesalahan saat memeriksa eligibilitas review'
      };
    }
  }
}
