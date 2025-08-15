import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/modules/booking/models/booking_response_models.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:function_mobile/modules/booking/controllers/booking_controller.dart';

class CalendarBookingWidget extends StatefulWidget {
  final BookingController controller;
  final int venueId;

  const CalendarBookingWidget({
    Key? key,
    required this.controller,
    required this.venueId,
  }) : super(key: key);

  @override
  State<CalendarBookingWidget> createState() => _CalendarBookingWidgetState();
}

class _CalendarBookingWidgetState extends State<CalendarBookingWidget> {
  @override
  void initState() {
    super.initState();
    // Auto-load current month availability on widget initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentMonthAvailability();
      _preSelectTodayIfAvailable();

      // Listen for booking success to refresh data
      _listenForBookingUpdates();
    });
  }

  void _loadCurrentMonthAvailability() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    widget.controller
        .loadCalendarAvailability(widget.venueId, startOfMonth, endOfMonth);
  }

  void _preSelectTodayIfAvailable() {
    final today = DateTime.now();
    // Pre-select today and load its time slots
    widget.controller.selectedDate.value = today;
    widget.controller.loadDetailedTimeSlots(widget.venueId, today);
  }

  @override
  Widget build(BuildContext context) {
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
          _buildLegendItem(Colors.green[100]!, 'Available'),
          _buildLegendItem(Colors.orange[100]!, 'Limited'),
          _buildLegendItem(Colors.red[100]!, 'Fully Booked'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _getBorderColor(label),
              width: 1.5,
            ),
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Color _getBorderColor(String label) {
    switch (label) {
      case 'Available':
        return Colors.green[300]!;
      case 'Limited':
        return Colors.orange[300]!;
      case 'Fully Booked':
        return Colors.red[300]!;
      default:
        return Colors.grey[300]!;
    }
  }

  Widget _buildTableCalendar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TableCalendar<String>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: widget.controller.selectedDate.value ?? DateTime.now(),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,

        // Enhanced selection logic
        selectedDayPredicate: (day) {
          return widget.controller.selectedDate.value != null &&
              isSameDay(widget.controller.selectedDate.value!, day);
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
          _onDaySelected(selectedDay);
        },

        onPageChanged: (focusedDay) {
          _onPageChanged(focusedDay);
        },
      ),
    );
  }

  // SIMPLIFIED calendar cells - only color, no text info
  Widget _buildSimpleDayCell(DateTime day, bool isToday, bool isSelected) {
    final availability = widget.controller.getAvailabilityStatus(day);

    Color backgroundColor;
    Color borderColor;
    Color textColor = Colors.grey[800]!;

    // Determine colors based on selection and availability
    if (isSelected) {
      backgroundColor = Get.theme.primaryColor;
      borderColor = Get.theme.primaryColor;
      textColor = Colors.white;
    } else {
      backgroundColor = _getColorForAvailability(availability);
      borderColor =
          isToday ? Colors.blue : _getBorderColorForAvailability(availability);

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
      if (widget.controller.selectedDate.value == null) {
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

      if (widget.controller.isLoadingTimeSlots.value) {
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

      final timeSlots = widget.controller.detailedTimeSlots;
      final selectedDate = widget.controller.selectedDate.value!;

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
              '${_formatSelectedDate(selectedDate)} • ${timeSlots.where((slot) => slot.available).length} of ${timeSlots.length} slots available',
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
                  return _buildTimeSlotChip(slot);
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
    final isAvailable = slot.available;
    final isSelected = _isSlotSelected(slot);

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
      onTap: isAvailable ? () => _onSlotTap(slot) : null,
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
              ),
              if (!isAvailable) ...[
                SizedBox(height: 2),
                Icon(
                  Icons.block,
                  color: textColor,
                  size: 10,
                ),
              ],
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
          _buildSlotLegendItem(
            Colors.green[50]!,
            Colors.green[300]!,
            Colors.green[700]!,
            'Available',
            Icons.check_circle_outline,
          ),
          _buildSlotLegendItem(
            Get.theme.primaryColor,
            Get.theme.primaryColor,
            Colors.white,
            'Selected',
            Icons.radio_button_checked,
          ),
          _buildSlotLegendItem(
            Colors.red[100]!,
            Colors.red[300]!,
            Colors.red[600]!,
            'Booked',
            Icons.block,
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
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor),
          ),
          child: Icon(
            icon,
            color: textColor,
            size: 12,
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  // Helper methods
  Color _getColorForAvailability(String availability) {
    switch (availability) {
      case 'available':
        return Colors.green[50]!;
      case 'partial':
        return Colors.orange[50]!;
      case 'booked':
        return Colors.red[50]!;
      default:
        return Colors.grey[50]!;
    }
  }

  Color _getBorderColorForAvailability(String availability) {
    switch (availability) {
      case 'available':
        return Colors.green[300]!;
      case 'partial':
        return Colors.orange[300]!;
      case 'booked':
        return Colors.red[300]!;
      default:
        return Colors.grey[300]!;
    }
  }

  bool _isSlotSelected(DetailedTimeSlot slot) {
    final startTime = widget.controller.startTime.value;
    final endTime = widget.controller.endTime.value;

    if (startTime == null || endTime == null) return false;

    final slotStart = _parseTimeOfDay(slot.start);
    _parseTimeOfDay(slot.end);

    // Check if this slot is within selected time range (inclusive)
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final slotStartMinutes = slotStart.hour * 60 + slotStart.minute;

    // Slot is selected if it overlaps with selected time range
    return slotStartMinutes >= startMinutes && slotStartMinutes < endMinutes;
  }

  void _onSlotTap(DetailedTimeSlot slot) {
    _parseTimeOfDay(slot.start);
    _parseTimeOfDay(slot.end);

    // Handle multi-slot selection for longer duration
    _handleMultiSlotSelection(slot);
  }

  void _handleMultiSlotSelection(DetailedTimeSlot slot) {
    final currentStart = widget.controller.startTime.value;
    final currentEnd = widget.controller.endTime.value;
    final slotStart = _parseTimeOfDay(slot.start);
    final slotEnd = _parseTimeOfDay(slot.end);

    if (currentStart == null) {
      // First selection - set this single 30-min slot
      widget.controller.startTime.value = slotStart;
      widget.controller.endTime.value = slotEnd;
    } else {
      // Check if clicking the same slot (deselect)
      final currentStartMinutes = currentStart.hour * 60 + currentStart.minute;
      final currentEndMinutes = currentEnd!.hour * 60 + currentEnd.minute;
      final slotStartMinutes = slotStart.hour * 60 + slotStart.minute;

      if (currentStartMinutes == slotStartMinutes &&
          currentEndMinutes == slotStartMinutes + 30) {
        // Clicking same slot - deselect
        widget.controller.startTime.value = null;
        widget.controller.endTime.value = null;
        CustomSnackbar.show(
            context: context, message: 'Time Cleared', type: SnackbarType.info);
        return;
      }

      // Extend selection
      if (slotStartMinutes < currentStartMinutes) {
        // Extend backwards
        widget.controller.startTime.value = slotStart;
      } else {
        // Extend forwards
        widget.controller.endTime.value = slotEnd;
      }
    }

    // Show feedback
    _calculateSelectedDuration();
    CustomSnackbar.show(
        context: context, message: 'Time Updated', type: SnackbarType.success);
  }

  String _calculateSelectedDuration() {
    final start = widget.controller.startTime.value;
    final end = widget.controller.endTime.value;

    if (start == null || end == null) return '';

    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final duration = endMinutes - startMinutes;

    if (duration >= 60) {
      final hours = duration ~/ 60;
      final mins = duration % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    } else {
      return '${duration}m';
    }
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _formatSelectedDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  void _onDaySelected(DateTime selectedDay) {
    // Prevent selecting past dates
    if (selectedDay.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      CustomSnackbar.show(
          context: context, message: 'Invalid Date', type: SnackbarType.error);
      return;
    }

    widget.controller.selectedDate.value = selectedDay;

    // Load detailed time slots for selected date
    widget.controller.loadDetailedTimeSlots(widget.venueId, selectedDay);

    // Clear existing time selection when date changes
    widget.controller.startTime.value = null;
    widget.controller.endTime.value = null;
  }

  void _onPageChanged(DateTime focusedDay) {
    // Load calendar availability for the new month
    final startOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final endOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);

    widget.controller
        .loadCalendarAvailability(widget.venueId, startOfMonth, endOfMonth);
  }

  // NEW: Force refresh calendar and time slots data
  void refreshAvailabilityData() {
    if (widget.controller.selectedDate.value != null) {
      // Refresh calendar for current month
      final currentDate = widget.controller.selectedDate.value!;
      final startOfMonth = DateTime(currentDate.year, currentDate.month, 1);
      final endOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);

      // Force refresh both calendar and time slots
      widget.controller
          .loadCalendarAvailability(widget.venueId, startOfMonth, endOfMonth);
      widget.controller.loadDetailedTimeSlots(widget.venueId, currentDate);

      print(
          '🔄 Force refreshed availability data for ${currentDate.toString()}');
    }
  }

  void _listenForBookingUpdates() {
    // Listen to booking status changes
    ever(widget.controller.bookingStatus, (status) {
      if (status == 'success') {
        // Delay refresh to allow backend to update
        Future.delayed(Duration(milliseconds: 1500), () {
          refreshAvailabilityData();
          CustomSnackbar.show(
              context: context, message: 'Updated', type: SnackbarType.success);
        });
      }
    });
  }
}
