import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/modules/booking/controllers/booking_list_controller.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/booking/models/booking_response_models.dart';
import 'package:function_mobile/modules/booking/services/booking_service.dart';
import 'package:function_mobile/modules/navigation/controllers/bottom_nav_controller.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class BookingController extends GetxController {
  final ApiService _apiService = ApiService();

  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  // Form data
  final RxString selectedCapacity = '10'.obs;

  // Tambahkan controller untuk input kapasitas dan status validasi
  final capacityController = TextEditingController(text: '10');
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
    // Hapus pengecekan capacityOptions
    // if (!capacityOptions.contains(selectedCapacity.value)) {
    //   selectedCapacity.value = capacityOptions[0];
    // }

    // Tambahkan listener untuk memperbarui selectedCapacity saat input berubah
    capacityController.addListener(() {
      if (capacityController.text.isNotEmpty) {
        selectedCapacity.value = capacityController.text;
      }
    });

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
    capacityController.dispose(); // Tambahkan dispose untuk controller baru
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

  bool validateCapacity(int maxCapacity) {
    try {
      final capacity = int.parse(capacityController.text.trim());
      if (capacity <= 0) {
        isCapacityValid.value = false;
        capacityErrorMessage.value =
            'Please enter a valid capacity greater than 0';
        return false;
      }
      if (capacity > maxCapacity) {
        isCapacityValid.value = false;
        capacityErrorMessage.value =
            'Capacity cannot exceed venue maximum of $maxCapacity';
        return false;
      }
      isCapacityValid.value = true;
      capacityErrorMessage.value = '';
      return true;
    } catch (e) {
      isCapacityValid.value = false;
      capacityErrorMessage.value = 'Please enter a valid number';
      return false;
    }
  }

  Future<void> createBooking(VenueModel venue) async {
    // Validasi kapasitas maksimum venue
    if (!validateCapacity(venue.maxCapacity ?? 200)) {
      showError(capacityErrorMessage.value);
      return;
    }

    if (!isFormValid()) return;

    try {
      isProcessing.value = true;
      bookingStatus.value = 'processing';

      if (startTime.value!.minute != 0 && startTime.value!.minute != 30) {
        showError(
            'Start time must be on 30-minute increments (e.g., 09:00, 09:30)');
        return;
      }

      if (endTime.value!.minute != 0 && endTime.value!.minute != 30) {
        showError(
            'End time must be on 30-minute increments (e.g., 09:00, 09:30)');
        return;
      }

      // Validasi durasi minimum
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

      // Log data yang akan dikirim untuk debugging
      print('DEBUG: Creating booking with data:');
      print('- Venue: ${venue.name} (ID: ${venue.id})');
      print('- Date: ${selectedDate.value}');
      print('- Time: ${startTime.value} - ${endTime.value}');
      print('- Duration: ${duration.inHours} hours');
      print(
          '- Capacity: ${capacityController.text.trim()}'); // Gunakan controller baru
      print('- Guest: ${guestNameController.text.trim()}');
      print('- Email: ${guestEmailController.text.trim()}');

      final bookingRequest = BookingCreateRequest.fromVenueAndForm(
        venue: venue,
        date: selectedDate.value!,
        startTime: startTime.value!,
        endTime: endTime.value!,
        capacity: int.parse(
            capacityController.text.trim()), // Gunakan controller baru
        specialRequests: specialRequestsController.text.trim(),
        userName: guestNameController.text.trim(),
        userEmail: guestEmailController.text.trim(),
        userPhone: guestPhoneController.text.trim(),
      );

      // Log JSON yang akan dikirim
      final requestJson = bookingRequest.toJson();
      print('DEBUG: Request JSON: $requestJson');

      // Validasi final sebelum kirim
      if (requestJson['amount'] == null || requestJson['amount'] <= 0) {
        showError('Invalid booking amount calculated');
        return;
      }

      final service = BookingService();
      final response =
          await service.createBookingWithBuiltInValidation(bookingRequest);

      if (response is BookingCreateWithResponse) {
        // Success
        bookingStatus.value = 'success';
        _showSuccess('Booking created successfully!\n'
            'Duration: ${response.totalHours} hours\n'
            'Total: Rp ${NumberFormat('#,###').format(response.totalAmount)}');

        clearForm();
        await Future.delayed(Duration(seconds: 2));
        Get.back();
      } else if (response is BookingConflictResponse) {
        bookingStatus.value = 'failed';
        _showConflictDialog(response.availableSlots, venue);
      }
    } catch (e) {
      print('ERROR: Booking creation failed: $e');
      bookingStatus.value = 'failed';

      // Tampilkan error yang lebih user-friendly
      String errorMessage = 'Failed to create booking';

      if (e.toString().contains('Minimum booking duration')) {
        errorMessage = 'Minimum booking duration is 1 hour';
      } else if (e.toString().contains('30-minute increments')) {
        errorMessage =
            'Please select times in 30-minute increments (e.g., 09:00, 09:30)';
      } else if (e.toString().contains('Network')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please try again.';
      } else if (e.toString().contains('409')) {
        errorMessage = 'Time slot is no longer available.';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Invalid booking data. Please check your input.';
      }

      showError(errorMessage);
    } finally {
      isProcessing.value = false;
      goToBookingListPage();
    }
  }

  bool isFormValid() {
    // Validasi tanggal
    if (selectedDate.value == null) {
      showError('Please select booking date');
      return false;
    }

    // Validasi tanggal tidak boleh di masa lalu
    final today = DateTime.now();
    final selectedDateOnly = DateTime(
      selectedDate.value!.year,
      selectedDate.value!.month,
      selectedDate.value!.day,
    );
    final todayOnly = DateTime(today.year, today.month, today.day);

    if (selectedDateOnly.isBefore(todayOnly)) {
      showError('Cannot book for past dates');
      return false;
    }

    // Validasi waktu
    if (startTime.value == null || endTime.value == null) {
      showError('Please select start and end times');
      return false;
    }

    // Validasi urutan waktu
    final startMinutes = startTime.value!.hour * 60 + startTime.value!.minute;
    final endMinutes = endTime.value!.hour * 60 + endTime.value!.minute;

    if (startMinutes >= endMinutes) {
      showError('End time must be after start time');
      return false;
    }

    // Validasi nama
    if (guestNameController.text.trim().isEmpty) {
      showError('Please enter guest name');
      return false;
    }

    // Validasi email dengan regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (guestEmailController.text.trim().isEmpty) {
      showError('Please enter email address');
      return false;
    }

    if (!emailRegex.hasMatch(guestEmailController.text.trim())) {
      showError('Please enter a valid email address');
      return false;
    }

    // Validasi phone
    if (guestPhoneController.text.trim().isEmpty) {
      showError('Please enter phone number');
      return false;
    }

    return true;
  }

  // CONFLICT DIALOG
  void _showConflictDialog(List<TimeSlot> availableSlots, VenueModel venue) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.schedule, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text('Time Not Available'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The selected time slot is already booked.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 16),
              if (availableSlots.isNotEmpty) ...[
                Text(
                  'Available time slots today:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  height: 200,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableSlots.length,
                    itemBuilder: (context, index) {
                      final slot = availableSlots[index];
                      return _buildAvailableSlotItem(slot, venue);
                    },
                  ),
                ),
              ] else ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No available slots for today. Please choose a different date.',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          if (availableSlots.isEmpty)
            ElevatedButton(
              onPressed: () {
                Get.back();
                // Focus on date picker to let user choose different date
                _focusOnDatePicker();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Choose Different Date'),
            ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildAvailableSlotItem(TimeSlot slot, VenueModel venue) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green[200]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.green[50],
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          Icons.access_time,
          color: Colors.green[600],
          size: 20,
        ),
        title: Text(
          slot.displayTime,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.green[700],
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () => _useAvailableSlot(slot, venue),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            minimumSize: Size(60, 32),
            textStyle: TextStyle(fontSize: 12),
          ),
          child: Text('Use This'),
        ),
      ),
    );
  }

// Use the selected available slot
  void _useAvailableSlot(TimeSlot slot, VenueModel venue) {
    // Close dialog first
    Get.back();

    try {
      // Parse and update the form with selected time slot
      final startParts = slot.start.split(':');
      final endParts = slot.end.split(':');

      startTime.value = TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      );

      endTime.value = TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      );

      // Show confirmation dialog
      Get.dialog(
        AlertDialog(
          title: Text('Confirm Time Change'),
          content: Text(
            'Change booking time to ${slot.displayTime}?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                // Show success message and auto-submit
                _showSuccess(
                    'Time updated to ${slot.displayTime}. Creating booking...');

                // Small delay for user to see the message
                Future.delayed(Duration(milliseconds: 500), () {
                  createBooking(venue);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('Confirm & Book'),
            ),
          ],
        ),
      );
    } catch (e) {
      showError('Failed to update time slot: $e');
    }
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

      final paymentData = {
        'booking_id': booking.id,
        'amount': booking.place?.price ?? 0,
      };

      final response = await _apiService.postRequest('/payment', paymentData);

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

          _showSuccess('Payment page opened. Complete your payment.');

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
      showError('Payment Error: ${e.toString()}');
    } finally {
      isProcessing.value = false;
    }
  }

  // UTILITY METHODS
  void clearForm() {
    selectedDate.value = null;
    capacityController.text = '10'; // Update untuk menggunakan controller baru
    selectedCapacity.value = '10';
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

  void _focusOnDatePicker() {
    print('📅 Focus on date picker to choose different date');
  }

  void showError(String message) {
    String userFriendlyMessage = _makeErrorUserFriendly(message);

    Get.snackbar(
      'Booking Error',
      userFriendlyMessage,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red[600],
      colorText: Colors.white,
      duration: Duration(seconds: 4),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      icon: Icon(Icons.error_outline, color: Colors.white),
    );
  }

  String _makeErrorUserFriendly(String technicalError) {
    final lowerError = technicalError.toLowerCase();

    if (lowerError.contains('venue not available') ||
        lowerError.contains('409') ||
        lowerError.contains('conflict')) {
      return 'This time slot is already booked. Please choose a different time.';
    }

    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return 'Connection problem. Please check your internet and try again.';
    }

    if (lowerError.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (lowerError.contains('validation') || lowerError.contains('invalid')) {
      return 'Please check your booking details and try again.';
    }

    if (lowerError.contains('unauthorized') || lowerError.contains('401')) {
      return 'Please log in again to continue.';
    }

    return 'Something went wrong. Please try again or contact support.';
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Booking Successful! 🎉',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green[600],
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      icon: Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }

  // NAVIGATION
  void goToBookingListPage() {
    Get.offAllNamed(MyRoutes.bottomNav);
    Get.find<BottomNavController>().changePage(1);
    Get.find<BookingListController>().refreshBookings();
  }
}
