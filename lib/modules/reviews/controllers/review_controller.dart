import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/modules/reviews/models/review_model.dart';
import 'package:function_mobile/modules/reviews/services/review_service.dart';
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
  final RxBool isEditMode = false.obs;
  final Rx<ReviewModel?> currentReview = Rx<ReviewModel?>(null);

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
      if (Get.arguments['reviewId'] != null) {
        int reviewId = Get.arguments['reviewId'];
        loadReviewForEdit(reviewId);
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

  // Load review for editing
  Future<void> loadReviewForEdit(int reviewId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      isEditMode.value = true;

      // Assuming we can get a single review by ID
      // If not available, you might need to add this method to your service
      final reviewData = await _reviewService.getReviewById(reviewId);

      if (reviewData != null) {
        currentReview.value = reviewData;
        // Pre-fill form with existing data
        rating.value = reviewData.rating;
        commentController.text = reviewData.comment ?? '';
      } else {
        hasError.value = true;
        errorMessage.value = 'Review not found';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error loading review: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Submit a new review or update existing one
  Future<void> submitReview() async {
    if (rating.value == 0) {
      _showError('Please select a rating');
      return;
    }

    if (commentController.text.trim().isEmpty) {
      _showError('Please enter a comment');
      return;
    }

    if (!isEditMode.value && bookingId.value == 0) {
      _showError('No booking selected');
      return;
    }

    try {
      isSubmitting.value = true;

      ReviewModel? review;

      if (isEditMode.value && currentReview.value != null) {
        // Update existing review
        review = await _reviewService.updateReview(
          currentReview.value!.id,
          currentReview.value!.bookingId,
          rating.value,
          commentController.text.trim(),
        );
        if (review != null) {
          _showSuccess('Review updated successfully');
        }
      } else {
        // Create new review
        review = await _reviewService.createReview(
          bookingId.value,
          rating.value,
          commentController.text.trim(),
        );
        if (review != null) {
          _showSuccess('Review submitted successfully');
        }
      }

      if (review != null) {
        // Reset form
        rating.value = 0;
        commentController.clear();
        isEditMode.value = false;
        currentReview.value = null;

        // Reload reviews if we're on a venue page
        if (venueId.value > 0) {
          await loadReviewsByVenueId(venueId.value);
        }
        Get.back();
      } else {
        _showError(isEditMode.value
            ? 'Failed to update review'
            : 'Failed to submit review');
      }
    } catch (e) {
      // Tampilkan pesan error yang lebih detail
      String errorMessage = e.toString();
      if (errorMessage.contains('Booking tidak ditemukan')) {
        _showError('Booking tidak ditemukan');
      } else if (errorMessage
          .contains('Anda hanya dapat mereview booking milik Anda sendiri')) {
        _showError('Anda hanya dapat mereview booking milik Anda sendiri');
      } else if (errorMessage
          .contains('Anda hanya dapat mereview booking yang sudah selesai')) {
        _showError('Anda hanya dapat mereview booking yang sudah selesai');
      } else if (errorMessage
          .contains('Anda tidak dapat mereview booking yang dibatalkan')) {
        _showError('Anda tidak dapat mereview booking yang dibatalkan');
      } else if (errorMessage.contains(
          'Anda hanya dapat mereview booking yang sudah dikonfirmasi')) {
        _showError('Anda hanya dapat mereview booking yang sudah dikonfirmasi');
      } else if (errorMessage
          .contains('Anda hanya dapat mereview booking yang sudah dibayar')) {
        _showError('Anda hanya dapat mereview booking yang sudah dibayar');
      } else if (errorMessage
          .contains('Anda sudah memberikan review untuk booking ini')) {
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
