import 'dart:math';
import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/core/constants/app_constants.dart';
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

class BookingController extends GetxController {
  final BookingService _bookingService = BookingService();

  // Form data
  final Rx<DateTimeRange?> selectedDateRange = Rx<DateTimeRange?>(null);
  final RxString selectedCapacity = '10'.obs;
  final RxList<String> capacityOptions = ['10', '20', '50', '100', '200'].obs;

  // Time slots - using TimeOfDay for UI, will convert to String for API
  final Rx<TimeOfDay?> startTime = Rx<TimeOfDay?>(null);
  final Rx<TimeOfDay?> endTime = Rx<TimeOfDay?>(null);

  // Booking state
  final RxBool isProcessing = false.obs;
  final RxString bookingStatus = 'idle'.obs; // idle, processing, success, failed
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

  Future<void> saveBooking(VenueModel venue) async {
  if (!isFormValid()) return;

  try {
    isProcessing.value = true;
    bookingStatus.value = 'processing';

    // Debug info
    debugBookingRequest(venue);

    // Create the booking request using the existing model from booking_model.dart
    final bookingRequest = BookingCreateRequest.fromVenueAndForm(
      venue: venue,
      date: selectedDateRange.value!.start,
      startTime: startTime.value!,
      endTime: endTime.value!,
      capacity: int.parse(selectedCapacity.value),
      specialRequests: specialRequestsController.text.trim().isNotEmpty 
          ? specialRequestsController.text.trim() 
          : null,
      userName: guestNameController.text.trim(),
      userEmail: guestEmailController.text.trim(),
      userPhone: guestPhoneController.text.trim().isNotEmpty 
          ? guestPhoneController.text.trim() 
          : null,
    );


    // Create booking via existing service method
    final createdBooking = await _bookingService.createBooking(bookingRequest);
    
    bookingStatus.value = 'success';
    
    _showSuccess('Booking request submitted successfully! Please wait for admin approval.');
    
    // Navigate to booking list after a short delay
    await Future.delayed(const Duration(seconds: 2));
    goToBookingListPage();
    
  } catch (e) {
    bookingStatus.value = 'failed';
    
    String errorMessage = 'Failed to create booking';
    if (e.toString().contains('Connection refused') || 
        e.toString().contains('SocketException') ||
        e.toString().contains('Failed host lookup')) {
      errorMessage = 'Cannot connect to server. Please check if FastAPI is running.';
    } else if (e.toString().contains('Time slot is already booked')) {
      errorMessage = 'This time slot is already booked. Please choose a different time.';
    } else if (e.toString().contains('Validation failed') || 
               e.toString().contains('422')) {
      errorMessage = 'Please check your booking details and try again.';
    } else if (e.toString().contains('409')) {
      errorMessage = 'Time slot is already booked. Please choose a different time.';
    }
    
    _showError(errorMessage);
    print('Error saving booking: $e');
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
    print('API Base URL: ${AppConstants.baseUrl}');
    print('========================');
  }

  // Get booking summary for display - using venue's existing price with day calculation
  Map<String, dynamic> getBookingSummary(VenueModel venue) {
    // Calculate number of days
    int numberOfDays = 1; // Default to 1 day
    if (selectedDateRange.value != null) {
      numberOfDays = selectedDateRange.value!.duration.inDays +
          1; // +1 because duration.inDays doesn't count the start day
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
      'booking_date':
          selectedDateRange.value?.start.toIso8601String().split('T')[0] ?? '',
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

  // Get available time slots for a venue (could be enhanced with real data)
  List<TimeOfDay> getAvailableTimeSlots() {
    // This is a simple implementation - in a real app, you'd fetch this from the API
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