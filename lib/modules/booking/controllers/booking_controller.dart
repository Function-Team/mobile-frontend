import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/modules/booking/controllers/booking_list_controller.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/booking/models/booking_response_models.dart';
import 'package:function_mobile/modules/booking/services/booking_service.dart';
import 'package:function_mobile/modules/booking/services/booking_validation_service.dart';
import 'package:function_mobile/modules/booking/widgets/conflict_dialog.dart';
import 'package:function_mobile/modules/navigation/controllers/bottom_nav_controller.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class BookingController extends GetxController {
  final ApiService _apiService = ApiService();
  final BookingValidationService validationService =
      Get.put(BookingValidationService());

  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  // Debounce timer
  Timer? _validationTimer;

  // Real-time validation states
  final RxString nameError = ''.obs;
  final RxString emailError = ''.obs;
  final RxString phoneError = ''.obs;
  final RxString dateTimeError = ''.obs;

  final RxBool isFormComplete = false.obs;
  final RxDouble formProgress = 0.0.obs;

  // Capacity controller and validation
  final capacityController = TextEditingController(text: '1');
  final RxBool isCapacityValid = true.obs;
  final RxString capacityErrorMessage = ''.obs;

  // Calendar & Time slots state
  final RxMap<String, String> calendarAvailability = <String, String>{}.obs;
  final RxList<DetailedTimeSlot> detailedTimeSlots = <DetailedTimeSlot>[].obs;
  final RxBool isLoadingCalendar = false.obs;
  final RxBool isLoadingTimeSlots = false.obs;

  // Time slots
  final Rx<TimeOfDay?> startTime = Rx<TimeOfDay?>(null);
  final Rx<TimeOfDay?> endTime = Rx<TimeOfDay?>(null);

  // Booking state
  final RxBool isProcessing = false.obs;
  final RxString bookingStatus = 'idle'.obs;
  final RxInt remainingSeconds = 300.obs;
  final RxInt maxVenueCapacity = 100.obs;
  Timer? _timer;

  // Guest information
  final guestNameController = TextEditingController();
  final guestEmailController = TextEditingController();
  final guestPhoneController = TextEditingController();
  final specialRequestsController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _formValidation();

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
    _validationTimer?.cancel();
    guestNameController.dispose();
    guestEmailController.dispose();
    guestPhoneController.dispose();
    specialRequestsController.dispose();
    capacityController.dispose();
    super.onClose();
  }

  // CALENDAR METHODS
  Future<void> loadCalendarAvailability(
      int venueId, DateTime startDate, DateTime endDate) async {
    try {
      isLoadingCalendar.value = true;
      calendarAvailability.clear();

      final service = BookingService();
      final response = await service.getCalendarAvailability(
        placeId: venueId,
        startDate: startDate,
        endDate: endDate,
      );

      calendarAvailability.value = response.availability;
    } catch (e) {
      showError('Failed to load calendar availability: ${e.toString()}');
    } finally {
      isLoadingCalendar.value = false;
    }
  }

  List<TimeSlot> _filterOperatingHourSlots(List<TimeSlot> slots) {
    return slots.where((slot) {
      final startHour = int.parse(slot.start.split(':')[0]);
      final startMinute = int.parse(slot.start.split(':')[1]);
      final endHour = int.parse(slot.end.split(':')[0]);
      final endMinute = int.parse(slot.end.split(':')[1]);

      // Convert to minutes for precise comparison
      final startTotalMinutes = startHour * 60 + startMinute;
      final endTotalMinutes = endHour * 60 + endMinute;
      
      // Operating hours: 08:00 (480 minutes) to 22:00 (1320 minutes)
      final openingMinutes = 8 * 60; // 08:00
      final closingMinutes = 22 * 60; // 22:00

      // Only include slots that start >= 08:00 and end <= 22:00
      return startTotalMinutes >= openingMinutes && endTotalMinutes <= closingMinutes;
    }).toList();
  }

  Future<void> loadDetailedTimeSlots(int venueId, DateTime date) async {
    try {
      isLoadingTimeSlots.value = true;
      detailedTimeSlots.clear();

      final service = BookingService();
      final response = await service.getDetailedTimeSlots(
        placeId: venueId,
        date: date,
      );

      detailedTimeSlots.value = response.slots;
    } catch (e) {
      showError('Failed to load time slots: ${e.toString()}');
    } finally {
      isLoadingTimeSlots.value = false;
    }
  }

  String getAvailabilityStatus(DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return calendarAvailability[dateStr] ?? 'unknown';
  }

  Future<void> createBooking(VenueModel venue) async {
    // Pre-validate form before processing
    if (!isFormValid()) return;

    try {
      isProcessing.value = true;
      bookingStatus.value = 'processing';

      // Validate time increments
      if (startTime.value!.minute != 0 && startTime.value!.minute != 30) {
        showError(
            'Waktu mulai harus dalam kelipatan 30 menit (09:00, 09:30, dst)');
        return;
      }

      if (endTime.value!.minute != 0 && endTime.value!.minute != 30) {
        showError(
            'Waktu selesai harus dalam kelipatan 30 menit (09:00, 09:30, dst)');
        return;
      }

      // Validate duration
      final startDateTime = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        startTime.value!.hour,
        startTime.value!.minute,
      );

      final endDateTime = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        endTime.value!.hour,
        endTime.value!.minute,
      );

      final duration = endDateTime.difference(startDateTime);
      if (duration.inMinutes < 60) {
        showError('Minimum booking duration is 1 hour');
        return;
      }

      final bookingRequest = BookingCreateRequest.fromVenueAndForm(
        venue: venue,
        date: selectedDate.value!,
        startTime: startTime.value!,
        endTime: endTime.value!,
        capacity: int.parse(capacityController.text.trim()),
        specialRequests: specialRequestsController.text.trim(),
        userName: guestNameController.text.trim(),
        userEmail: guestEmailController.text.trim(),
        userPhone: guestPhoneController.text.trim(),
      );

      // Log request JSON
      final requestJson = bookingRequest.toJson();
      print('DEBUG: Request JSON: $requestJson');

      // Final validation
      if (requestJson['amount'] == null || requestJson['amount'] <= 0) {
        showError('Invalid booking amount calculated');
        return;
      }

      final service = BookingService();
      final response =
          await service.createBookingWithBuiltInValidation(bookingRequest);

      if (response is BookingCreateWithResponse) {
        bookingStatus.value = 'success';
        showSuccess('Booking created successfully!\n'
            'Duration: ${response.totalHours} hours\n'
            'Total: Rp ${NumberFormat('#,###').format(response.totalAmount)}');

        clearForm();
        await Future.delayed(Duration(seconds: 2));
        Get.back();
        goToBookingListPage();
      } else if (response is BookingConflictResponse) {
        // CONFLICT - Time slot not available
        bookingStatus.value = 'failed';
        handleBookingConflict(response.availableSlots, venue);
      }
    } catch (e) {
      print('ERROR: Booking creation failed: $e');
      bookingStatus.value = 'failed';

      String errorMessage = _getUserFriendlyErrorMessage(e.toString());
      showError(errorMessage);
    } finally {
      isProcessing.value = false;
    }
  }

  // Enhanced friendly error messages with JSON parsing
  String _getUserFriendlyErrorMessage(String error) {
    print('🔍 Analyzing error: $error');

    // Try to parse JSON error response from backend
    try {
      final Map<String, dynamic> errorData = json.decode(error);

      // Check if it's a structured error response
      if (errorData.containsKey('detail') && errorData['detail'] is Map) {
        final detail = errorData['detail'] as Map<String, dynamic>;

        // Return the user-friendly message from backend
        if (detail.containsKey('message')) {
          String message = detail['message'];

          // Add suggestion if available
          if (detail.containsKey('suggestion')) {
            message += '\n\n💡 ${detail['suggestion']}';
          }

          // Add valid options for specific errors
          if (detail.containsKey('valid_latest_slots')) {
            final validSlots = detail['valid_latest_slots'] as List;
            message +=
                '\n\n⏰ Slot terakhir yang valid: ${validSlots.join(', ')}';
          }

          return message;
        }

        // Fallback to error type specific messages
        final errorType = detail['error'] ?? '';
        switch (errorType) {
          case 'Invalid start time':
          case 'Invalid end time':
            return detail['message'] ?? 'Waktu harus dalam kelipatan 30 menit';
          case 'Duration too short':
            return detail['message'] ?? 'Durasi booking minimum 1 jam';
          case 'Duration too long':
            return detail['message'] ?? 'Durasi booking maksimum 7 hari';
          case 'Start time too early':
          case 'Start time too late':
          case 'End time too early':
          case 'End time too late':
          case 'End time exceeds venue hours':
            return detail['message'] ??
                'Waktu booking di luar jam operasional venue';
          case 'Guest count exceeds capacity':
            return detail['message'] ?? 'Jumlah tamu melebihi kapasitas venue';
          case 'Time slot not available':
            return detail['message'] ?? 'Waktu yang dipilih sudah dibooking';
          default:
            return detail['message'] ?? 'Terjadi kesalahan validasi';
        }
      }
    } catch (e) {
      print('Error parsing JSON, falling back to string analysis: $e');
    }

    // Fallback to original string-based error detection
    final lowerError = error.toLowerCase();

    // Specific conflict detection - multiple patterns
    if (lowerError.contains('venue not available') ||
        lowerError.contains('conflict') ||
        lowerError.contains('slot') && lowerError.contains('available') ||
        lowerError.contains('booking') && lowerError.contains('conflict') ||
        lowerError.contains('time') && lowerError.contains('booked') ||
        lowerError.contains('already booked') ||
        lowerError.contains('409')) {
      print('Detected conflict/venue unavailable error');
      return 'Waktu yang dipilih sudah dibooking. Silakan pilih waktu lain.';
    }

    // Network/connection errors
    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout') ||
        lowerError.contains('internet')) {
      print('Detected network error');
      return 'Masalah koneksi. Periksa internet Anda dan coba lagi.';
    }

    // Validation errors
    if (lowerError.contains('validation') ||
        lowerError.contains('invalid') ||
        lowerError.contains('required') ||
        lowerError.contains('format')) {
      print('Detected validation error');
      return 'Data tidak valid. Silakan periksa input Anda.';
    }

    // Authentication errors
    if (lowerError.contains('unauthorized') ||
        lowerError.contains('401') ||
        lowerError.contains('authentication') ||
        lowerError.contains('login')) {
      print('Detected auth error');
      return 'Silakan login ulang untuk melanjutkan.';
    }

    // Business rule errors
    if (lowerError.contains('minimum') && lowerError.contains('duration')) {
      print('Detected duration error');
      return 'Durasi booking minimal 1 jam';
    }

    if (lowerError.contains('30-minute') || lowerError.contains('increments')) {
      print('Detected time increment error');
      return 'Pilih waktu dalam kelipatan 30 menit (09:00, 09:30, dst)';
    }

    // Server errors
    if (lowerError.contains('server error') ||
        lowerError.contains('500') ||
        lowerError.contains('502') ||
        lowerError.contains('503')) {
      print('Detected server error');
      return 'Server sedang bermasalah. Silakan coba lagi nanti.';
    }

    // Client errors
    if (lowerError.contains('400') || lowerError.contains('bad request')) {
      print('Detected client error');
      return 'Data booking tidak valid. Periksa kembali input Anda.';
    }

    // Default fallback
    print('Using fallback error message');
    return 'Terjadi kesalahan. Silakan coba lagi atau hubungi support.';
  }

  void _formValidation() {
    guestNameController.addListener(() => _debounceValidation('name'));
    guestEmailController.addListener(() => _debounceValidation('email'));
    guestPhoneController.addListener(() => _debounceValidation('phone'));
    capacityController.addListener(() => _debounceValidation('capacity'));

    // Instant validation for reactive fields
    selectedDate.listen((_) => _validateDateTime());
    startTime.listen((_) => _validateDateTime());
    endTime.listen((_) => _validateDateTime());

    // Listen to all changes for form completion
    ever(
        isFormComplete,
        (complete) =>
            formProgress.value = complete ? 1.0 : _calculateProgress());
  }

  void _debounceValidation(String field) {
    _validationTimer?.cancel();
    _validationTimer =
        Timer(Duration(milliseconds: 400), () => validateField(field));
  }

  void validateField(String field) {
    switch (field) {
      case 'name':
        final result =
            validationService.validateGuestName(guestNameController.text);
        nameError.value = result.isValid ? '' : result.message;
        break;
      case 'email':
        final result =
            validationService.validateGuestEmail(guestEmailController.text);
        emailError.value = result.isValid ? '' : result.message;
        break;
      case 'phone':
        final result =
            validationService.validateGuestPhone(guestPhoneController.text);
        phoneError.value = result.isValid ? '' : result.message;
        break;
      case 'capacity':
        validateCapacity(maxVenueCapacity.value);
        break;
    }
    _updateFormCompletion();
  }

  void _validateDateTime() {
    final result = validationService.validateTimeSlot(
      date: selectedDate.value,
      startTime: startTime.value,
      endTime: endTime.value,
    );
    dateTimeError.value = result.isValid ? '' : result.message;
    _updateFormCompletion();
  }

  void _updateFormCompletion() {
    final status = validationService.getFormCompletionStatus(
      selectedDate: selectedDate.value,
      startTime: startTime.value,
      endTime: endTime.value,
      guestName: guestNameController.text,
      guestEmail: guestEmailController.text,
      guestPhone: guestPhoneController.text,
      capacityText: capacityController.text,
      venueMaxCapacity: maxVenueCapacity.value,
    );

    isFormComplete.value = status['isComplete'];
    formProgress.value = status['completionPercentage'];
  }

  double _calculateProgress() {
    int completed = 0;
    int total = 6; // total required fields

    if (selectedDate.value != null) completed++;
    if (startTime.value != null &&
        endTime.value != null &&
        dateTimeError.isEmpty) completed++;
    if (guestNameController.text.isNotEmpty && nameError.isEmpty) completed++;
    if (guestEmailController.text.isNotEmpty && emailError.isEmpty) completed++;
    if (guestPhoneController.text.isNotEmpty && phoneError.isEmpty) completed++;
    if (capacityController.text.isNotEmpty && isCapacityValid.value)
      completed++;

    return completed / total;
  }

  bool isFormValid() {
    // Use validation service to check form
    final result = validationService.validateBookingFormWithSpecificError(
      selectedDate: selectedDate.value,
      startTime: startTime.value,
      endTime: endTime.value,
      guestName: guestNameController.text,
      guestEmail: guestEmailController.text,
      guestPhone: guestPhoneController.text,
      capacityText: capacityController.text,
      venueMaxCapacity: maxVenueCapacity.value,
    );

    if (!result.isValid) {
      showError(result.message);
      return false;
    }

    if (!validateCapacityForSubmit(maxVenueCapacity.value)) {
      showError(capacityErrorMessage.value);
      return false;
    }

    return true;
  }

  void handleBookingConflict(List<TimeSlot> availableSlots, VenueModel venue) {
    // Let UI layer handle the dialog display
    final filteredSlots = _filterOperatingHourSlots(availableSlots);

    // Use callback or event to notify UI layer
    Get.dialog(ConflictDialog(
        availableSlots: filteredSlots,
        venue: venue,
        onSlotSelected: (TimeSlot slot) => useAvailableSlot(slot)));
  }

  // Use the selected available slot
  void useAvailableSlot(TimeSlot slot) {
    try {
      // Parse start time from available slot
      final startParts = slot.start.split(':');
      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);

      // Validate slot is within operating hours
      final startTotalMinutes = startHour * 60 + startMinute;
      final closingMinutes = 22 * 60; // 22:00
      final minimumBookingMinutes = 30; // 30 minutes minimum
      final latestValidStartMinutes = closingMinutes - minimumBookingMinutes;
      
      if (startTotalMinutes > latestValidStartMinutes) {
        showError('Slot tidak dapat digunakan - akan melewati jam operasional');
        return;
      }

      // Set start time
      startTime.value = TimeOfDay(
        hour: startHour,
        minute: startMinute,
      );

      // Calculate end time (1 hour after start time)
      final endTotalMinutes = startTotalMinutes + 60;
      
      // Operating hours constraint: end time cannot exceed 22:00 (1320 minutes)
      final actualEndMinutes = endTotalMinutes > closingMinutes ? closingMinutes : endTotalMinutes;
      
      final endHour = actualEndMinutes ~/ 60;
      final endMinute = actualEndMinutes % 60;

      // Set end time (1 hour duration or until closing time)
      endTime.value = TimeOfDay(
        hour: endHour,
        minute: endMinute,
      );

      // Format display times for success message
      final startTimeDisplay =
          '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
      final endTimeDisplay =
          '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
      final timeRangeDisplay = '$startTimeDisplay - $endTimeDisplay';

      // Show warning if end time was adjusted due to operating hours
      if (endTotalMinutes > closingMinutes) {
        showSuccess(
            'Waktu booking diperbarui ke $timeRangeDisplay\n⚠️ Waktu akhir disesuaikan dengan jam operasional (sampai 22:00)\nSilakan review detail booking dan tekan "Book Now" jika sudah yakin.');
      } else {
        showSuccess(
            'Waktu booking diperbarui ke $timeRangeDisplay\nSilakan review detail booking dan tekan "Book Now" jika sudah yakin.');
      }

      print('Time updated successfully: $timeRangeDisplay');
    } catch (e) {
      showError('Gagal memperbarui slot waktu: $e');
    }
  }

  void setStartTime(TimeOfDay time) {
    startTime.value = time;
  }

  void setEndTime(TimeOfDay time) {
    endTime.value = time;
  }

  void setVenueData(VenueModel venue) {
    if (venue.maxCapacity != null && venue.maxCapacity! > 0) {
      maxVenueCapacity.value = venue.maxCapacity!;
      final currentCapacity = int.tryParse(capacityController.text) ?? 1;
      if (currentCapacity > venue.maxCapacity!) {
        capacityController.text = venue.maxCapacity!.toString();
        showInfo(
            'Capacity adjusted to venue maximum: ${venue.maxCapacity} guests');
      }
    } else {
      maxVenueCapacity.value = 100;
    }
    // Trigger validation after setting venue data
    validateField('capacity');
  }

  bool validateCapacity(int maxCapacity) {
    final inputText = capacityController.text.trim();

    // Allow empty input (user sedang ngetik)
    if (inputText.isEmpty) {
      isCapacityValid.value = true; // Don't show error while typing
      capacityErrorMessage.value = '';
      return true;
    }

    int? capacity;
    try {
      capacity = int.parse(inputText);
    } catch (e) {
      isCapacityValid.value = false;
      capacityErrorMessage.value = 'Please enter a valid number';
      return false;
    }

    // Allow 0 during input (user bisa temporary input 0)
    if (capacity == 0) {
      isCapacityValid.value = true; // Allow 0 temporarily
      capacityErrorMessage.value = '';
      return true;
    }

    if (capacity < 0) {
      isCapacityValid.value = false;
      capacityErrorMessage.value = 'Capacity cannot be negative';
      return false;
    }

    if (capacity > maxCapacity) {
      isCapacityValid.value = false;
      capacityErrorMessage.value =
          'Capacity cannot exceed venue maximum of $maxCapacity';
      return false;
    }

    // Valid capacity
    isCapacityValid.value = true;
    capacityErrorMessage.value = '';
    return true;
  }

// Strict validation untuk submit (tidak allow 0)
  bool validateCapacityForSubmit(int maxCapacity) {
    final inputText = capacityController.text.trim();

    if (inputText.isEmpty) {
      isCapacityValid.value = false;
      capacityErrorMessage.value = 'Number of guests is required';
      return false;
    }

    int? capacity;
    try {
      capacity = int.parse(inputText);
    } catch (e) {
      isCapacityValid.value = false;
      capacityErrorMessage.value = 'Please enter a valid number';
      return false;
    }

    // Strict validation - tidak allow 0 saat submit
    if (capacity <= 0) {
      isCapacityValid.value = false;
      capacityErrorMessage.value = 'Number of guests must be at least 1';
      return false;
    }

    if (capacity > maxCapacity) {
      isCapacityValid.value = false;
      capacityErrorMessage.value =
          'Cannot exceed venue maximum of $maxCapacity guests';
      return false;
    }

    // Valid capacity
    isCapacityValid.value = true;
    capacityErrorMessage.value = '';
    return true;
  }

  void incrementCapacity() {
    final currentValue = int.tryParse(capacityController.text) ?? 0;
    final maxCapacity = maxVenueCapacity.value;

    if (currentValue < maxCapacity) {
      capacityController.text = (currentValue + 1).toString();
      validateField('capacity');
    } else {
      showInfo('Maximum capacity is $maxCapacity guests');
    }
  }

  void decrementCapacity() {
    final currentValue = int.tryParse(capacityController.text) ?? 1;
    if (currentValue > 0) {
      capacityController.text = (currentValue - 1).toString();
      validateField('capacity');
    }
  }

// Handle auto-correction saat user input > max capacity
  void handleCapacityInput(String value) {
    final maxCapacity = maxVenueCapacity.value;

    // Allow empty atau 0 untuk flexibility
    if (value.isEmpty || value == '0') {
      validateCapacity(maxCapacity); // Use lenient validation
      return;
    }

    final inputValue = int.tryParse(value);
    if (inputValue == null) {
      // Invalid input - keep previous value or reset to 1
      capacityController.text = '1';
      capacityController.selection = TextSelection.fromPosition(
        TextPosition(offset: capacityController.text.length),
      );
      return;
    }

    // Auto-correct immediately jika > max capacity
    if (inputValue > maxCapacity) {
      capacityController.text = maxCapacity.toString();
      capacityController.selection = TextSelection.fromPosition(
        TextPosition(offset: capacityController.text.length),
      );
      showInfo('Maximum capacity is $maxCapacity guests');
    }

    // Validate with lenient rules (allow 0 temporarily)
    validateCapacity(maxCapacity);
  }

  // PAYMENT METHODS
  Future<void> createPaymentForBooking(BookingModel booking) async {
    try {
      isProcessing.value = true;

      if (!booking.isConfirmed) {
        showError('Booking must be confirmed by admin before payment');
        return;
      }

      if (booking.payment != null &&
          booking.payment!.status.toLowerCase() == 'success') {
        showError('Payment already completed for this booking');
        return;
      }

      // First, try to get existing payment for this booking
      var response;
      try {
        response =
            await _apiService.getRequest('/payment/booking/${booking.id}');
        print('Found existing payment for booking ${booking.id}');
      } catch (e) {
        // If no existing payment found, create a new one
        print(
            'No existing payment found, creating new payment for booking ${booking.id}');
        final paymentData = {
          'booking_id': booking.id,
          'amount': booking.place?.price ?? 0,
        };
        response = await _apiService.postRequest('/payment', paymentData);
      }

      if (response != null && response['midtrans'] != null) {
        final snapToken = response['midtrans']['token'];
        final paymentUrl =
            'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken';
        final Uri url = Uri.parse(paymentUrl);

        if (await canLaunchUrl(url)) {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );

          showSuccess('Payment page opened. Complete your payment.');

          await Future.delayed(Duration(seconds: 3));
          if (Get.isRegistered<BookingListController>()) {
            Get.find<BookingListController>().refreshBookings();
          }
        } else {
          throw Exception('Could not open payment page');
        }
      } else {
        throw Exception('Failed to get payment session');
      }
    } catch (e) {
      showError('Payment Error: ${e.toString()}');
    } finally {
      isProcessing.value = false;
    }
  }

  // UTILITY METHODS
  void clearForm() {
    selectedDate.value = null;
    capacityController.text = '10';
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
    calendarAvailability.clear();
    detailedTimeSlots.clear();

    // Clear error states
    nameError.value = '';
    emailError.value = '';
    phoneError.value = '';
    dateTimeError.value = '';
    capacityErrorMessage.value = '';
    isCapacityValid.value = true;
    isFormComplete.value = false;
    formProgress.value = 0.0;
  }

  String formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      if (hours > 0) {
        return '$days days $hours hours';
      } else {
        return '$days days';
      }
    } else {
      if (hours > 0 && minutes > 0) {
        return '${hours}h ${minutes}m';
      } else if (hours > 0) {
        return '${hours}h';
      } else {
        return '${minutes}m';
      }
    }
  }

  void showError(String message) {
    CustomSnackbar.show(
      context: Get.context!,
      message: message,
      type: SnackbarType.error,
    );
  }

  void showSuccess(String message) {
    CustomSnackbar.show(
      context: Get.context!,
      message: message,
      type: SnackbarType.success,
    );
  }

  void showValidationWarning(String message) {
    CustomSnackbar.show(
      context: Get.context!,
      message: message,
      type: SnackbarType.warning,
    );
  }

  void showInfo(String message) {
    CustomSnackbar.show(
      context: Get.context!,
      message: message,
      type: SnackbarType.info,
    );
  }

  // NAVIGATION
  Future<void> goToBookingListPage() async {
    Get.offAllNamed(MyRoutes.bottomNav);
    Get.find<BottomNavController>().changePage(0);
    Get.find<BookingListController>().refreshBookings();
  }
}