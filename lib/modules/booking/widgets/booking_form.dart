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
          _capacityDropdown(controller),
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
    final timeSlots = _generateTimeSlots();

    return Obx(() {
      return Row(
        children: [
          // Start Time
          Expanded(
            child: TimeSlotPicker(
              label: 'Start Time',
              selectedTime: controller.startTime.value,
              timeSlots: timeSlots,
              onTimeSelected: (time) {
                controller.startTime.value = time;
                // Auto-set end time to +2 hours if not set
                if (controller.endTime.value == null) {
                  final endHour = (time.hour + 2) % 24;
                  controller.endTime.value =
                      TimeOfDay(hour: endHour, minute: time.minute);
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

  Widget _capacityDropdown(BookingController controller) {
    return Obx(() {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Number of Guests',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: controller.selectedCapacity.value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: controller.capacityOptions.map((String capacity) {
                  return DropdownMenuItem<String>(
                    value: capacity,
                    child: Text('$capacity guests'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedCapacity.value = value;
                  }
                },
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

  // IMPROVED BOOKING BUTTON with comprehensive validation
  Widget _bookNowButton(BookingController controller) {
    return Obx(() {
      final isProcessing = controller.isProcessing.value;
      final isValid = _isFormValidForSubmission(controller);

      return Column(
        children: [
          // Show validation errors if form is not valid
          if (!isValid && !isProcessing) ...[
            _buildValidationErrors(controller),
            SizedBox(height: 16),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isValid && !isProcessing
                  ? () {
                      print(
                          'Book Now button pressed - starting booking process');
                      controller.createBooking(venue);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor:
                    isValid ? Get.theme.primaryColor : Colors.grey[400],
                disabledBackgroundColor: Colors.grey[400],
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
                        color: isValid ? Colors.white : Colors.grey[600],
                      ),
                    ),
            ),
          ),
        ],
      );
    });
  }

  // COMPREHENSIVE FORM VALIDATION
  bool _isFormValidForSubmission(BookingController controller) {
    // Check basic form fields
    if (controller.selectedDate.value == null) return false;
    if (controller.startTime.value == null || controller.endTime.value == null)
      return false;

    // Check guest information
    if (controller.guestNameController.text.trim().isEmpty) return false;
    if (controller.guestEmailController.text.trim().isEmpty) return false;
    if (controller.guestPhoneController.text.trim().isEmpty) return false;

    // Check email format
    if (!_isValidEmail(controller.guestEmailController.text.trim()))
      return false;

    // Check time slot duration is valid
    if (!_isTimeSlotDurationValid(controller)) return false;

    // Check not currently processing
    if (controller.isProcessing.value) return false;

    return true;
  }

  // Helper method to validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Helper method to validate time slot duration
  bool _isTimeSlotDurationValid(BookingController controller) {
    if (controller.selectedDate.value == null ||
        controller.startTime.value == null ||
        controller.endTime.value == null) {
      return false;
    }

    final selectedDateValue = controller.selectedDate.value!;
    final startTimeValue = controller.startTime.value!;
    final endTimeValue = controller.endTime.value!;

    final start = DateTime(
      selectedDateValue.year,
      selectedDateValue.month,
      selectedDateValue.day,
      startTimeValue.hour,
      startTimeValue.minute,
    );

    final end = DateTime(
      selectedDateValue.year,
      selectedDateValue.month,
      selectedDateValue.day,
      endTimeValue.hour,
      endTimeValue.minute,
    );

    final duration = end.difference(start);

    // Must be at least 1 hour and maximum 7 days
    return duration >= Duration(hours: 1) && duration <= Duration(days: 7);
  }

  // Helper widget to show validation errors
  Widget _buildValidationErrors(BookingController controller) {
    final errors = <String>[];

    if (controller.selectedDate.value == null) {
      errors.add('Please select a booking date');
    }

    if (controller.startTime.value == null ||
        controller.endTime.value == null) {
      errors.add('Please select start and end times');
    } else if (!_isTimeSlotDurationValid(controller)) {
      errors.add('Booking duration must be between 1 hour and 7 days');
    }

    if (controller.guestNameController.text.trim().isEmpty) {
      errors.add('Please enter guest name');
    }

    if (controller.guestEmailController.text.trim().isEmpty) {
      errors.add('Please enter email address');
    } else if (!_isValidEmail(controller.guestEmailController.text.trim())) {
      errors.add('Please enter a valid email address');
    }

    if (controller.guestPhoneController.text.trim().isEmpty) {
      errors.add('Please enter phone number');
    }

    if (errors.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
              SizedBox(width: 8),
              Text(
                'Please complete the form:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ...errors
              .map((error) => Padding(
                    padding: EdgeInsets.only(left: 28, bottom: 4),
                    child: Text(
                      '• $error',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 13,
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  // Helper methods
  List<TimeOfDay> _generateTimeSlots() {
    final slots = <TimeOfDay>[];
    for (int hour = 0; hour < 24; hour++) {
      slots.add(TimeOfDay(hour: hour, minute: 0));
      slots.add(TimeOfDay(hour: hour, minute: 30));
    }
    return slots;
  }
}
