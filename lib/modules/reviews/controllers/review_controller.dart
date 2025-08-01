import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/modules/reviews/services/review_service.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:get/get.dart';

class ReviewController extends GetxController {
  final ReviewService _reviewService = Get.find<ReviewService>();

  // Observable variables
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Form variables
  final RxInt rating = 0.obs;
  final TextEditingController commentController = TextEditingController();
  final RxBool isSubmitting = false.obs;

  // Venue and booking IDs
  final RxInt venueId = 0.obs;
  final RxInt bookingId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Get arguments from route
    if (Get.arguments != null) {
      if (Get.arguments['venueId'] != null) {
        venueId.value = Get.arguments['venueId'];
        loadReviewsByVenueId(venueId.value);
      }
      if (Get.arguments['bookingId'] != null) {
        bookingId.value = Get.arguments['bookingId'];
      }
    }
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  // Load reviews by venue ID
  Future<void> loadReviewsByVenueId(int id) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final reviewsData = await _reviewService.getReviewsByVenueId(id);
      reviews.assignAll(reviewsData);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error loading reviews: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Submit a new review
  Future<void> submitReview() async {
    if (rating.value == 0) {
      _showError('Please select a rating');
      return;
    }

    if (commentController.text.trim().isEmpty) {
      _showError('Please enter a comment');
      return;
    }

    if (bookingId.value == 0) {
      _showError('No booking selected');
      return;
    }

    try {
      isSubmitting.value = true;
      
      final review = await _reviewService.createReview(
        bookingId.value,
        rating.value,
        commentController.text.trim(),
      );

      if (review != null) {
        _showSuccess('Review submitted successfully');
        // Reset form
        rating.value = 0;
        commentController.clear();
        // Reload reviews if we're on a venue page
        if (venueId.value > 0) {
          await loadReviewsByVenueId(venueId.value);
        }
        Get.back();
      } else {
        _showError('Failed to submit review');
      }
    } catch (e) {
      // Tampilkan pesan error yang lebih detail
      String errorMessage = e.toString();
      if (errorMessage.contains('Booking tidak ditemukan')) {
        _showError('Booking tidak ditemukan');
      } else if (errorMessage.contains('Anda hanya dapat mereview booking milik Anda sendiri')) {
        _showError('Anda hanya dapat mereview booking milik Anda sendiri');
      } else if (errorMessage.contains('Anda hanya dapat mereview booking yang sudah selesai')) {
        _showError('Anda hanya dapat mereview booking yang sudah selesai');
      } else if (errorMessage.contains('Anda tidak dapat mereview booking yang dibatalkan')) {
        _showError('Anda tidak dapat mereview booking yang dibatalkan');
      } else if (errorMessage.contains('Anda hanya dapat mereview booking yang sudah dikonfirmasi')) {
        _showError('Anda hanya dapat mereview booking yang sudah dikonfirmasi');
      } else if (errorMessage.contains('Anda hanya dapat mereview booking yang sudah dibayar')) {
        _showError('Anda hanya dapat mereview booking yang sudah dibayar');
      } else if (errorMessage.contains('Anda sudah memberikan review untuk booking ini')) {
        _showError('Anda sudah memberikan review untuk booking ini');
      } else {
        _showError('Error: $errorMessage');
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  // Helper methods for showing messages
  void _showError(String message) {
    if (Get.context != null) {
      CustomSnackbar.show(
        context: Get.context!,
        message: message,
        type: SnackbarType.error,
      );
    }
  }

  void _showSuccess(String message) {
    if (Get.context != null) {
      CustomSnackbar.show(
        context: Get.context!,
        message: message,
        type: SnackbarType.success,
      );
    }
  }
}