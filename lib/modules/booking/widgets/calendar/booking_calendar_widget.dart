import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/core/helpers/localization_helper.dart';
import 'package:function_mobile/generated/locale_keys.g.dart';
import 'package:function_mobile/modules/booking/models/booking_response_models.dart';
import 'package:function_mobile/modules/booking/widgets/modals/booking_guide_modal.dart';
import 'package:function_mobile/modules/booking/widgets/calendar/time_category_segment.dart';
import 'package:function_mobile/modules/booking/widgets/calendar/time_slot_chip.dart';
import 'package:function_mobile/modules/booking/widgets/shared/selection_summary_widget.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:function_mobile/modules/booking/controllers/booking_controller.dart';

class BookingCalendarWidget extends StatefulWidget {

  final BookingController controller;
  

  final int venueId;

  const BookingCalendarWidget({
    Key? key,
    required this.controller,
    required this.venueId,
  }) : super(key: key);

  @override
  State<BookingCalendarWidget> createState() => _BookingCalendarWidgetState();
}

class _BookingCalendarWidgetState extends State<BookingCalendarWidget> {
  
  /// Currently hovered time slot for preview functionality
  DetailedTimeSlot? _hoveredSlot;
  
  /// Currently selected time category (Morning, Afternoon, Evening)
  TimeCategory _selectedCategory = TimeCategory.morning;
  
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

  /// Loads availability data for the current month from the API.
  /// 
  /// This method is called during widget initialization to populate the calendar
  /// with availability indicators for all dates in the current month.
  void _loadCurrentMonthAvailability() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    widget.controller
        .loadCalendarAvailability(widget.venueId, startOfMonth, endOfMonth);
  }

  /// Pre-selects today's date and loads its time slots if available.
  /// 
  /// This provides a better user experience by immediately showing available
  /// time slots for today, eliminating the need for users to manually select
  /// the current date.
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
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[100]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvailabilityLegend(),
        ],
      ),
    );
  }

  Widget _buildAvailabilityLegend() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(Colors.green[100]!, LocalizationHelper.tr(LocaleKeys.venue_availability)),
          _buildLegendItem(Colors.orange[100]!, LocalizationHelper.tr(LocaleKeys.search_distance)),
          _buildLegendItem(Colors.red[100]!, LocalizationHelper.tr(LocaleKeys.venue_unavailable)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _getBorderColor(label),
              width: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
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
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Get.theme.primaryColor,
          ),
          leftChevronIcon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Get.theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Get.theme.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.chevron_left,
              color: Get.theme.primaryColor,
              size: 20,
            ),
          ),
          rightChevronIcon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Get.theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Get.theme.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.chevron_right,
              color: Get.theme.primaryColor,
              size: 20,
            ),
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
          cellMargin: const EdgeInsets.all(2),
          cellPadding: const EdgeInsets.all(0),

          // Enhanced styling untuk different states
          defaultDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          todayDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Get.theme.primaryColor.withOpacity(0.5),
              width: 2,
            ),
            color: Colors.transparent,
          ),
          selectedDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Get.theme.primaryColor,
            boxShadow: [
              BoxShadow(
                color: Get.theme.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          outsideDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          disabledDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),

          // Enhanced text styles
          defaultTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          todayTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Get.theme.primaryColor,
          ),
          selectedTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          outsideTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.grey[400],
          ),
          disabledTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.grey[300],
          ),
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
    final isPast =
        day.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _getBackgroundColor(availability, isSelected, isPast),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _getDayBorderColor(availability, isToday, isSelected, isPast),
          width: isToday && !isSelected ? 2.5 : 1.5,
        ),
        boxShadow: _getShadow(isSelected, availability),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected
                  ? FontWeight.w700
                  : isToday
                      ? FontWeight.w600
                      : FontWeight.w500,
              color: _getTextColor(availability, isSelected, isPast),
            ),
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
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                child: Icon(Icons.calendar_today_outlined,
                    size: 56, color: Get.theme.primaryColor.withOpacity(0.3)),
              ),
              const SizedBox(height: 16),
              Text(
                'Pilih tanggal untuk melihat waktu yang tersedia',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      if (widget.controller.isLoadingTimeSlots.value) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 140,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Get.theme.primaryColor),
                ),
                const SizedBox(height: 16),
                Text(
                  'Memuat waktu tersedia...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final timeSlots = _getFilteredTimeSlots();
      final selectedDate = widget.controller.selectedDate.value!;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(16)),
          border: Border(
            top: BorderSide(
              color: Colors.grey[100]!,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Get.theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: Get.theme.primaryColor,
                    size: 16,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    LocalizationHelper.tr(LocaleKeys.booking_timeSlot),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => BookingGuideModal.show(),
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Icon(
                      Icons.help_outline,
                      color: Colors.blue[600],
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              '${_formatSelectedDate(selectedDate)} • ${timeSlots.where((slot) => slot.available).length} ${LocalizationHelper.tr(LocaleKeys.venue_availability)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
            SizedBox(height: 16),
            
            // Floating Selection Summary (if any selection exists)
            SelectionSummaryWidget(
              startTime: widget.controller.startTime.value,
              endTime: widget.controller.endTime.value,
              onClear: () {
                widget.controller.startTime.value = null;
                widget.controller.endTime.value = null;
              },
            ),
            
            // Time Category Segmented Control
            TimeCategorySegment(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
            SizedBox(height: 16),
            
            // Cross-category range indicator
            _buildCrossCategoryIndicator(),
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
                        LocalizationHelper.tr(LocaleKeys.search_noResultsFound),
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
              LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive grid berdasarkan screen width
                  final screenWidth = constraints.maxWidth;
                  final crossAxisCount = _getOptimalCrossAxisCount(screenWidth);
                  final aspectRatio = _getOptimalAspectRatio(screenWidth);

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: aspectRatio,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: timeSlots.length,
                    itemBuilder: (context, index) {
                      final slot = timeSlots[index];
                      return TimeSlotChip(
                        slot: slot,
                        isSelected: _isSlotSelected(slot),
                        isFirstSelected: _isSlotFirstSelected(slot),
                        isLastSelected: _isSlotLastSelected(slot),
                        isInPreviewRange: _isSlotInPreviewRange(slot),
                        isConnectableFromOtherCategory: !TimeCategoryHelper.isSlotInCategory(slot.start, _selectedCategory) && _canSlotConnectToSelection(slot),
                        isDisabledByConstraint: widget.controller.startTime.value != null && slot.available && !_canSlotBeEndTime(slot),
                        onTap: () => (slot.available && !_isSlotDisabledByConstraint(slot)) ? _onSlotTap(slot) : _onDisabledSlotTap(slot),
                        onTapDown: () => (slot.available && !_isSlotDisabledByConstraint(slot)) ? _onSlotHover(slot) : null,
                        onTapCancel: () => _onSlotHoverEnd(),
                      );
                    },
                  );
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

  void _onSlotHover(DetailedTimeSlot slot) {
    // Only show preview if we have a start time selected but no end time yet
    final startTime = widget.controller.startTime.value;
    final endTime = widget.controller.endTime.value;
    
    if (startTime != null && (endTime == null || _isSlotSelected(slot)) && _canSlotBeEndTime(slot)) {
      setState(() {
        _hoveredSlot = slot;
      });
    }
  }

  void _onDisabledSlotTap(DetailedTimeSlot slot) {
    final startTime = widget.controller.startTime.value;
    
    if (startTime != null && slot.available && !_canSlotBeEndTime(slot)) {
      // Show error message for continuity constraint
      final maxContinuousEnd = _findMaxContinuousEndTime(startTime);
      final maxEndFormatted = _formatTime(maxContinuousEnd);
      
      CustomSnackbar.show(
        context: context, 
        message: LocalizationHelper.tr(LocaleKeys.errors_timeSlotUnavailable), 
        type: SnackbarType.error,
        autoClear: true,
        enableDebounce: false, // Show errors immediately
      );
    } else if (!slot.available) {
      // Show error message for unavailable slot
      CustomSnackbar.show(
        context: context, 
        message: LocalizationHelper.tr(LocaleKeys.errors_timeSlotUnavailable), 
        type: SnackbarType.error,
        autoClear: true,
        enableDebounce: false, // Show errors immediately
      );
    }
  }

  void _onSlotHoverEnd() {
    setState(() {
      _hoveredSlot = null;
    });
  }

  Widget _buildTimeSlotLegend() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Row pertama: Available dan Selected
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSlotLegendItem(
                Colors.green[50]!,
                Colors.green[300]!,
                Colors.green[700]!,
                LocalizationHelper.tr(LocaleKeys.venue_availability),
                Icons.check_circle_outline,
              ),
              _buildSlotLegendItem(
                Get.theme.primaryColor,
                Get.theme.primaryColor,
                Colors.white,
                LocalizationHelper.tr(LocaleKeys.booking_details),
                Icons.radio_button_checked,
              ),
            ],
          ),
          SizedBox(height: 8),
          // Row kedua: Connectable dan Booked
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSlotLegendItem(
                Colors.purple[50]!,
                Colors.purple[300]!,
                Colors.purple[700]!,
                'Connectable',
                Icons.link,
              ),
              _buildSlotLegendItem(
                Colors.red[100]!,
                Colors.red[300]!,
                Colors.red[600]!,
                LocalizationHelper.tr(LocaleKeys.venue_unavailable),
                Icons.block,
              ),
            ],
          ),
          SizedBox(height: 8),
          // Row ketiga: Blocked
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSlotLegendItem(
                Colors.grey[200]!,
                Colors.grey[400]!,
                Colors.grey[600]!,
                LocalizationHelper.tr(LocaleKeys.venue_closed),
                Icons.link_off,
              ),
            ],
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

  bool _isSlotSelected(DetailedTimeSlot slot) {
    final startTime = widget.controller.startTime.value;
    final endTime = widget.controller.endTime.value;

    if (startTime == null || endTime == null) return false;

    final slotStart = _parseTimeOfDay(slot.start);

    // Check if this slot is within selected time range (inclusive)
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final slotStartMinutes = slotStart.hour * 60 + slotStart.minute;

    // Slot is selected if it overlaps with selected time range
    return slotStartMinutes >= startMinutes && slotStartMinutes < endMinutes;
  }

  bool _isSlotFirstSelected(DetailedTimeSlot slot) {
    final startTime = widget.controller.startTime.value;
    if (startTime == null) return false;
    
    final slotStart = _parseTimeOfDay(slot.start);
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final slotStartMinutes = slotStart.hour * 60 + slotStart.minute;
    
    return slotStartMinutes == startMinutes;
  }

  bool _isSlotLastSelected(DetailedTimeSlot slot) {
    final endTime = widget.controller.endTime.value;
    if (endTime == null) return false;
    
    final slotEnd = _parseTimeOfDay(slot.end);
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final slotEndMinutes = slotEnd.hour * 60 + slotEnd.minute;
    
    return slotEndMinutes == endMinutes;
  }

  bool _isSlotInPreviewRange(DetailedTimeSlot slot) {
    if (_hoveredSlot == null) return false;
    
    final startTime = widget.controller.startTime.value;
    if (startTime == null) return false;
    
    final slotStart = _parseTimeOfDay(slot.start);
    final hoveredSlotStart = _parseTimeOfDay(_hoveredSlot!.start);
    
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final slotStartMinutes = slotStart.hour * 60 + slotStart.minute;
    final hoveredMinutes = hoveredSlotStart.hour * 60 + hoveredSlotStart.minute;
    
    // Create preview range from current start to hovered slot, but respect continuity
    if (hoveredMinutes > startMinutes) {
      // Check if range is continuous from start to hovered slot
      final maxContinuousEnd = _findMaxContinuousEndTime(startTime);
      final maxEndMinutes = maxContinuousEnd.hour * 60 + maxContinuousEnd.minute;
      final effectiveEnd = hoveredMinutes + 30 > maxEndMinutes ? maxEndMinutes : hoveredMinutes + 30;
      
      return slotStartMinutes >= startMinutes && slotStartMinutes < effectiveEnd;
    } else {
      // Extending backwards - find max continuous start time
      final minContinuousStart = _findMinContinuousStartTime(startTime);
      final minStartMinutes = minContinuousStart.hour * 60 + minContinuousStart.minute;
      final effectiveStart = hoveredMinutes < minStartMinutes ? minStartMinutes : hoveredMinutes;
      
      return slotStartMinutes >= effectiveStart && slotStartMinutes < startMinutes + 30;
    }
  }

  // Find the maximum end time that maintains continuity from start time
  TimeOfDay _findMaxContinuousEndTime(TimeOfDay startTime) {
    final timeSlots = widget.controller.detailedTimeSlots;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    
    // Sort slots by time to check continuity
    final sortedSlots = timeSlots.toList()
      ..sort((a, b) {
        final aMinutes = _parseTimeOfDay(a.start).hour * 60 + _parseTimeOfDay(a.start).minute;
        final bMinutes = _parseTimeOfDay(b.start).hour * 60 + _parseTimeOfDay(b.start).minute;
        return aMinutes.compareTo(bMinutes);
      });
    
    TimeOfDay maxEndTime = startTime;
    
    for (final slot in sortedSlots) {
      final slotStart = _parseTimeOfDay(slot.start);
      final slotEnd = _parseTimeOfDay(slot.end);
      final slotStartMinutes = slotStart.hour * 60 + slotStart.minute;
      final slotEndMinutes = slotEnd.hour * 60 + slotEnd.minute;
      final currentMaxMinutes = maxEndTime.hour * 60 + maxEndTime.minute;
      
      // Skip slots before our start time
      if (slotEndMinutes <= startMinutes) continue;
      
      // If this slot starts exactly where our current max ends, and it's available
      if (slotStartMinutes == currentMaxMinutes && slot.available) {
        maxEndTime = slotEnd;
      } else if (slotStartMinutes > currentMaxMinutes) {
        // Gap found or unavailable slot - stop here
        break;
      }
    }
    
    return maxEndTime;
  }

  // Find the minimum start time that maintains continuity to current start time
  TimeOfDay _findMinContinuousStartTime(TimeOfDay currentStart) {
    final timeSlots = widget.controller.detailedTimeSlots;
    final currentStartMinutes = currentStart.hour * 60 + currentStart.minute;
    
    // Sort slots by time (descending for backward search)
    final sortedSlots = timeSlots.toList()
      ..sort((a, b) {
        final aMinutes = _parseTimeOfDay(a.start).hour * 60 + _parseTimeOfDay(a.start).minute;
        final bMinutes = _parseTimeOfDay(b.start).hour * 60 + _parseTimeOfDay(b.start).minute;
        return bMinutes.compareTo(aMinutes);
      });
    
    TimeOfDay minStartTime = currentStart;
    
    for (final slot in sortedSlots) {
      final slotStart = _parseTimeOfDay(slot.start);
      final slotEnd = _parseTimeOfDay(slot.end);
      final slotStartMinutes = slotStart.hour * 60 + slotStart.minute;
      final slotEndMinutes = slotEnd.hour * 60 + slotEnd.minute;
      final currentMinMinutes = minStartTime.hour * 60 + minStartTime.minute;
      
      // Skip slots after our current start time
      if (slotStartMinutes >= currentStartMinutes) continue;
      
      // If this slot ends exactly where our current min starts, and it's available
      if (slotEndMinutes == currentMinMinutes && slot.available) {
        minStartTime = slotStart;
      } else if (slotEndMinutes < currentMinMinutes) {
        // Gap found or unavailable slot - stop here
        break;
      }
    }
    
    return minStartTime;
  }

  // Check if a slot can be selected as end time given current start time
  bool _canSlotBeEndTime(DetailedTimeSlot slot) {
    final startTime = widget.controller.startTime.value;
    if (startTime == null) return slot.available;
    
    final slotStart = _parseTimeOfDay(slot.start);
    final slotEnd = _parseTimeOfDay(slot.end);
    final maxContinuousEnd = _findMaxContinuousEndTime(startTime);
    
    final slotEndMinutes = slotEnd.hour * 60 + slotEnd.minute;
    final maxEndMinutes = maxContinuousEnd.hour * 60 + maxContinuousEnd.minute;
    
    return slot.available && slotEndMinutes <= maxEndMinutes;
  }

  void _onSlotTap(DetailedTimeSlot slot) {
    _parseTimeOfDay(slot.start);
    _parseTimeOfDay(slot.end);

    // Clear hover state
    _onSlotHoverEnd();

    // Handle multi-slot selection for longer duration
    _handleMultiSlotSelection(slot);
  }

  void _handleMultiSlotSelection(DetailedTimeSlot slot) {
    final currentStart = widget.controller.startTime.value;
    final currentEnd = widget.controller.endTime.value;
    final slotStart = _parseTimeOfDay(slot.start);
    final slotEnd = _parseTimeOfDay(slot.end);
    final slotStartMinutes = slotStart.hour * 60 + slotStart.minute;

    if (currentStart == null) {
      // First selection - set start time
      widget.controller.startTime.value = slotStart;
      widget.controller.endTime.value = slotEnd; // Initial 30-min selection
      CustomSnackbar.show(
          context: context, 
          message: LocalizationHelper.tr(LocaleKeys.booking_startTime), 
          type: SnackbarType.success,
          autoClear: true,
          enableDebounce: true, // Debounce selection feedback
          debounceDuration: const Duration(milliseconds: 500),
      );
    } else {
      final currentStartMinutes = currentStart.hour * 60 + currentStart.minute;
      final currentEndMinutes = currentEnd!.hour * 60 + currentEnd.minute;

      // Check if clicking within current selection (deselect)
      if (slotStartMinutes >= currentStartMinutes && 
          slotStartMinutes < currentEndMinutes) {
        // Deselect all
        widget.controller.startTime.value = null;
        widget.controller.endTime.value = null;
        CustomSnackbar.show(
            context: context, 
            message: LocalizationHelper.tr(LocaleKeys.common_cancel), 
            type: SnackbarType.info,
            autoClear: true,
            enableDebounce: false, // Show clear actions immediately
        );
        return;
      }

      // Create range selection
      if (slotStartMinutes < currentStartMinutes) {
        // Extend backwards - new start time
        widget.controller.startTime.value = slotStart;
        // Keep current end time, or extend to include current selection
        widget.controller.endTime.value = currentEnd;
      } else {
        // Extend forwards - new end time
        widget.controller.endTime.value = slotEnd;
        // Keep current start time
      }

      final duration = _calculateSelectedDuration();
      CustomSnackbar.show(
          context: context, 
          message: LocalizationHelper.tr(LocaleKeys.booking_duration), 
          type: SnackbarType.success,
          autoClear: true,
          enableDebounce: true, // Debounce range selection feedback
          debounceDuration: const Duration(milliseconds: 400),
      );
    }
  }

  String _calculateSelectedDuration() {
    final start = widget.controller.startTime.value;
    final end = widget.controller.endTime.value;
    if (start == null || end == null) return '';

    final duration =
        (end.hour * 60 + end.minute) - (start.hour * 60 + start.minute);
    if (duration >= 60) {
      final hours = duration ~/ 60;
      final mins = duration % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
    return '${duration}m';
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatSelectedDate(DateTime date) {
    // Using LocalizationHelper for date formatting
    return LocalizationHelper.formatDate(date);
  }

  void _onDaySelected(DateTime selectedDay) {
    // Prevent selecting past dates
    if (selectedDay.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      CustomSnackbar.show(
          context: context, 
          message: LocalizationHelper.tr(LocaleKeys.common_error), 
          type: SnackbarType.error,
          autoClear: true,
          enableDebounce: false, // Show errors immediately
      );
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
    final startOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final endOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);
    widget.controller
        .loadCalendarAvailability(widget.venueId, startOfMonth, endOfMonth);
  }

  void refreshAvailabilityData() {
    final currentDate = widget.controller.selectedDate.value;
    if (currentDate != null) {
      final startOfMonth = DateTime(currentDate.year, currentDate.month, 1);
      final endOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);

      widget.controller
          .loadCalendarAvailability(widget.venueId, startOfMonth, endOfMonth);
      widget.controller.loadDetailedTimeSlots(widget.venueId, currentDate);
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
              context: context, 
              message: LocalizationHelper.tr(LocaleKeys.common_success), 
              type: SnackbarType.success,
              autoClear: true,
              enableDebounce: false, // Show updates immediately
          );
        });
      }
    });
  }

  // Enhanced helper methods untuk better visual feedback
  Color _getBackgroundColor(String availability, bool isSelected, bool isPast) {
    if (isSelected) {
      return Get.theme.primaryColor;
    }

    if (isPast) {
      return Colors.grey[100]!;
    }

    switch (availability.toLowerCase()) {
      case 'available':
        return Colors.green[50]!;
      case 'limited':
      case 'partial':
        return Colors.orange[50]!;
      case 'booked':
        return Colors.red[50]!;
      default:
        return Colors.grey[50]!;
    }
  }

  Color _getDayBorderColor(
      String availability, bool isToday, bool isSelected, bool isPast) {
    if (isSelected) {
      return Get.theme.primaryColor;
    }

    if (isToday) {
      return Get.theme.primaryColor;
    }

    if (isPast) {
      return Colors.grey[300]!;
    }

    switch (availability.toLowerCase()) {
      case 'available':
        return Colors.green[300]!;
      case 'limited':
      case 'partial':
        return Colors.orange[300]!;
      case 'booked':
        return Colors.red[300]!;
      default:
        return Colors.grey[300]!;
    }
  }

  Color _getTextColor(String availability, bool isSelected, bool isPast) {
    if (isSelected) {
      return Colors.white;
    }

    if (isPast) {
      return Colors.grey[400]!;
    }

    switch (availability.toLowerCase()) {
      case 'available':
        return Colors.green[700]!;
      case 'limited':
      case 'partial':
        return Colors.orange[700]!;
      case 'booked':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  List<BoxShadow> _getShadow(bool isSelected, String availability) {
    if (isSelected) {
      return [
        BoxShadow(
          color: Get.theme.primaryColor.withOpacity(0.4),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }

    if (availability == 'available') {
      return [
        BoxShadow(
          color: Colors.green.withOpacity(0.2),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];
    }

    return [];
  }

  // Responsive helper methods untuk prevent overflow
  int _getOptimalCrossAxisCount(double screenWidth) {
    if (screenWidth < 300) {
      return 2; // Small phones - fewer columns for better readability
    } else if (screenWidth < 400) {
      return 3; // Regular phones - reduced from 4 to 3
    } else if (screenWidth < 600) {
      return 4; // Large phones - reduced from 5 to 4
    } else {
      return 5; // Tablets - reduced from 6 to 5
    }
  }

  double _getOptimalAspectRatio(double screenWidth) {
    if (screenWidth < 300) {
      return 2.5; // Wider cells for better text readability
    } else if (screenWidth < 400) {
      return 2.8; // Increased from 2.2 to 2.8
    } else {
      return 3.0; // Increased from 2.5 to 3.0
    }
  }

  List<DetailedTimeSlot> _getFilteredTimeSlots() {
    final allSlots = widget.controller.detailedTimeSlots;
    final startTime = widget.controller.startTime.value;
    
    // If no selection, show only current category
    if (startTime == null) {
      return allSlots.where((slot) => TimeCategoryHelper.isSlotInCategory(slot.start, _selectedCategory)).toList();
    }
    
    // If there's a selection, include slots that can connect across categories
    final categorySlots = allSlots.where((slot) => TimeCategoryHelper.isSlotInCategory(slot.start, _selectedCategory)).toList();
    final connectableSlots = allSlots.where((slot) => 
        !TimeCategoryHelper.isSlotInCategory(slot.start, _selectedCategory) && _canSlotConnectToSelection(slot)).toList();
    
    return [...categorySlots, ...connectableSlots];
  }
  
  bool _canSlotConnectToSelection(DetailedTimeSlot slot) {
    final startTime = widget.controller.startTime.value;
    final endTime = widget.controller.endTime.value;
    
    if (startTime == null) return false;
    
    final slotStart = _parseTimeOfDay(slot.start);
    final slotEnd = _parseTimeOfDay(slot.end);
    
    // Check if slot can extend the current selection
    if (endTime != null) {
      final endMinutes = endTime.hour * 60 + endTime.minute;
      final slotStartMinutes = slotStart.hour * 60 + slotStart.minute;
      
      // Slot can extend the end time
      return slotStartMinutes == endMinutes && slot.available;
    } else {
      // Check if slot can be end time (continuation logic)
      return _canSlotBeEndTime(slot);
    }
  }

  Widget _buildCrossCategoryIndicator() {
    final startTime = widget.controller.startTime.value;
    final endTime = widget.controller.endTime.value;
    
    if (startTime == null) {
      return const SizedBox.shrink();
    }
    
    // Check if selected range spans across categories
    final selectedRange = _getSelectedTimeRange();
    if (selectedRange == null) {
      return const SizedBox.shrink();
    }
    
    final currentCategoryRange = TimeCategoryHelper.getCategoryTimeRange(_selectedCategory, widget.controller.selectedDate.value!);
    final isRangeStartsInOtherCategory = selectedRange.start.isBefore(currentCategoryRange.start);
    final isRangeEndsInOtherCategory = endTime != null && selectedRange.end.isAfter(currentCategoryRange.end);
    
    if (!isRangeStartsInOtherCategory && !isRangeEndsInOtherCategory) {
      return const SizedBox.shrink();
    }
    
    String message = '';
    if (isRangeStartsInOtherCategory && isRangeEndsInOtherCategory) {
      message = 'Range extends from other periods';
    } else if (isRangeStartsInOtherCategory) {
      message = 'Range continues from ${TimeCategoryHelper.getCategoryForTime(startTime)}';
    } else {
      message = 'Range extends to other periods';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timeline,
            color: Colors.orange[600],
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for cross-category logic
  DateTimeRange? _getSelectedTimeRange() {
    final startTime = widget.controller.startTime.value;
    final endTime = widget.controller.endTime.value;
    final selectedDate = widget.controller.selectedDate.value;
    
    if (startTime == null || selectedDate == null) return null;
    
    final start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, startTime.hour, startTime.minute);
    final end = endTime != null 
        ? DateTime(selectedDate.year, selectedDate.month, selectedDate.day, endTime.hour, endTime.minute)
        : start.add(const Duration(minutes: 30));
    
    return DateTimeRange(start: start, end: end);
  }

  bool _isSlotDisabledByConstraint(DetailedTimeSlot slot) {
    final startTime = widget.controller.startTime.value;
    return startTime != null && slot.available && !_canSlotBeEndTime(slot);
  }
}
