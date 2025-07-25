import 'dart:async';

import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/modules/booking/controllers/booking_list_controller.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/booking/services/booking_service.dart';
import 'package:get/get.dart';

class BookingDetailController extends GetxController {
  final BookingService _bookingService = BookingService();

  // State management
  final Rx<BookingModel?> booking = Rx<BookingModel?>(null);
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Action states
  final RxBool isConfirming = false.obs;
  final RxBool isCancelling = false.obs;

  int? bookingId;

  @override
  void onInit() {
    super.onInit();
    bookingId = int.tryParse(Get.arguments?.toString() ?? '');
    if (bookingId != null) {
      fetchBookingDetail();
      startStatusCheckTimer(); // Start auto-refresh
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

  Future<void> fetchBookingDetail() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final fetchedBooking = await _bookingService.getBookingById(bookingId!);

      if (fetchedBooking != null) {
        booking.value = fetchedBooking;
      } else {
        hasError.value = true;
        errorMessage.value = 'Booking not found';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load booking details: ${e.toString()}';
      print('Error fetching booking detail: $e');
    } finally {
      isLoading.value = false;
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
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to cancel this booking?'),
            const SizedBox(height: 8),
            Text(
              'Venue: ${booking.value?.place?.name ?? 'Unknown'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              'Date: ${booking.value?.formattedDate ?? 'Unknown'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Important:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• This action cannot be undone\n• Refund policy may apply\n• Contact venue owner for details',
                    style: TextStyle(
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
            child: const Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              cancelBooking();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
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

  void shareBooking() {
    if (booking.value != null) {
      // Implement sharing functionality
      final bookingInfo = '''
Booking Details:
Venue: ${booking.value!.place?.name ?? 'Unknown'}
Date: ${booking.value!.formattedDate}
Time: ${booking.value!.formattedTimeRange}
Status: ${isBookingCompleted ? 'Completed' : booking.value!.statusDisplayName}
Booking ID: #${booking.value!.id}
${isBookingCompleted ? 'Payment: Paid' : ''}
      ''';

      // You can use the share_plus package here
      // Share.share(bookingInfo);

      _showSuccess('Booking details copied to clipboard');
    }
  }

  void downloadBookingReceipt() {
    if (!isBookingCompleted) {
      _showError('Receipt only available for completed bookings');
      return;
    }
    // Implement PDF generation and download
    _showSuccess('Receipt download started');
  }

  Future<void> refreshBookingDetail() async {
    if (bookingId != null) {
      try {
        isLoading.value = true;
        hasError.value = false;
        errorMessage.value = '';

        final fetchedBooking = await _bookingService.getBookingById(bookingId!);

        if (fetchedBooking != null) {
          // Update with new status
          booking.value = fetchedBooking;

          // Show a notification if status has changed since last check
          if (booking.value?.isConfirmed == true &&
              booking.value?.status == BookingStatus.confirmed) {
            _showSuccess('Your booking has been confirmed by the venue!');
          }
          
          // Check if payment was completed
          if (isBookingCompleted && booking.value?.payment != null) {
            _showSuccess('Payment completed successfully!');
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
        !isConfirming.value &&
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
        !isConfirming.value &&
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
}