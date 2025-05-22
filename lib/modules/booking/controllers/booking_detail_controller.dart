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
    } else {
      hasError.value = true;
      errorMessage.value = 'Invalid booking ID';
      isLoading.value = false;
    }
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

  Future<void> confirmBooking() async {
    if (booking.value == null) return;

    try {
      isConfirming.value = true;
      
      final confirmedBooking = await _bookingService.confirmBooking(booking.value!.id);
      booking.value = confirmedBooking;
      
      // Update booking list
      final bookingListController = Get.find<BookingListController>();
      bookingListController.fetchBookings();
      
      _showSuccess('Booking confirmed successfully!');
    } catch (e) {
      _showError('Failed to confirm booking: ${e.toString()}');
    } finally {
      isConfirming.value = false;
    }
  }

  Future<void> cancelBooking() async {
    if (booking.value == null) return;

    try {
      isCancelling.value = true;
      
      await _bookingService.cancelBooking(booking.value!.id);
      
      // Update booking list
      final bookingListController = Get.find<BookingListController>();
      bookingListController.fetchBookings();
      
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

  // void contactVenueOwner() {
  //   if (booking.value?.place?.host?.user?.id != null) {
  //     // Navigate to chat with venue owner
  //     Get.toNamed(MyRoutes., arguments: {
  //       'hostId': booking.value!.place!.host!.user!.id,
  //       'venueName': booking.value!.place!.name,
  //     });
  //   } else {
  //     _showError('Unable to contact venue owner at this time');
  //   }
  // }

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
Status: ${booking.value!.statusDisplayName}
Booking ID: #${booking.value!.id}
      ''';
      
      // You can use the share_plus package here
      // Share.share(bookingInfo);
      
      _showSuccess('Booking details copied to clipboard');
    }
  }

  // void rescheduleBooking() {
  //   if (booking.value != null) {
  //     // Navigate to reschedule page with current booking data
  //     Get.toNamed('/reschedule-booking', arguments: booking.value);
  //   }
  // }

  void downloadBookingReceipt() {
    // Implement PDF generation and download
    _showSuccess('Receipt download started');
  }

  Future<void> refreshBookingDetail() async {
    if (bookingId != null) {
      await fetchBookingDetail();
    }
  }

  // Computed properties
  bool get canConfirm => 
      booking.value?.status == BookingStatus.pending && 
      !isConfirming.value && 
      !isCancelling.value;

  bool get canCancel {
    if (booking.value == null) return false;
    
    final now = DateTime.now();
    final bookingDateTime = DateTime(
      booking.value!.date.year,
      booking.value!.date.month,
      booking.value!.date.day,
      int.parse(booking.value!.startTime.split(':')[0]),
      int.parse(booking.value!.startTime.split(':')[1]),
    );
    
    return (booking.value!.status == BookingStatus.pending || 
            booking.value!.status == BookingStatus.confirmed) &&
           bookingDateTime.isAfter(now) &&
           !isConfirming.value && 
           !isCancelling.value;
  }

  bool get canReschedule {
    if (booking.value == null) return false;
    
    final now = DateTime.now();
    final bookingDateTime = DateTime(
      booking.value!.date.year,
      booking.value!.date.month,
      booking.value!.date.day,
      int.parse(booking.value!.startTime.split(':')[0]),
      int.parse(booking.value!.startTime.split(':')[1]),
    );
    
    return (booking.value!.status == BookingStatus.confirmed || 
            booking.value!.status == BookingStatus.pending) &&
           bookingDateTime.isAfter(now.add(const Duration(hours: 24))) && // At least 24 hours notice
           !isConfirming.value && 
           !isCancelling.value;
  }

  bool get isPastBooking {
    if (booking.value == null) return false;
    
    final now = DateTime.now();
    final bookingEndDateTime = DateTime(
      booking.value!.date.year,
      booking.value!.date.month,
      booking.value!.date.day,
      int.parse(booking.value!.endTime.split(':')[0]),
      int.parse(booking.value!.endTime.split(':')[1]),
    );
    
    return bookingEndDateTime.isBefore(now);
  }

  String get timeUntilBooking {
    if (booking.value == null) return '';
    
    final now = DateTime.now();
    final bookingDateTime = DateTime(
      booking.value!.date.year,
      booking.value!.date.month,
      booking.value!.date.day,
      int.parse(booking.value!.startTime.split(':')[0]),
      int.parse(booking.value!.startTime.split(':')[1]),
    );
    
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