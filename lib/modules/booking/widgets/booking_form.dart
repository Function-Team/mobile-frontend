import 'package:flutter/material.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
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
          // Date & Time Selection Card
          _buildDateTimeCard(),
          const SizedBox(height: 16),

          // Duration & Capacity Card
          _buildDurationCapacityCard(),
          const SizedBox(height: 16),

          // Guest Information Card
          _guestInfoForm(controller),
          const SizedBox(height: 16),

          // Price Summary Card
          _buildPriceSummaryCard(),
          const SizedBox(height: 24),

          // Book Now Button
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


  // Date & Time Selection Card
  Widget _buildDateTimeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(Get.context!).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    LocalizationHelper.tr(LocaleKeys.booking_selectDate),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Calendar widget
            CalendarBookingWidget(
              controller: controller,
              venueId: venue.id,
            ),
            const SizedBox(height: 16),

            // Time selection info
            _timeSelectionInfo(controller),
          ],
        ),
      ),
    );
  }

  // Duration & Capacity Card
  Widget _buildDurationCapacityCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Theme.of(Get.context!).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    LocalizationHelper.tr(LocaleKeys.booking_duration),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Duration Display
            _durationDisplay(controller),
            const SizedBox(height: 16),

            // Capacity Section
            _capacitySection(controller),
          ],
        ),
      ),
    );
  }

  // Price Summary Card
  Widget _buildPriceSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: Theme.of(Get.context!).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    LocalizationHelper.tr(LocaleKeys.booking_priceSummary),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price Display
            _totalPriceDisplay(controller),
          ],
        ),
      ),
    );
  }

  Widget _timeSelectionInfo(BookingController controller) {
    return Obx(() {
      final startTime = controller.startTime.value;
      final endTime = controller.endTime.value;

      if (startTime == null || endTime == null) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  LocalizationHelper.tr(LocaleKeys.booking_selectTime),
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Colors.green[600], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${LocalizationHelper.tr(LocaleKeys.booking_timeSlot)}: ${_formatTime(startTime)} - ${_formatTime(endTime)}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.red[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  LocalizationHelper.tr(LocaleKeys.errors_validationError),
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // Validate maximum duration
      if (duration > Duration(days: 7)) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.red[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  LocalizationHelper.tr(LocaleKeys.errors_validationError),
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Duration: ${controller.formatDuration(duration)}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _capacitySection(BookingController controller) {
    return Obx(() {
      final maxCapacity = venue.maxCapacity ?? 100;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.people_outline,
                color: Theme.of(Get.context!).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                LocalizationHelper.tr(LocaleKeys.search_guestCount),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${LocalizationHelper.tr(LocaleKeys.common_capacity)}: $maxCapacity',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(Get.context!).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Container dengan style seperti search capacity
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                // Input field
                Expanded(
                  child: TextField(
                    controller: controller.capacityController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: LocalizationHelper.tr(
                          LocaleKeys.forms_enterNumberOfGuests),
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onChanged: (value) =>
                        _handleCapacityInput(value, maxCapacity, controller),
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
                      onTap: () => _incrementCapacity(controller, maxCapacity),
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
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                controller.capacityErrorMessage.value,
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _guestInfoForm(BookingController controller) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: Theme.of(Get.context!).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    LocalizationHelper.tr(LocaleKeys.booking_guestInformation),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() => TextField(
                  controller: controller.guestNameController,
                  decoration: InputDecoration(
                    labelText:
                        LocalizationHelper.tr(LocaleKeys.labels_guestNameLabel),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                    errorText: controller.nameError.isEmpty
                        ? null
                        : controller.nameError.value,
                    suffixIcon: controller.nameError.isNotEmpty
                        ? Icon(Icons.error, color: Colors.red, size: 20)
                        : null,
                  ),
                )),
            SizedBox(height: 12),
            Obx(() => TextField(
                  controller: controller.guestEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText:
                        LocalizationHelper.tr(LocaleKeys.labels_emailLabel),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    errorText: controller.emailError.isEmpty
                        ? null
                        : controller.emailError.value,
                    suffixIcon: controller.emailError.isNotEmpty
                        ? Icon(Icons.error, color: Colors.red, size: 20)
                        : null,
                  ),
                )),
            SizedBox(height: 12),
            Obx(() => TextField(
                  controller: controller.guestPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText:
                        LocalizationHelper.tr(LocaleKeys.labels_phoneLabel),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    errorText: controller.phoneError.isEmpty
                        ? null
                        : controller.phoneError.value,
                    suffixIcon: controller.phoneError.isNotEmpty
                        ? Icon(Icons.error, color: Colors.red, size: 20)
                        : null,
                  ),
                )),
            SizedBox(height: 12),
            TextField(
              controller: controller.specialRequestsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: LocalizationHelper.tr(
                    LocaleKeys.labels_specialRequestsLabel),
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
              LocalizationHelper.tr(LocaleKeys.booking_priceSummary),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(LocalizationHelper.tr(
                    LocaleKeys.labels_basePricePerHourLabel)),
                Text('Rp ${NumberFormat('#,###').format(venue.price ?? 0)}'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(LocalizationHelper.tr(LocaleKeys.labels_durationLabel)),
                Text(
                    '${totalHours.toStringAsFixed(1)} ${LocalizationHelper.tr(LocaleKeys.labels_hoursText)}'),
              ],
            ),
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocalizationHelper.tr(LocaleKeys.booking_totalAmount),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Rp ${NumberFormat('#,###').format(totalAmount)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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
                backgroundColor: Get.theme.primaryColor,
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
                          LocalizationHelper.tr(LocaleKeys.booking_processingPayment),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      LocalizationHelper.tr(LocaleKeys.booking_bookNow),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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

      if (controller.selectedDate.value == null) incomplete.add(LocalizationHelper.tr(LocaleKeys.common_date));
      if (controller.startTime.value == null ||
          controller.endTime.value == null ||
          controller.dateTimeError.isNotEmpty) incomplete.add(LocalizationHelper.tr(LocaleKeys.common_time));
      if (controller.guestNameController.text.trim().isEmpty ||
          controller.nameError.isNotEmpty) incomplete.add(LocalizationHelper.tr(LocaleKeys.forms_guestName));
      if (controller.guestEmailController.text.trim().isEmpty ||
          controller.emailError.isNotEmpty) incomplete.add(LocalizationHelper.tr(LocaleKeys.forms_email));
      if (controller.guestPhoneController.text.trim().isEmpty ||
          controller.phoneError.isNotEmpty) incomplete.add(LocalizationHelper.tr(LocaleKeys.forms_phoneNumber));
      if (!controller.isCapacityValid.value) incomplete.add(LocalizationHelper.tr(LocaleKeys.common_capacity));

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
                LocalizationHelper.tr(LocaleKeys.common_success),
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
                '${LocalizationHelper.tr(LocaleKeys.common_error)}: ${incomplete.join(', ')}',
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

  // Optimized: Generate time slots with caching
  static final List<TimeOfDay> _cachedTimeSlots = _generateTimeSlotsRange(8, 0, 22, 0);
  
  List<TimeOfDay> _generateTimeSlots() => _cachedTimeSlots;

  static List<TimeOfDay> _generateTimeSlotsRange(
      int startHour, int startMinute, int endHour, int endMinute) {
    final slots = <TimeOfDay>[];
    int currentHour = startHour;
    int currentMinute = startMinute;

    while (currentHour < endHour ||
        (currentHour == endHour && currentMinute < endMinute)) {
      slots.add(TimeOfDay(hour: currentHour, minute: currentMinute));
      
      currentMinute += 30;
      if (currentMinute >= 60) {
        currentMinute = 0;
        currentHour++;
      }
    }

    if (currentHour == endHour && currentMinute == 0) {
      slots.add(TimeOfDay(hour: endHour, minute: 0));
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
          size: 20,
          color: enabled ? Colors.grey[600] : Colors.grey[400],
        ),
      ),
    );
  }

  void _handleCapacityInput(
      String value, int maxCapacity, BookingController controller) {
    if (value.isEmpty || value == '0') return;

    final inputValue = int.tryParse(value);
    if (inputValue == null) {
      _setCapacityValue(controller, '1');
      return;
    }

    if (inputValue > maxCapacity) {
      _setCapacityValue(controller, maxCapacity.toString());
      controller.showInfo(LocalizationHelper.tr(LocaleKeys.errors_capacityExceeded));
    }
  }

  void _setCapacityValue(BookingController controller, String value) {
    controller.capacityController.text = value;
    controller.capacityController.selection = TextSelection.fromPosition(
      TextPosition(offset: value.length),
    );
  }

  void _decrementCapacity(BookingController controller) {
    final currentValue = int.tryParse(controller.capacityController.text) ?? 1;
    if (currentValue > 0) {
      controller.capacityController.text = (currentValue - 1).toString();
      controller.validateField('capacity');
    }
  }

  void _incrementCapacity(BookingController controller, int maxCapacity) {
    final currentValue = int.tryParse(controller.capacityController.text) ?? 0;
    if (currentValue < maxCapacity) {
      controller.capacityController.text = (currentValue + 1).toString();
      controller.validateField('capacity');
    } else {
      controller.showInfo(LocalizationHelper.tr(LocaleKeys.errors_capacityExceeded));
    }
  }
}
