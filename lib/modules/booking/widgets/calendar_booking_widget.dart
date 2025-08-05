import 'package:flutter/material.dart';
import 'package:function_mobile/modules/booking/models/booking_response_models.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:function_mobile/modules/booking/controllers/booking_controller.dart';

class CalendarBookingWidget extends StatelessWidget {
  final BookingController controller;
  final int venueId;

  const CalendarBookingWidget({
    Key? key,
    required this.controller,
    required this.venueId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          _buildCalendarHeader(),
          SizedBox(height: 16),
          _buildTableCalendar(),
        ],
      );
    });
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Booking Date',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap on a date to see available time slots',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          SizedBox(height: 12),
          _buildAvailabilityLegend(),
        ],
      ),
    );
  }

  Widget _buildAvailabilityLegend() {
    return Row(
      children: [
        _buildLegendItem(Colors.green[100]!, 'Available'),
        SizedBox(width: 16),
        _buildLegendItem(Colors.orange[100]!, 'Partial'),
        SizedBox(width: 16),
        _buildLegendItem(Colors.red[100]!, 'Booked'),
      ],
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
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: _getBorderColor(label),
              width: 1,
            ),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Color _getBorderColor(String label) {
    switch (label) {
      case 'Available':
        return Colors.green;
      case 'Partial':
        return Colors.orange;
      case 'Booked':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTableCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar<String>(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(Duration(days: 365)),
        focusedDay: controller.selectedDate.value ?? DateTime.now(),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        
        // Selected day configuration
        selectedDayPredicate: (day) {
          return controller.selectedDate.value != null &&
              isSameDay(controller.selectedDate.value!, day);
        },
        
        // Calendar builders for custom styling
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, false);
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, true);
          },
          selectedBuilder: (context, day, focusedDay) {
            return _buildSelectedDayCell(day);
          },
          outsideBuilder: (context, day, focusedDay) {
            return _buildOutsideDayCell(day);
          },
        ),
        
        // Header style
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // Day style
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          weekendStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        
        // Calendar style
        calendarStyle: CalendarStyle(
          cellMargin: EdgeInsets.all(4),
          defaultDecoration: BoxDecoration(),
          todayDecoration: BoxDecoration(),
          selectedDecoration: BoxDecoration(),
          outsideDecoration: BoxDecoration(),
        ),
        
        // Event handling
        onDaySelected: (selectedDay, focusedDay) {
          _onDaySelected(selectedDay);
        },
        
        onPageChanged: (focusedDay) {
          _onPageChanged(focusedDay);
        },
      ),
    );
  }

  Widget _buildDayCell(DateTime day, bool isToday) {
    final availability = controller.getAvailabilityStatus(day);
    final color = _getColorForAvailability(availability);
    final borderColor = _getBorderColorForAvailability(availability);
    
    return Container(
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isToday ? Colors.blue : borderColor,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: availability == 'booked' ? Colors.red[700] : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDayCell(DateTime day) {
    return Container(
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
      ),
    );
  }

  Widget _buildOutsideDayCell(DateTime day) {
    return Container(
      margin: EdgeInsets.all(2),
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

  Color _getColorForAvailability(String availability) {
    switch (availability) {
      case 'available':
        return Colors.green[100]!;
      case 'partial':
        return Colors.orange[100]!;
      case 'booked':
        return Colors.red[100]!;
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

  void _onDaySelected(DateTime selectedDay) {
    // Prevent selecting past dates
    if (selectedDay.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      Get.snackbar(
        'Invalid Date',
        'Cannot select past dates',
        backgroundColor: Colors.red[100],
      );
      return;
    }

    controller.selectedDate.value = selectedDay;
    
    // Load detailed time slots for selected date
    controller.loadDetailedTimeSlots(venueId, selectedDay);
    
    // Show time slot picker
    _showTimeSlotPicker(selectedDay);
  }

  void _onPageChanged(DateTime focusedDay) {
    // Load calendar availability for the new month
    final startOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final endOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);
    
    controller.loadCalendarAvailability(venueId, startOfMonth, endOfMonth);
  }

  void _showTimeSlotPicker(DateTime selectedDate) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Obx(() {
          if (controller.isLoadingTimeSlots.value) {
            return Container(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final availableSlots = controller.detailedTimeSlots
              .where((slot) => slot.available)
              .toList();

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Times - ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              if (availableSlots.isEmpty)
                Container(
                  height: 100,
                  child: Center(
                    child: Text(
                      'No available time slots for this date',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                )
              else
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: availableSlots.length,
                    itemBuilder: (context, index) {
                      final slot = availableSlots[index];
                      return ElevatedButton(
                        onPressed: () => _selectTimeSlot(slot),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[50],
                          foregroundColor: Colors.green[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          '${slot.start}',
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
          );
        }),
      ),
    );
  }

  void _selectTimeSlot(DetailedTimeSlot slot) {
    Get.back(); // Close bottom sheet
    
    // Parse and set the selected time
    final startParts = slot.start.split(':');
    final endParts = slot.end.split(':');
    
    controller.startTime.value = TimeOfDay(
      hour: int.parse(startParts[0]),
      minute: int.parse(startParts[1]),
    );
    
    // Set end time to 2 hours later by default
    final startHour = int.parse(startParts[0]);
    final startMinute = int.parse(startParts[1]);
    final endHour = startMinute == 30 ? startHour + 2 : startHour + 1;
    final endMinute = startMinute == 30 ? 30 : 0;
    
    controller.endTime.value = TimeOfDay(
      hour: endHour > 22 ? 22 : endHour,
      minute: endMinute,
    );
    
    Get.snackbar(
      'Time Selected',
      'Start time set to ${slot.start}. Adjust end time if needed.',
      backgroundColor: Colors.green[100],
    );
  }
}