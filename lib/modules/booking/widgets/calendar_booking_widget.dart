import 'package:flutter/material.dart';
import 'package:function_mobile/modules/booking/models/booking_response_models.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:function_mobile/modules/booking/controllers/booking_controller.dart';
import 'package:function_mobile/modules/booking/controllers/calendar_booking_controller.dart';

class CalendarBookingWidget extends GetView<CalendarBookingController> {
  final BookingController bookingController;
  final int venueId;

  const CalendarBookingWidget({
    super.key,
    required this.bookingController,
    required this.venueId,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controller with dependency injection
    Get.put(CalendarBookingController(
      bookingController: bookingController,
      venueId: venueId,
    ));

    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildCalendarHeader(),
            _buildTableCalendar(),
            _buildTimeSlotGrid(),
          ],
        ),
      );
    });
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Get.theme.primaryColor.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today,
                  color: Get.theme.primaryColor, size: 24),
              SizedBox(width: 12),
              Text(
                'Select Date & Time',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Choose your preferred date and available time slots below',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          _buildAvailabilityLegend(),
        ],
      ),
    );
  }

  Widget _buildAvailabilityLegend() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(child: _buildLegendItem(Colors.green[200]!, 'Available')),
          Flexible(child: _buildLegendItem(Colors.orange[200]!, 'Limited')),
          Flexible(child: _buildLegendItem(Colors.red[200]!, 'Fully Booked')),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _getBorderColor(label),
              width: 1.5,
            ),
          ),
        ),
        SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getBorderColor(String label) {
    return controller.getBorderColor(label);
  }

  Widget _buildTableCalendar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TableCalendar<String>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: controller.selectedDate ?? DateTime.now(),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,

        // Enhanced selection logic
        selectedDayPredicate: (day) {
          return controller.selectedDate != null &&
              isSameDay(controller.selectedDate!, day);
        },

        // Enhanced available days logic
        enabledDayPredicate: (day) {
          // Disable past dates
          return !day.isBefore(DateTime.now().subtract(Duration(days: 1)));
        },

        // Custom calendar builders - SIMPLIFIED (no text info)
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return _buildSimpleDayCell(day, false, false);
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildSimpleDayCell(day, true, false);
          },
          selectedBuilder: (context, day, focusedDay) {
            return _buildSimpleDayCell(day, false, true);
          },
          disabledBuilder: (context, day, focusedDay) {
            return _buildDisabledDayCell(day);
          },
        ),

        // Enhanced header styling
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: Get.theme.primaryColor,
            size: 28,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: Get.theme.primaryColor,
            size: 28,
          ),
        ),

        // Enhanced days of week styling
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),

        // Clean calendar style
        calendarStyle: CalendarStyle(
          cellMargin: EdgeInsets.all(2),
          defaultDecoration: BoxDecoration(),
          todayDecoration: BoxDecoration(),
          selectedDecoration: BoxDecoration(),
          outsideDecoration: BoxDecoration(),
          disabledDecoration: BoxDecoration(),
        ),

        // Enhanced event handling
        onDaySelected: (selectedDay, focusedDay) {
          controller.onDaySelected(selectedDay);
        },

        onPageChanged: (focusedDay) {
          controller.onPageChanged(focusedDay);
        },
      ),
    );
  }

  // SIMPLIFIED calendar cells - only color, no text info
  Widget _buildSimpleDayCell(DateTime day, bool isToday, bool isSelected) {
    final availability = controller.getAvailabilityStatus(day);

    Color backgroundColor;
    Color borderColor;
    Color textColor = Colors.grey[800]!;

    // Determine colors based on selection and availability
    if (isSelected) {
      backgroundColor = Get.theme.primaryColor;
      borderColor = Get.theme.primaryColor;
      textColor = Colors.white;
    } else {
      backgroundColor = controller.getColorForAvailability(availability);
      borderColor =
          isToday ? Colors.blue : controller.getBorderColorForAvailability(availability);

      if (availability == 'booked') {
        textColor = Colors.grey[500]!;
      }
    }

    return Container(
      margin: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontSize: 14,
            fontWeight:
                isToday || isSelected ? FontWeight.bold : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDisabledDayCell(DateTime day) {
    return Container(
      margin: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotGrid() {
    return Obx(() {
      if (controller.selectedDate == null) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.touch_app, size: 48, color: Colors.grey[300]),
              SizedBox(height: 12),
              Text(
                'Select a date to view available time slots',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      if (controller.isLoadingTimeSlots) {
        return Container(
          height: 120,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text(
                  'Loading available time slots...',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      }

      final timeSlots = controller.detailedTimeSlots;
      final selectedDate = controller.selectedDate!;

      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time,
                    color: Get.theme.primaryColor, size: 20),
                SizedBox(width: 8),
                Text(
                  'Available Time Slots',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              '${controller.formatSelectedDate(selectedDate)} • ${timeSlots.where((slot) => slot.available && controller.isSlotWithinOperatingHours(slot)).length} of ${timeSlots.length} slots available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
            SizedBox(height: 16),
            if (timeSlots.isEmpty) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_busy, color: Colors.red[600], size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No time slots available for this date. Please select another date.',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Time slots grid (4 columns)
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  final slot = timeSlots[index];
                  return Obx(() => _buildTimeSlotChip(slot));
                },
              ),

              SizedBox(height: 16),
              _buildTimeSlotLegend(),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildTimeSlotChip(DetailedTimeSlot slot) {
    final isAvailable = slot.available && controller.isSlotWithinOperatingHours(slot);
    final isSelected = controller.isSlotSelected(slot);

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (!isAvailable) {
      // Booked/Unavailable - Red
      backgroundColor = Colors.red[100]!;
      borderColor = Colors.red[300]!;
      textColor = Colors.red[600]!;
    } else if (isSelected) {
      // Selected - Blue/Primary
      backgroundColor = Get.theme.primaryColor;
      borderColor = Get.theme.primaryColor;
      textColor = Colors.white;
    } else {
      // Available - Green
      backgroundColor = Colors.green[50]!;
      borderColor = Colors.green[300]!;
      textColor = Colors.green[700]!;
    }

    return GestureDetector(
      onTap: isAvailable ? () => controller.onSlotTap(slot) : null,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Get.theme.primaryColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                slot.start,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotLegend() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            child: _buildSlotLegendItem(
              Colors.green[50]!,
              Colors.green[300]!,
              Colors.green[700]!,
              'Available',
              Icons.check_circle_outline,
            ),
          ),
          Flexible(
            child: _buildSlotLegendItem(
              Get.theme.primaryColor,
              Get.theme.primaryColor,
              Colors.white,
              'Selected',
              Icons.radio_button_checked,
            ),
          ),
          Flexible(
            child: _buildSlotLegendItem(
              Colors.red[100]!,
              Colors.red[300]!,
              Colors.red[600]!,
              'Booked',
              Icons.block,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotLegendItem(
    Color bgColor,
    Color borderColor,
    Color textColor,
    String label,
    IconData icon,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor),
          ),
          child: Icon(
            icon,
            color: textColor,
            size: 10,
          ),
        ),
        SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Helper methods moved to CalendarBookingController

  // All business logic methods moved to CalendarBookingController

  // NEW: Force refresh calendar and time slots data
  void refreshAvailabilityData() {
    final currentDate = controller.selectedDate;
    if (currentDate != null) {
      // Refresh calendar for current month
      final startOfMonth = DateTime(currentDate.year, currentDate.month, 1);
      final endOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);

      // Force refresh both calendar and time slots
      controller
          .loadCalendarAvailability(controller.venueId, startOfMonth, endOfMonth);
      controller.loadDetailedTimeSlots(controller.venueId, currentDate);

      print(
          '🔄 Force refreshed availability data for ${currentDate.toString()}');
    }
  }

  // Method removed - booking updates are now handled in controller
}