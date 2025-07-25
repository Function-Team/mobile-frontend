import 'dart:math';
import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/core/constants/app_constants.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/modules/booking/controllers/booking_list_controller.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/booking/services/booking_service.dart';
import 'package:function_mobile/modules/booking/widgets/change_booking_bottom_sheets.dart';
import 'package:function_mobile/modules/booking/widgets/detail_bottom_sheets.dart';
import 'package:function_mobile/modules/navigation/controllers/bottom_nav_controller.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:function_mobile/modules/payment/controllers/payment_controller.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingController extends GetxController {
  final BookingService _bookingService = BookingService();
  final ApiService _apiService = ApiService();

  // Form data
  final Rx<DateTimeRange?> selectedDateRange = Rx<DateTimeRange?>(null);
  final RxString selectedCapacity = '10'.obs;
  final RxList<String> capacityOptions = ['10', '20', '50', '100', '200'].obs;

  // Time slots - using TimeOfDay for UI, will convert to String for API
  final Rx<TimeOfDay?> startTime = Rx<TimeOfDay?>(null);
  final Rx<TimeOfDay?> endTime = Rx<TimeOfDay?>(null);

  // Booking state
  final RxBool isProcessing = false.obs;
  final RxString bookingStatus =
      'idle'.obs; // idle, processing, success, failed
  final RxInt remainingSeconds = 300.obs; // 5 minutes countdown
  Timer? _timer;

  // Guest information
  final guestNameController = TextEditingController();
  final guestEmailController = TextEditingController();
  final guestPhoneController = TextEditingController();
  final specialRequestsController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Set default values
    if (!capacityOptions.contains(selectedCapacity.value)) {
      selectedCapacity.value = capacityOptions[0];
    }

    // Set default time slots
    startTime.value = TimeOfDay.now();
    endTime.value = TimeOfDay(
      hour: (TimeOfDay.now().hour + 2) % 24,
      minute: TimeOfDay.now().minute,
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    guestNameController.dispose();
    guestEmailController.dispose();
    guestPhoneController.dispose();
    specialRequestsController.dispose();
    super.onClose();
  }

  // Validation methods
  bool isFormValid() {
    if (selectedDateRange.value == null) {
      _showError('Please select booking dates');
      return false;
    }

    if (startTime.value == null || endTime.value == null) {
      _showError('Please select start and end times');
      return false;
    }

    // Validate time range
    final start = startTime.value!;
    final end = endTime.value!;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (endMinutes <= startMinutes) {
      _showError('End time must be after start time');
      return false;
    }

    if (guestNameController.text.trim().isEmpty) {
      _showError('Please enter guest name');
      return false;
    }

    if (guestEmailController.text.trim().isEmpty) {
      _showError('Please enter email address');
      return false;
    }

    if (guestPhoneController.text.trim().isEmpty) {
      _showError('Please enter phone number');
      return false;
    }

    return true;
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

  void _showSuccess(String message) {
    if (Get.context != null) {
      CustomSnackbar.show(
        context: Get.context!,
        message: message,
        type: SnackbarType.success,
      );
    }
  }

  // Setters
  void setDateRange(DateTimeRange range) {
    selectedDateRange.value = range;
  }

  void setCapacity(String capacity) {
    selectedCapacity.value = capacity;
  }

  void setStartTime(TimeOfDay time) {
    startTime.value = time;
  }

  void setEndTime(TimeOfDay time) {
    endTime.value = time;
  }

  // Bottom sheet methods
  Future displayDetailBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      useSafeArea: true,
      context: context,
      builder: (_) => DetailBottomSheets(),
    );
  }

  Future displayChangeDateBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ChangeBookingBottomSheet(),
    );
  }

  // Timer methods
  void startTimer() {
    _timer?.cancel();
    remainingSeconds.value = 300; // 5 minutes
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
        bookingStatus.value = 'expired';
        _showError('Booking time expired. Please try again.');
      }
    });
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Navigation methods
  void goToBookingListPage() {
    Get.offAllNamed(MyRoutes.bottomNav);
    Get.find<BottomNavController>().changePage(1);
    Get.find<BookingListController>().refreshBookings();
  }

  // UPDATED: Create booking only (no payment)
  Future<void> saveBookingOnly(VenueModel venue) async {
    if (!isFormValid()) return;

    try {
      isProcessing.value = true;
      bookingStatus.value = 'processing';

      // Create booking request
      final bookingRequest = BookingCreateRequest.fromVenueAndForm(
        venue: venue,
        date: selectedDateRange.value!.start,
        startTime: startTime.value!,
        endTime: endTime.value!,
        capacity: int.parse(selectedCapacity.value),
        specialRequests: specialRequestsController.text.trim(),
        userName: guestNameController.text.trim(),
        userEmail: guestEmailController.text.trim(),
        userPhone: guestPhoneController.text.trim(),
      );

      // Create booking only
      final response = await _apiService.postRequest(
        '/booking',
        bookingRequest.toJson(),
      );

      if (response != null) {
        bookingStatus.value = 'success';
        
        _showSuccess('Booking created successfully! Waiting for admin confirmation.');
        
        // Clear form
        clearForm();
        
        // Wait a bit for user to see the message
        await Future.delayed(Duration(seconds: 2));
        
        // Go back to venue detail
        Get.back();
        
      } else {
        throw Exception('Failed to create booking');
      }
    } catch (e) {
      bookingStatus.value = 'failed';
      _showError('Error: ${e.toString()}');
    } finally {
      isProcessing.value = false;
    }
  }

  // DEPRECATED: Old method that creates payment immediately
  @Deprecated('Use saveBookingOnly instead')
  Future<void> saveBookingWithPayment(VenueModel venue) async {
    // This method is kept for backward compatibility but should not be used
    print('WARNING: saveBookingWithPayment is deprecated. Use saveBookingOnly instead.');
    await saveBookingOnly(venue);
  }

  // NEW: Create payment for confirmed booking (called from BookingListPage)
  Future<void> createPaymentForBooking(BookingModel booking) async {
    try {
      isProcessing.value = true;
      
      // Verify booking is confirmed
      if (!booking.isConfirmed) {
        _showError('Booking must be confirmed by admin before payment');
        return;
      }
      
      // Check if payment already exists and is successful
      if (booking.payment != null && booking.payment!.status.toLowerCase() == 'success') {
        _showError('Payment already completed for this booking');
        return;
      }
      
      // Create payment request
      final paymentData = {
        'booking_id': booking.id,
        'amount': booking.place?.price ?? 0,
      };
      
      // Create payment
      final response = await _apiService.postRequest('/payment', paymentData);
      
      if (response != null && response['midtrans'] != null) {
        final snapToken = response['midtrans']['token'];
        
        // Open Midtrans payment URL
        final paymentUrl = 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken';
        final Uri url = Uri.parse(paymentUrl);
        
        if (await canLaunchUrl(url)) {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
          
          _showSuccess('Payment page opened. Complete your payment.');
          
          // Refresh bookings list after a delay
          await Future.delayed(Duration(seconds: 3));
          if (Get.isRegistered<BookingListController>()) {
            Get.find<BookingListController>().refreshBookings();
          }
        } else {
          throw Exception('Could not open payment page');
        }
      } else {
        throw Exception('Failed to create payment session');
      }
    } catch (e) {
      _showError('Payment Error: ${e.toString()}');
    } finally {
      isProcessing.value = false;
    }
  }

  // Helper method untuk debugging
  void debugBookingRequest(VenueModel venue) {
    print('=== BOOKING DEBUG INFO ===');
    print('Venue: ${venue.name} (ID: ${venue.id})');
    print('Date: ${selectedDateRange.value?.start}');
    print('Start Time: ${startTime.value}');
    print('End Time: ${endTime.value}');
    print('Capacity: ${selectedCapacity.value}');
    print('Guest Name: ${guestNameController.text}');
    print('Guest Email: ${guestEmailController.text}');
    print('Guest Phone: ${guestPhoneController.text}');
    print('Special Requests: ${specialRequestsController.text}');
    print('========================');
  }

  // Get booking summary for display
  Map<String, dynamic> getBookingSummary(VenueModel venue) {
    // Calculate number of days
    int numberOfDays = 1; // Default to 1 day
    if (selectedDateRange.value != null) {
      numberOfDays = selectedDateRange.value!.duration.inDays + 1; // +1 because duration.inDays doesn't count the start day
      if (numberOfDays <= 0) numberOfDays = 1; // Minimum 1 day
    }

    // Base price per day
    final pricePerDay = venue.price?.toDouble() ?? 0.0;
    final basePrice = pricePerDay * numberOfDays;

    final tax = basePrice * 0.1; // 10% tax
    final serviceFee = 25000.0; // Fixed service fee in IDR
    final finalTotal = basePrice + tax + serviceFee;

    // Calculate duration for display
    Duration duration = Duration.zero;
    if (startTime.value != null && endTime.value != null) {
      final start = startTime.value!;
      final end = endTime.value!;
      final startMinutes = start.hour * 60 + start.minute;
      final endMinutes = end.hour * 60 + end.minute;
      duration = Duration(minutes: endMinutes - startMinutes);
    }

    return {
      'base_price': basePrice,
      'price_per_day': pricePerDay,
      'number_of_days': numberOfDays,
      'tax': tax,
      'service_fee': serviceFee,
      'total': finalTotal,
      'duration': duration,
      'duration_hours': duration.inHours + (duration.inMinutes % 60) / 60.0,
      'capacity': selectedCapacity.value,
      'venue_name': venue.name ?? 'Unknown Venue',
      'venue_price_per_day': pricePerDay,
      'booking_date': selectedDateRange.value?.start.toIso8601String().split('T')[0] ?? '',
      'start_datetime': startTime.value?.format(Get.context!) ?? '',
      'end_datetime': endTime.value?.format(Get.context!) ?? '',
    };
  }

  // Helper method to format duration for display
  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  // Validation for booking date and time
  String? validateBookingDateTime() {
    if (selectedDateRange.value == null) {
      return 'Please select a booking date';
    }
    if (startTime.value == null || endTime.value == null) {
      return 'Please select start and end times';
    }
    return null; // Let backend handle advanced validation
  }

  // Clear form data
  void clearForm() {
    selectedDateRange.value = null;
    selectedCapacity.value = capacityOptions[0];
    startTime.value = TimeOfDay.now();
    endTime.value = TimeOfDay(
      hour: (TimeOfDay.now().hour + 2) % 24,
      minute: TimeOfDay.now().minute,
    );
    guestNameController.clear();
    guestEmailController.clear();
    guestPhoneController.clear();
    specialRequestsController.clear();
    bookingStatus.value = 'idle';
  }

  // Get available time slots for a venue
  List<TimeOfDay> getAvailableTimeSlots() {
    final slots = <TimeOfDay>[];
    for (int hour = 8; hour <= 22; hour++) {
      slots.add(TimeOfDay(hour: hour, minute: 0));
      if (hour < 22) {
        slots.add(TimeOfDay(hour: hour, minute: 30));
      }
    }
    return slots;
  }
}