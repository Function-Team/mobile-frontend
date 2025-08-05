// lib/modules/booking/controllers/booking_controller.dart - CLEANED VERSION

import 'package:flutter/material.dart';
import 'package:function_mobile/common/routes/routes.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/modules/booking/controllers/booking_list_controller.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/booking/models/booking_response_models.dart';
import 'package:function_mobile/modules/booking/services/booking_service.dart';
import 'package:function_mobile/modules/navigation/controllers/bottom_nav_controller.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class BookingController extends GetxController {
  final ApiService _apiService = ApiService();

  // SINGLE DATE STATE (Remove DateTimeRange)
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  
  // Form data
  final RxString selectedCapacity = '10'.obs;
  final RxList<String> capacityOptions = ['10', '20', '50', '100', '200'].obs;
  
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

  // CALENDAR METHODS
  Future<void> loadCalendarAvailability(int venueId, DateTime startDate, DateTime endDate) async {
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
      _showError('Failed to load calendar availability: ${e.toString()}');
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
      _showError('Failed to load time slots: ${e.toString()}');
    } finally {
      isLoadingTimeSlots.value = false;
    }
  }

  String getAvailabilityStatus(DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return calendarAvailability[dateStr] ?? 'unknown';
  }

  // MAIN BOOKING METHOD (Unified approach)
  Future<void> createBooking(VenueModel venue) async {
    if (!isFormValid()) return;

    try {
      isProcessing.value = true;
      bookingStatus.value = 'processing';

      final bookingRequest = BookingCreateRequest.fromVenueAndForm(
        venue: venue,
        date: selectedDate.value!,
        startTime: startTime.value!,
        endTime: endTime.value!,
        capacity: int.parse(selectedCapacity.value),
        specialRequests: specialRequestsController.text.trim(),
        userName: guestNameController.text.trim(),
        userEmail: guestEmailController.text.trim(),
        userPhone: guestPhoneController.text.trim(),
      );

      final service = BookingService();
      final response = await service.createBookingWithBuiltInValidation(bookingRequest);

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
        // Conflict - show improved dialog with quick actions
        bookingStatus.value = 'failed';
        _showConflictDialog(response.availableSlots, venue);
      }
    } catch (e) {
      bookingStatus.value = 'failed';
      _showError('Error: ${e.toString()}');
    } finally {
      isProcessing.value = false;
    }
  }

  // SIMPLIFIED FORM VALIDATION (Backend handles time validation)
  bool isFormValid() {
    if (selectedDate.value == null) {
      _showError('Please select booking date');
      return false;
    }

    if (startTime.value == null || endTime.value == null) {
      _showError('Please select start and end times');
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

  // IMPROVED CONFLICT DIALOG
  void _showConflictDialog(List<TimeSlot> slots, VenueModel venue) {
    Get.dialog(
      AlertDialog(
        title: Text('Time Slot Not Available'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The selected time slot is already booked.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (slots.isNotEmpty) ...[
              Text('Available alternatives:'),
              SizedBox(height: 8),
              ...slots.take(3).map((slot) => Container(
                margin: EdgeInsets.symmetric(vertical: 2),
                child: ElevatedButton(
                  onPressed: () => _useAlternativeSlot(slot, venue),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[50],
                    foregroundColor: Colors.green[700],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 16),
                      SizedBox(width: 8),
                      Text('Use ${slot.start} - ${slot.end}'),
                    ],
                  ),
                ),
              )).toList(),
            ] else ...[
              Text('No available slots for this date.'),
              Text('Please try a different date.'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          if (slots.isNotEmpty)
            TextButton(
              onPressed: () {
                Get.back();
                _showAllAvailableSlots(slots, venue);
              },
              child: Text('View All Slots'),
            ),
        ],
      ),
    );
  }

  void _useAlternativeSlot(TimeSlot slot, VenueModel venue) {
    Get.back();
    
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
    
    Get.snackbar(
      'Time Updated',
      'Using ${slot.start} - ${slot.end}. Creating booking...',
      backgroundColor: Colors.green[100],
    );
    
    Future.delayed(Duration(milliseconds: 500), () {
      createBooking(venue);
    });
  }

  void _showAllAvailableSlots(List<TimeSlot> slots, VenueModel venue) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Available Time Slots',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: slots.length,
                itemBuilder: (context, index) {
                  final slot = slots[index];
                  return ElevatedButton(
                    onPressed: () => _useAlternativeSlot(slot, venue),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[50],
                      foregroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '${slot.start} - ${slot.end}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SETTERS (Keep for backward compatibility)
  void setCapacity(String capacity) {
    selectedCapacity.value = capacity;
  }

  void setStartTime(TimeOfDay time) {
    startTime.value = time;
  }

  void setEndTime(TimeOfDay time) {
    endTime.value = time;
  }

  // PAYMENT METHODS (Keep existing)
  Future<void> createPaymentForBooking(BookingModel booking) async {
    try {
      isProcessing.value = true;

      if (!booking.isConfirmed) {
        _showError('Booking must be confirmed by admin before payment');
        return;
      }

      if (booking.payment != null &&
          booking.payment!.status.toLowerCase() == 'success') {
        _showError('Payment already completed for this booking');
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
      _showError('Payment Error: ${e.toString()}');
    } finally {
      isProcessing.value = false;
    }
  }

  // UTILITY METHODS
  void clearForm() {
    selectedDate.value = null;
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

  // NAVIGATION
  void goToBookingListPage() {
    Get.offAllNamed(MyRoutes.bottomNav);
    Get.find<BottomNavController>().changePage(1);
    Get.find<BookingListController>().refreshBookings();
  }
}