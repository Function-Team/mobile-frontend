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
            venueId: venue.id,
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
          venue.id, startOfMonth, endOfMonth);

      // Refresh time slots if date is selected
      if (controller.selectedDate.value != null) {
        await controller.loadDetailedTimeSlots(
            venue.id, controller.selectedDate.value!);
      }

      print('BookingForm: Successfully refreshed availability data');
    } catch (e) {
      print('BookingForm: Error refreshing data: $e');
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
              timeSlots: timeSlots, // Use venue-specific time slots
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
    return Obx(() {
      final maxCapacity = venue.maxCapacity ?? 100;

      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Number of Guests',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Max: $maxCapacity',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Container dengan style seperti search capacity
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    // Icon - matching other fields
                    Icon(Icons.people_outline,
                        color: Colors.grey[600], size: 20),
                    const SizedBox(width: 12),

                    // Input field
                    Expanded(
                      child: TextField(
                        controller: controller.capacityController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter number of guests',
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onChanged: (value) => _handleCapacityInput(
                            value, maxCapacity, controller),
                      ),
                    ),

                    // Stepper Controls - sama seperti search
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Decrease button
                        _buildStepperButton(
                          icon: Icons.remove_circle_outline,
                          onTap: () => _decrementCapacity(controller),
                          enabled: true,
                        ),

                        const SizedBox(width: 4),

                        // Increase button
                        _buildStepperButton(
                          icon: Icons.add_circle_outline,
                          onTap: () =>
                              _incrementCapacity(controller, maxCapacity),
                          enabled: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Error message (kalau ada)
              if (!controller.isCapacityValid.value &&
                  controller.capacityErrorMessage.value.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    controller.capacityErrorMessage.value,
                    style: TextStyle(
                      color: Colors.red[600],
                      fontSize: 12,
                    ),
                  ),
                ),

              // Helper text
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Maximum capacity: $maxCapacity guests',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _guestInfoForm(BookingController controller) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Guest Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                // Form completion indicator
                Obx(() => controller.isFormComplete.value
                    ? Icon(Icons.check_circle, color: Colors.green, size: 20)
                    : Icon(Icons.radio_button_unchecked,
                        color: Colors.grey, size: 20)),
              ],
            ),
            SizedBox(height: 16),
            Obx(() => TextField(
                  controller: controller.guestNameController,
                  decoration: InputDecoration(
                    labelText: 'Guest Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                    errorText: controller.nameError.isEmpty
                        ? null
                        : controller.nameError.value,
                    suffixIcon: controller.nameError.isEmpty &&
                            controller.guestNameController.text.isNotEmpty
                        ? Icon(Icons.check, color: Colors.green, size: 20)
                        : controller.nameError.isNotEmpty
                            ? Icon(Icons.error, color: Colors.red, size: 20)
                            : null,
                  ),
                )),
            SizedBox(height: 12),
            Obx(() => TextField(
                  controller: controller.guestEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    errorText: controller.emailError.isEmpty
                        ? null
                        : controller.emailError.value,
                    suffixIcon: controller.emailError.isEmpty &&
                            controller.guestEmailController.text.isNotEmpty
                        ? Icon(Icons.check, color: Colors.green, size: 20)
                        : controller.emailError.isNotEmpty
                            ? Icon(Icons.error, color: Colors.red, size: 20)
                            : null,
                  ),
                )),
            SizedBox(height: 12),
            Obx(() => TextField(
                  controller: controller.guestPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    errorText: controller.phoneError.isEmpty
                        ? null
                        : controller.phoneError.value,
                    suffixIcon: controller.phoneError.isEmpty &&
                            controller.guestPhoneController.text.isNotEmpty
                        ? Icon(Icons.check, color: Colors.green, size: 20)
                        : controller.phoneError.isNotEmpty
                            ? Icon(Icons.error, color: Colors.red, size: 20)
                            : null,
                  ),
                )),
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
                      final validationResult = controller.validationService
                          .validateBookingFormWithSpecificError(
                        selectedDate: controller.selectedDate.value,
                        startTime: controller.startTime.value,
                        endTime: controller.endTime.value,
                        guestName: controller.guestNameController.text,
                        guestEmail: controller.guestEmailController.text,
                        guestPhone: controller.guestPhoneController.text,
                        capacityText: controller.capacityController.text,
                        venueMaxCapacity: venue.maxCapacity ?? 200,
                      );

                      if (!validationResult.isValid) {
                        // Show specific validation error using CustomSnackbar
                        controller.showError(validationResult.message);
                        return;
                      }

                      // All validations passed, proceed with booking
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

  Widget _buildFormHints(BookingController controller) {
    return Obx(() {
      final incomplete = <String>[];

      if (controller.selectedDate.value == null) incomplete.add('Date');
      if (controller.startTime.value == null ||
          controller.endTime.value == null ||
          controller.dateTimeError.isNotEmpty) incomplete.add('Time');
      if (controller.guestNameController.text.trim().isEmpty ||
          controller.nameError.isNotEmpty) incomplete.add('Name');
      if (controller.guestEmailController.text.trim().isEmpty ||
          controller.emailError.isNotEmpty) incomplete.add('Email');
      if (controller.guestPhoneController.text.trim().isEmpty ||
          controller.phoneError.isNotEmpty) incomplete.add('Phone');
      if (!controller.isCapacityValid.value) incomplete.add('Capacity');

      if (incomplete.isEmpty) {
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600], size: 18),
              SizedBox(width: 8),
              Text(
                'Form lengkap dan siap untuk booking!',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

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
                'Lengkapi: ${incomplete.join(', ')}',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // Helper: Generate time slots based on venue operating hours
  List<TimeOfDay> _generateTimeSlots() {
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
    if (currentHour == endHour && currentMinute == 0) {
      slots.add(TimeOfDay(hour: endHour, minute: 0));
    }

    return slots;
  }
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
        size: 20,
        color: enabled ? Colors.grey[600] : Colors.grey[400],
      ),
    ),
  );
}

void _handleCapacityInput(String value, int maxCapacity, BookingController controller) {
  // Allow empty or 0 temporarily untuk input flexibility
  if (value.isEmpty || value == '0') {
    return; // Don't auto-correct, let user continue typing
  }

  // Parse input
  int? inputValue = int.tryParse(value);
  
  if (inputValue == null) {
    // Invalid input - revert to previous valid value or 1
    controller.capacityController.text = '1';
    controller.capacityController.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.capacityController.text.length),
    );
    return;
  }

  // Auto-correct immediately if exceeds max capacity
  if (inputValue > maxCapacity) {
    controller.capacityController.text = maxCapacity.toString();
    controller.capacityController.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.capacityController.text.length),
    );
    controller.showInfo('Maximum capacity is $maxCapacity guests');
  }
}

// Decrease capacity
void _decrementCapacity(BookingController controller) {
  final currentValue = int.tryParse(controller.capacityController.text) ?? 1;
  if (currentValue > 0) {
    controller.capacityController.text = (currentValue - 1).toString();
    // Trigger validation after change
    controller.validateField('capacity');
  }
}

// Increase capacity dengan respect max capacity
void _incrementCapacity(BookingController controller, int maxCapacity) {
  final currentValue = int.tryParse(controller.capacityController.text) ?? 0;
  if (currentValue < maxCapacity) {
    controller.capacityController.text = (currentValue + 1).toString();
    // Trigger validation after change
    controller.validateField('capacity');
  } else {
    controller.showInfo('Maximum capacity is $maxCapacity guests');
  }
}