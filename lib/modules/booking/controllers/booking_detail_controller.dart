import 'dart:async';
import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/booking/controllers/booking_list_controller.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/booking/services/booking_service.dart';
import 'package:function_mobile/modules/reviews/models/review_model.dart';
import 'package:function_mobile/modules/reviews/services/review_service.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart'
    as venue_models;
import 'package:function_mobile/modules/venue/services/whatsapp_contact_service.dart';
import 'package:get/get.dart';

class BookingDetailController extends GetxController {
  final BookingService _bookingService = BookingService();

  // State management
  final Rx<BookingModel?> booking = Rx<BookingModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Action states
  final RxBool isCancelling = false.obs;

  int? bookingId;

  @override
  void onInit() {
    super.onInit();
    bookingId = int.tryParse(Get.arguments?.toString() ?? '');
    if (bookingId != null) {
      loadBookingDetails();
    } else {
      hasError.value = true;
      errorMessage.value = 'Invalid booking ID';
      isLoading.value = false;
    }
  }

  // Check if booking is completed
  bool get isBookingCompleted {
    if (booking.value == null) return false;
    return booking.value!.isConfirmed && booking.value!.isPaid;
  }

  // Check if booking has been reviewed
  bool get hasBeenReviewed {
    if (booking.value == null) return false;
    return booking.value!.reviews != null && booking.value!.reviews!.isNotEmpty;
  }

  // Check if booking is eligible for review based on backend validation rules
  final RxBool isEligibleForReview = false.obs;
  final RxString eligibilityMessage = ''.obs;

  // Periksa eligibilitas review dari backend
  Future<void> checkReviewEligibility() async {
    if (booking.value == null || bookingId == null) return;

    try {
      // Import service
      final reviewService = Get.find<ReviewService>();

      // Panggil endpoint eligibilitas
      final response = await reviewService.checkReviewEligibility(bookingId!);

      // Update state berdasarkan response
      isEligibleForReview.value = response['eligible'] ?? false;
      eligibilityMessage.value = response['message'] ?? '';

      // Jika ada review_id, berarti sudah ada review
      if (response.containsKey('review_id')) {
        // Jangan reload booking details karena akan menyebabkan infinite loop
        // Cukup update status hasBeenReviewed secara manual
        if (booking.value != null &&
            (booking.value!.reviews == null ||
                booking.value!.reviews!.isEmpty)) {
          // Tambahkan review kosong ke booking untuk menandai bahwa sudah ada review
          final reviewId = response['review_id'];
          if (reviewId != null) {
            print('Review found with ID: $reviewId, updating booking model');

            // Coba ambil review lengkap dari API
            try {
              final reviewData = await reviewService.getReviewById(reviewId);
              if (reviewData != null) {
                // Update booking model dengan review lengkap
                booking.value = booking.value!.copyWith(
                  reviews: [reviewData],
                );
                return;
              }
            } catch (e) {
              print('Error fetching review: $e');
            }

            // Fallback ke dummy review jika gagal mengambil review lengkap
            final dummyReview = ReviewModel(
              id: reviewId,
              bookingId: bookingId!,
              userId: booking.value!.userId,
              rating: 0, // Nilai ini akan diupdate saat review diambil
              comment: '', // Nilai ini akan diupdate saat review diambil
              createdAt: DateTime.now(),
            );

            // Update booking model dengan review
            booking.value = booking.value!.copyWith(
              reviews: [dummyReview],
            );
          }
        }
      }
    } catch (e) {
      print('Error checking review eligibility: $e');
      isEligibleForReview.value = false;
      eligibilityMessage.value =
          'Terjadi kesalahan saat memeriksa eligibilitas review';
    }
  }

  Future<void> loadBookingDetails() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      print("🔍 Loading booking details for ID: $bookingId");

      final result = await _bookingService.getBookingById(bookingId!);
      if (result != null) {
        print("📦 Raw booking data: ${result.place?.name ?? result.placeName}");

        // Apply enrichment like in BookingCard if needed
        BookingModel enrichedBooking = result;
        if (_needsPlaceEnrichment(result)) {
          print("Enriching booking with place details...");
          enrichedBooking = await _enrichBookingWithPlaceDetails(result);
        }

        booking.value = enrichedBooking;
        print(
            "Booking loaded: ${enrichedBooking.place?.name ?? enrichedBooking.placeName}");
        print("📍 Address: ${enrichedBooking.place?.address ?? 'No address'}");

        // Check review eligibility after loading booking details
        await checkReviewEligibility();
      } else {
        hasError.value = true;
        errorMessage.value = 'Booking not found';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load booking details: ${e.toString()}';
      print('Error loading booking detail: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods for place enrichment (same as BookingService)
  bool _needsPlaceEnrichment(BookingModel booking) {
    return booking.place == null ||
        booking.place?.address == null ||
        booking.place!.address!.isEmpty;
  }

  Future<BookingModel> _enrichBookingWithPlaceDetails(
      BookingModel booking) async {
    try {
      final apiService = Get.find<ApiService>();
      final placeResponse =
          await apiService.getRequest('/place/${booking.placeId}');
      print(
          'Fetched place details for booking ${booking.id}: ${placeResponse['name']}');

      final venueModel = venue_models.VenueModel.fromJson(placeResponse);
      return booking.copyWith(place: venueModel);
    } catch (e) {
      print('Error enriching booking ${booking.id} with place details: $e');
      return booking;
    }
  }

  Future<void> cancelBooking() async {
    if (booking.value == null) return;

    // Don't allow cancellation for completed bookings
    if (isBookingCompleted) {
      _showError('Cannot cancel a completed booking');
      return;
    }

    try {
      isCancelling.value = true;

      await _bookingService.cancelBooking(booking.value!.id);

      // Update booking list
      if (Get.isRegistered<BookingListController>()) {
        final bookingListController = Get.find<BookingListController>();
        bookingListController.fetchBookings();
      }

      _showSuccess('Booking cancelled successfully!');

      // Navigate back after a short delay
      await Future.delayed(const Duration(seconds: 1));
      Get.back();
    } catch (e) {
      _showError('Failed to cancel booking: ${e.toString()}');
    } finally {
      isCancelling.value = false;
    }
  }

  void showCancelConfirmationDialog() {
    // Don't show cancel dialog for completed bookings
    if (isBookingCompleted) {
      _showError('Cannot cancel a completed booking');
      return;
    }
    Get.dialog(
      AlertDialog(
        title: Text(LocalizationHelper.tr(LocaleKeys.booking_cancelBooking)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocalizationHelper.tr(
                LocaleKeys.booking_cancelConfirmationMessage)),
            const SizedBox(height: 8),
            Text(
              LocalizationHelper.trArgs(LocaleKeys.booking_venueInfo, {
                'venueName': booking.value?.place?.name ??
                    LocalizationHelper.tr(LocaleKeys.common_unknown)
              }),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              LocalizationHelper.trArgs(LocaleKeys.booking_dateInfo, {
                'date': booking.value?.formattedDate ??
                    LocalizationHelper.tr(LocaleKeys.common_unknown)
              }),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationHelper.tr(LocaleKeys.common_important),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    LocalizationHelper.tr(LocaleKeys.booking_cancelWarningText),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(LocalizationHelper.tr(LocaleKeys.booking_keepBooking)),
          ),
          TextButton(
            onPressed: () {
              cancelBooking();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(LocalizationHelper.tr(LocaleKeys.booking_yesCancel)),
          ),
        ],
      ),
    );
  }

  void viewVenueDetails() {
    if (booking.value?.place?.id != null) {
      Get.toNamed(MyRoutes.venueDetail, arguments: {
        'venueId': booking.value!.place!.id,
      });
    }
  }

  Future<void> refreshBookingDetail() async {
    if (bookingId != null) {
      try {
        isLoading.value = true;
        hasError.value = false;
        errorMessage.value = '';

        final fetchedBooking = await _bookingService.getBookingById(bookingId!);

        if (fetchedBooking != null) {
          booking.value = fetchedBooking;
          await checkReviewEligibility();
          if (booking.value?.isConfirmed == true &&
              booking.value?.status == BookingStatus.confirmed) {
            _showSuccess('Your booking has been confirmed by the venue!');
          }

          // Check if payment was completed
          if (isBookingCompleted && booking.value?.payment != null) {
            _showSuccess('Payment completed successfully!');
            print('🔍 Payment status: ${booking.value!.payment!.status}');
            print('🔍 Payment_status field: ${booking.value!.paymentStatus}');
            print('🔍 isPaid result: ${booking.value!.isPaid}');
          }
        } else {
          // If booking is null, it might have been cancelled by admin
          hasError.value = true;
          errorMessage.value = 'Booking may have been cancelled by the venue.';
          _showError(
              'This booking has been cancelled by the venue administrator.');
        }
      } catch (e) {
        hasError.value = true;
        errorMessage.value =
            'Failed to refresh booking details: ${e.toString()}';
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Auto-refresh timer to check for status updates
  void startStatusCheckTimer() {
    // Check every 30 seconds for updates
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (Get.currentRoute.contains(MyRoutes.bookingDetail)) {
        refreshBookingDetail();
      } else {
        // Stop timer if we navigate away
        timer.cancel();
      }
    });
  }

  bool get canCancel {
    if (booking.value == null) return false;

    // Cannot cancel completed bookings
    if (isBookingCompleted) return false;

    final now = DateTime.now();
    final bookingDateTime = booking.value!.startDateTime;

    return (booking.value!.status == BookingStatus.pending ||
            booking.value!.status == BookingStatus.confirmed) &&
        bookingDateTime.isAfter(now) &&
        !isCancelling.value;
  }

  bool get canReschedule {
    if (booking.value == null) return false;

    // Cannot reschedule completed bookings
    if (isBookingCompleted) return false;

    final now = DateTime.now();
    final bookingDateTime = booking.value!.startDateTime;

    return (booking.value!.status == BookingStatus.confirmed ||
            booking.value!.status == BookingStatus.pending) &&
        bookingDateTime.isAfter(
            now.add(const Duration(hours: 24))) && // At least 24 hours notice
        !isCancelling.value;
  }

  bool get isPastBooking {
    if (booking.value == null) return false;

    final now = DateTime.now();
    final bookingEndDateTime = booking.value!.endDateTime;

    return bookingEndDateTime.isBefore(now) && !isBookingCompleted;
  }

  String get timeUntilBooking {
    if (booking.value == null) return '';

    // Show payment status for completed bookings
    if (isBookingCompleted) {
      return 'Booking completed - Paid';
    }

    final now = DateTime.now();
    final bookingDateTime = booking.value!.startDateTime;

    if (bookingDateTime.isBefore(now)) {
      return 'Past booking';
    }

    final difference = bookingDateTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} to go';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} to go';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} to go';
    }
  }

  Map<String, dynamic> get bookingSummary {
    if (booking.value?.place == null) return {};

    final venue = booking.value!.place!;
    final duration = booking.value!.duration;
    final basePrice = venue.price?.toDouble() ?? 0.0;

    // Calculate pricing
    final hours = duration.inHours + (duration.inMinutes % 60) / 60.0;
    final subtotal = basePrice * hours;
    final tax = subtotal * 0.10; // 10% tax
    final serviceFee = 25000.0; // Fixed service fee
    final total = subtotal + tax + serviceFee;

    return {
      'base_price': basePrice,
      'hours': hours,
      'subtotal': subtotal,
      'tax': tax,
      'service_fee': serviceFee,
      'total': total,
      'duration_text': _formatDuration(duration),
      'is_paid': isBookingCompleted,
      'payment_status': booking.value?.payment?.status ?? 'pending',
      'payment_amount': booking.value?.payment?.amount ?? 0,
    };
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      if (minutes > 0) {
        return '$hours hour${hours > 1 ? 's' : ''} $minutes minute${minutes > 1 ? 's' : ''}';
      } else {
        return '$hours hour${hours > 1 ? 's' : ''}';
      }
    } else {
      return '$minutes minute${minutes > 1 ? 's' : ''}';
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

  void _showError(String message) {
    if (Get.context != null) {
      CustomSnackbar.show(
        context: Get.context!,
        message: message,
        type: SnackbarType.error,
      );
    }
  }

  //whatsapp
  Future<void> contactHost() async {
    WhatsAppContactService.contactHostFromBooking(booking: booking.value!);
  }

  void proceedToPayment(BookingModel booking) {
    // Navigate to payment page
    Get.toNamed('/payment', arguments: booking);
  }

  Future<void> navigateToReviewForm(BookingModel booking) async {
    // Jika sudah ada review, langsung navigasi ke form edit
    if (booking.reviews != null && booking.reviews!.isNotEmpty) {
      final Map<String, dynamic> arguments = {
        'bookingId': booking.id,
        'venueId': booking.placeId,
        'reviewId': booking.reviews!.first.id
      };

      Get.toNamed(MyRoutes.reviewForm, arguments: arguments);
      return;
    }

    // Jika belum ada review, periksa eligibilitas review terlebih dahulu
    await checkReviewEligibility();

    // Gunakan hasil dari endpoint eligibilitas
    if (!isEligibleForReview.value) {
      // Tampilkan pesan error dari backend
      _showError(eligibilityMessage.value);
      return;
    }

    // Jika eligible untuk review baru
    final Map<String, dynamic> arguments = {
      'bookingId': booking.id,
      'venueId': booking.placeId,
    };

    Get.toNamed(MyRoutes.reviewForm, arguments: arguments);
  }
}
