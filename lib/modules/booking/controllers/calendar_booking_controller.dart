import 'package:flutter/material.dart';
import 'package:function_mobile/common/widgets/snackbars/custom_snackbar.dart';
import 'package:function_mobile/modules/booking/models/booking_response_models.dart';
import 'package:get/get.dart';
import 'package:function_mobile/modules/booking/controllers/booking_controller.dart';

class CalendarBookingController extends GetxController {
  final BookingController bookingController;
  final int venueId;

  CalendarBookingController({
    required this.bookingController,
    required this.venueId,
  });

  @override
  void onInit() {
    super.onInit();
    // Auto-load current month availability on controller initialization
    _loadCurrentMonthAvailability();
    _preSelectTodayIfAvailable();
    _listenForBookingUpdates();
  }

  // Business Logic Methods
  void _loadCurrentMonthAvailability() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    bookingController.loadCalendarAvailability(venueId, startOfMonth, endOfMonth);
  }

  void _preSelectTodayIfAvailable() {
    final today = DateTime.now();
    // Pre-select today and load its time slots
    bookingController.selectedDate.value = today;
    bookingController.loadDetailedTimeSlots(venueId, today);
  }

  void _listenForBookingUpdates() {
    // Listen for booking success to refresh data
    // This can be implemented based on your booking update mechanism
  }

  // Calendar Event Handlers
  void onDaySelected(DateTime selectedDay) {
    if (selectedDay.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      CustomSnackbar.show(
        context: Get.context!,
        message: 'Tidak dapat memilih tanggal yang sudah lewat',
        type: SnackbarType.error,
      );
      return;
    }

    bookingController.selectedDate.value = selectedDay;
    bookingController.startTime.value = null;
    bookingController.endTime.value = null;
    bookingController.loadDetailedTimeSlots(venueId, selectedDay);

    CustomSnackbar.show(
      context: Get.context!,
      message: 'Tanggal dipilih: ${formatSelectedDate(selectedDay)}',
      type: SnackbarType.info,
    );
  }

  void onPageChanged(DateTime focusedDay) {
    final startOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final endOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);
    bookingController.loadCalendarAvailability(venueId, startOfMonth, endOfMonth);
  }

  // Time Slot Selection Logic
  void onSlotTap(DetailedTimeSlot slot) {
    // Check if slot is available before allowing selection
    if (!slot.available) {
      CustomSnackbar.show(
        context: Get.context!,
        message: 'Slot waktu sudah dibooking oleh orang lain',
        type: SnackbarType.error,
      );
      return;
    }

    // Check if slot is within operating hours before allowing selection
    if (!isSlotWithinOperatingHours(slot)) {
      CustomSnackbar.show(
        context: Get.context!,
        message: 'Slot tidak tersedia - akan melewati jam operasional',
        type: SnackbarType.error,
      );
      return;
    }

    // Handle multi-slot selection for longer duration
    handleMultiSlotSelection(slot);
  }

  void handleMultiSlotSelection(DetailedTimeSlot slot) {
    final currentStart = bookingController.startTime.value;
    final currentEnd = bookingController.endTime.value;
    final slotStart = parseTimeOfDay(slot.start);
    final slotEnd = parseTimeOfDay(slot.end);

    if (currentStart == null) {
      // First selection - set start time to slot start and end time to slot end
      bookingController.startTime.value = slotStart;
      bookingController.endTime.value = slotEnd;
    } else if (currentEnd == null) {
      // This shouldn't happen with the new logic, but handle it anyway
      bookingController.endTime.value = slotEnd;
    } else {
      // Both start and end are selected - check if clicking the same slot
      final slotStartMinutes = slotStart.hour * 60 + slotStart.minute;
      final slotEndMinutes = slotEnd.hour * 60 + slotEnd.minute;
      final currentStartMinutes = currentStart.hour * 60 + currentStart.minute;
      final currentEndMinutes = currentEnd.hour * 60 + currentEnd.minute;

      if (slotStartMinutes == currentStartMinutes && slotEndMinutes == currentEndMinutes) {
        // Clicking the exact same slot - deselect all
        bookingController.startTime.value = null;
        bookingController.endTime.value = null;
      } else {
        // Start new selection with this slot
        bookingController.startTime.value = slotStart;
        bookingController.endTime.value = slotEnd;
      }
    }

    // Show feedback
    calculateSelectedDuration();
  }

  // Utility Methods
  TimeOfDay parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  bool isSlotWithinOperatingHours(DetailedTimeSlot slot) {
    final slotEnd = parseTimeOfDay(slot.end);
    final closingTime = TimeOfDay(hour: 22, minute: 0);
    final slotEndMinutes = slotEnd.hour * 60 + slotEnd.minute;
    final closingMinutes = closingTime.hour * 60 + closingTime.minute;
    return slotEndMinutes <= closingMinutes;
  }

  bool isSlotSelected(DetailedTimeSlot slot) {
    final startTime = bookingController.startTime.value;
    final endTime = bookingController.endTime.value;

    if (startTime == null || endTime == null) return false;

    final slotStart = parseTimeOfDay(slot.start);

    // Check if this slot is within selected time range (inclusive)
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final slotStartMinutes = slotStart.hour * 60 + slotStart.minute;

    // Slot is selected if it overlaps with selected time range
    return slotStartMinutes >= startMinutes && slotStartMinutes < endMinutes;
  }

  void calculateSelectedDuration() {
    final startTime = bookingController.startTime.value;
    final endTime = bookingController.endTime.value;

    if (startTime != null && endTime != null) {
      final startMinutes = startTime.hour * 60 + startTime.minute;
      final endMinutes = endTime.hour * 60 + endTime.minute;
      final durationMinutes = endMinutes - startMinutes;
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;

      String durationText = '';
      if (hours > 0) {
        durationText += '${hours} jam';
        if (minutes > 0) {
          durationText += ' ${minutes} menit';
        }
      } else {
        durationText = '${minutes} menit';
      }

      CustomSnackbar.show(
        context: Get.context!,
        message: 'Durasi booking: $durationText',
        type: SnackbarType.info,
      );
    }
  }

  // UI Helper Methods
  String getAvailabilityStatus(DateTime day) {
    return bookingController.getAvailabilityStatus(day);
  }

  Color getColorForAvailability(String availability) {
    switch (availability) {
      case 'available':
        return Colors.green[100]!;
      case 'partial':
        return Colors.orange[100]!;
      case 'booked':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color getBorderColorForAvailability(String availability) {
    switch (availability) {
      case 'available':
        return Colors.green[400]!;
      case 'partial':
        return Colors.orange[400]!;
      case 'booked':
        return Colors.red[400]!;
      default:
        return Colors.grey[400]!;
    }
  }

  Color getBorderColor(String label) {
    switch (label) {
      case 'Available':
        return Colors.green[500]!;
      case 'Limited':
        return Colors.orange[500]!;
      case 'Fully Booked':
        return Colors.red[500]!;
      default:
        return Colors.grey[500]!;
    }
  }

  String formatSelectedDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Data loading methods
  void loadCalendarAvailability(int venueId, DateTime startDate, DateTime endDate) {
    bookingController.loadCalendarAvailability(venueId, startDate, endDate);
  }

  void loadDetailedTimeSlots(int venueId, DateTime date) {
    bookingController.loadDetailedTimeSlots(venueId, date);
  }

  // Getters for reactive data
  DateTime? get selectedDate => bookingController.selectedDate.value;
  bool get isLoadingTimeSlots => bookingController.isLoadingTimeSlots.value;
  List<DetailedTimeSlot> get detailedTimeSlots => bookingController.detailedTimeSlots;
  TimeOfDay? get startTime => bookingController.startTime.value;
  TimeOfDay? get endTime => bookingController.endTime.value;
  String get bookingStatus => bookingController.bookingStatus.value;
}