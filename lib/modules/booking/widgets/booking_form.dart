import 'package:flutter/material.dart';
import 'package:function_mobile/modules/booking/controllers/booking_controller.dart';
import 'package:function_mobile/modules/booking/widgets/time_slot_picker.dart';
import 'package:function_mobile/modules/booking/widgets/calendar_booking_widget.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookingForm extends StatelessWidget {
  final BookingController controller;
  final VenueModel venue;

  const BookingForm({
    Key? key,
    required this.controller,
    required this.venue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bookingTitle(),
          const SizedBox(height: 16),
          // Calendar widget
          CalendarBookingWidget(
            controller: controller,
            venueId: venue.id!,
          ),
          const SizedBox(height: 16),
          _timeRangePicker(controller),
          const SizedBox(height: 16),
          _durationDisplay(controller),
          const SizedBox(height: 16),
          _capacitySection(controller),
          const SizedBox(height: 16),
          _guestInfoForm(controller),
          const SizedBox(height: 24),
          _totalPriceDisplay(controller),
          const SizedBox(height: 24),
          _bookNowButton(controller),
        ],
      ),
    );
  }

  Future<void> refreshBookingData() async {
    try {
      print('🔄 BookingForm: Refreshing availability data...');

      // Refresh calendar availability for current month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      await controller.loadCalendarAvailability(
          venue.id!, startOfMonth, endOfMonth);

      // Refresh time slots if date is selected
      if (controller.selectedDate.value != null) {
        await controller.loadDetailedTimeSlots(
            venue.id!, controller.selectedDate.value!);
      }

      print('✅ BookingForm: Successfully refreshed availability data');
    } catch (e) {
      print('❌ BookingForm: Error refreshing data: $e');
      rethrow;
    }
  }

  Widget _bookingTitle() {
    return Text(
      'Booking Information',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _timeRangePicker(BookingController controller) {
    return Obx(() {
      // Generate time slots based on venue operating hours
      final timeSlots = _generateTimeSlots();

      return Row(
        children: [
          // Start Time
          Expanded(
            child: TimeSlotPicker(
              label: 'Start Time',
              selectedTime: controller.startTime.value,
              timeSlots: timeSlots, // Use venue-specific time slots
              onTimeSelected: (time) {
                controller.startTime.value = time;
                // Auto-set end time to +2 hours if not set, but respect venue hours
                if (controller.endTime.value == null) {
                  final endHour = (time.hour + 2) % 24;
                  final endTime = TimeOfDay(hour: endHour, minute: time.minute);

                  // Make sure end time is within venue operating hours
                  if (timeSlots.any((slot) =>
                      slot.hour == endTime.hour &&
                      slot.minute == endTime.minute)) {
                    controller.endTime.value = endTime;
                  } else {
                    // Find next available end time within operating hours
                    final availableEndTimes = timeSlots
                        .where((slot) =>
                            (slot.hour * 60 + slot.minute) >
                            (time.hour * 60 + time.minute))
                        .toList();

                    if (availableEndTimes.isNotEmpty) {
                      controller.endTime.value = availableEndTimes.first;
                    }
                  }
                }
              },
            ),
          ),

          SizedBox(width: 16),

          // End Time
          Expanded(
            child: TimeSlotPicker(
              label: 'End Time',
              selectedTime: controller.endTime.value,
              timeSlots: timeSlots,
              onTimeSelected: (time) {
                controller.endTime.value = time;
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _durationDisplay(BookingController controller) {
    return Obx(() {
      if (controller.selectedDate.value == null ||
          controller.startTime.value == null ||
          controller.endTime.value == null) {
        return SizedBox.shrink();
      }

      final selectedDate = controller.selectedDate.value!;
      final startTime = controller.startTime.value!;
      final endTime = controller.endTime.value!;

      final start = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        startTime.hour,
        startTime.minute,
      );

      final end = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        endTime.hour,
        endTime.minute,
      );

      final duration = end.difference(start);

      // Validate minimum duration
      if (duration < Duration(hours: 1)) {
        return Card(
          color: Colors.red[50],
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Minimum booking duration is 1 hour',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        );
      }

      // Validate maximum duration
      if (duration > Duration(days: 7)) {
        return Card(
          color: Colors.red[50],
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Maximum booking duration is 7 days',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        );
      }

      return Card(
        color: Colors.green[50],
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.access_time, color: Colors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Duration: ${controller.formatDuration(duration)}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _capacitySection(BookingController controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Number of Guests',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              SizedBox(height: 8),
              TextField(
                controller: controller.capacityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  hintText: 'Enter number of guests',
                  suffixText: 'guests',
                  errorText: !controller.isCapacityValid.value
                      ? controller.capacityErrorMessage.value
                      : null,
                  helperText:
                      'Maximum capacity: ${venue.maxCapacity ?? "Not specified"}',
                ),
                onChanged: (value) {
                  controller.validateCapacity(venue.maxCapacity ?? 200);
                },
              ),
              child: Row(
                children: [
                  // Icon
                  Icon(Icons.people_outline, color: Colors.grey[600], size: 20),
                  SizedBox(width: 12),

                  // Input field
                  Expanded(
                      child: TextField(
                    controller: controller.guestCountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter number of guests',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onChanged: (value) => controller.updateGuestCount(value),
                  )),

                  // Stepper Controls
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Decrease button
                      _buildStepperButton(
                        icon: Icons.remove_circle_outline,
                        onTap: () => controller.decrementGuestCount(),
                        enabled: controller.guestCount.value > 1,
                      ),

                      SizedBox(width: 4),

                      // Increase button
                      _buildStepperButton(
                        icon: Icons.add_circle_outline,
                        onTap: () => controller.incrementGuestCount(),
                        enabled: controller.guestCount.value <
                            controller.maxVenueCapacity.value,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Max capacity info
            SizedBox(height: 8),
            Text(
              'Maximum capacity: ${controller.maxVenueCapacity.value} guests',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),

            // Validation message
            Obx(() {
              if (controller.guestCount.value >
                  controller.maxVenueCapacity.value) {
                return Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Guest count exceeds maximum capacity',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _guestInfoForm(BookingController controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guest Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller.guestNameController,
              decoration: InputDecoration(
                labelText: 'Guest Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: controller.guestEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: controller.guestPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: controller.specialRequestsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Special Requests (Optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalPriceDisplay(BookingController controller) {
    return Obx(() {
      if (controller.selectedDate.value == null ||
          controller.startTime.value == null ||
          controller.endTime.value == null) {
        return SizedBox.shrink();
      }

      final selectedDate = controller.selectedDate.value!;
      final startTime = controller.startTime.value!;
      final endTime = controller.endTime.value!;

      final start = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        startTime.hour,
        startTime.minute,
      );

      final end = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        endTime.hour,
        endTime.minute,
      );

      final duration = end.difference(start);
      final totalHours = duration.inMinutes / 60.0;
      final totalAmount = (venue.price ?? 0) * totalHours;

      if (duration < Duration(hours: 1) || duration > Duration(days: 7)) {
        return SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Base Price/hour'),
                Text('Rp ${NumberFormat('#,###').format(venue.price ?? 0)}'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Duration'),
                Text('${totalHours.toStringAsFixed(1)} hours'),
              ],
            ),
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Rp ${NumberFormat('#,###').format(totalAmount)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ALWAYS ACTIVE BOOKING BUTTON - Super Simple Approach
  Widget _bookNowButton(BookingController controller) {
    return Obx(() {
      final isProcessing = controller.isProcessing.value;

      return Column(
        children: [
          _buildFormHints(controller),
          SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: !isProcessing
                  ? () {
                      // Validate only when button is pressed
                      if (!_isFormComplete(controller)) {
                        final errorMessage = _getValidationError(controller);
                        controller.showError(errorMessage);
                        return;
                      }

                      // Proceed with booking
                      controller.createBooking(venue);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor:
                    !isProcessing ? Get.theme.primaryColor : Colors.grey[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isProcessing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Creating Booking...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      );
    });
  }

  // Simple form completion check (no reactive state)
  bool _isFormComplete(BookingController controller) {
    // Check basic fields
    if (controller.selectedDate.value == null) return false;
    if (controller.startTime.value == null || controller.endTime.value == null)
      return false;

    // Check guest info
    if (controller.guestNameController.text.trim().isEmpty) return false;
    if (controller.guestEmailController.text.trim().isEmpty) return false;
    if (controller.guestPhoneController.text.trim().isEmpty) return false;

    // Check email format
    if (!_isValidEmail(controller.guestEmailController.text.trim()))
      return false;

    // Check duration
    if (!_isValidDuration(controller)) return false;

    // Check capacity
    try {
      final capacity = int.parse(controller.capacityController.text.trim());
      if (capacity <= 0 || capacity > (venue.maxCapacity ?? 200)) return false;
    } catch (e) {
      return false;
    }

    return true;
  }

  // Get specific validation error message
  String _getValidationError(BookingController controller) {
    if (controller.selectedDate.value == null) {
      return 'Please select a booking date';
    }

    if (controller.startTime.value == null ||
        controller.endTime.value == null) {
      return 'Please select start and end times';
    }

    if (!_isValidDuration(controller)) {
      return 'Booking duration must be between 1 hour and 7 days';
    }

    if (controller.guestNameController.text.trim().isEmpty) {
      return 'Please enter your name';
    }

    if (controller.guestEmailController.text.trim().isEmpty) {
      return 'Please enter your email address';
    }

    if (!_isValidEmail(controller.guestEmailController.text.trim())) {
      return 'Please enter a valid email address';
    }

    if (controller.guestPhoneController.text.trim().isEmpty) {
      return 'Please enter your phone number';
    }

    // Validasi kapasitas
    try {
      final capacity = int.parse(controller.capacityController.text.trim());
      if (capacity <= 0) {
        return 'Capacity must be greater than 0';
      }
      if (capacity > (venue.maxCapacity ?? 200)) {
        return 'Capacity cannot exceed venue maximum of ${venue.maxCapacity ?? 200}';
      }
    } catch (e) {
      return 'Please enter a valid number for capacity';
    }

    return 'Please complete all required fields';
  }

  // Helper: Show friendly form hints (optional visual feedback)
  Widget _buildFormHints(BookingController controller) {
    final incomplete = <String>[];

    if (controller.selectedDate.value == null) incomplete.add('Date');
    if (controller.startTime.value == null || controller.endTime.value == null)
      incomplete.add('Time');
    if (controller.guestNameController.text.trim().isEmpty)
      incomplete.add('Name');
    if (controller.guestEmailController.text.trim().isEmpty)
      incomplete.add('Email');
    if (controller.guestPhoneController.text.trim().isEmpty)
      incomplete.add('Phone');

    if (incomplete.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[600], size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Complete: ${incomplete.join(', ')}',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Duration validation
  bool _isValidDuration(BookingController controller) {
    if (controller.selectedDate.value == null ||
        controller.startTime.value == null ||
        controller.endTime.value == null) {
      return false;
    }

    final selectedDate = controller.selectedDate.value!;
    final startTime = controller.startTime.value!;
    final endTime = controller.endTime.value!;

    final start = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime.hour,
      startTime.minute,
    );

    final end = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      endTime.hour,
      endTime.minute,
    );

    final duration = end.difference(start);
    return duration >= Duration(hours: 1) && duration <= Duration(days: 7);
  }

  // Helper: Generate time slots based on venue operating hours
  List<TimeOfDay> _generateTimeSlots() {
    // Get venue operating hours from time slots data (8 AM - 10 PM default)
    final timeSlots = controller.detailedTimeSlots;

    if (timeSlots.isNotEmpty) {
      // Extract operating hours from available slots
      final firstSlot = timeSlots.first;
      final lastSlot = timeSlots.last;

      final startHour = int.parse(firstSlot.start.split(':')[0]);
      final endHour = int.parse(lastSlot.end.split(':')[0]);
      final endMinute = int.parse(lastSlot.end.split(':')[1]);

      return _generateTimeSlotsInRange(startHour, 0, endHour, endMinute);
    }

    // Default: 8 AM - 10 PM (based on backend operating hours)
    return _generateTimeSlotsInRange(8, 0, 22, 0);
  }

  List<TimeOfDay> _generateTimeSlotsInRange(
      int startHour, int startMinute, int endHour, int endMinute) {
    final slots = <TimeOfDay>[];

    // Start from venue opening time
    int currentHour = startHour;
    int currentMinute = startMinute;

    // Generate 30-minute intervals until closing time
    while (currentHour < endHour ||
        (currentHour == endHour && currentMinute < endMinute)) {
      slots.add(TimeOfDay(hour: currentHour, minute: currentMinute));

      // Add 30 minutes
      currentMinute += 30;
      if (currentMinute >= 60) {
        currentMinute = 0;
        currentHour++;
      }
    }

    // Add final time slot at closing time
    if (currentHour == endHour && currentMinute == endMinute) {
      slots.add(TimeOfDay(hour: currentHour, minute: currentMinute));
    }

    return slots;
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.all(4),
        child: Icon(
          icon,
          color: enabled ? Colors.blue[600] : Colors.grey[400],
          size: 24,
        ),
      ),
    );
  }
}
