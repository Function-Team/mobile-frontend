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
          // REPLACE DateTimeRange picker with Calendar
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

  // SIMPLIFIED: Single "Book Now" button with smart handling
  Widget _bookNowButton(BookingController controller) {
    return Obx(() {
      final isValidForm = controller.selectedDate.value != null &&
          controller.startTime.value != null &&
          controller.endTime.value != null &&
          controller.guestNameController.text.trim().isNotEmpty &&
          controller.guestEmailController.text.trim().isNotEmpty;

      final isDurationValid = _isDurationValid(controller);

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed:
              (isValidForm && isDurationValid && !controller.isProcessing.value)
                  ? () => controller.createBooking(venue)
                  : null,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Get.theme.primaryColor,
          ),
          child: controller.isProcessing.value
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
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
      );
    });
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

  bool _isDurationValid(BookingController controller) {
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
}