class TimeSlot {
  final String start;
  final String end;
  final bool available;

  TimeSlot({
    required this.start,
    required this.end,
    required this.available,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      start: json['start'] ?? '',
      end: json['end'] ?? '',
      available: json['available'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'available': available,
    };
  }

  String get displayTime => '$start - $end';

  @override
  String toString() => 'TimeSlot($start - $end, available: $available)';
}

class BookingCreateWithResponse {
  final bool success;
  final int bookingId;
  final double totalHours;
  final double totalAmount;
  final Map<String, dynamic> booking;

  BookingCreateWithResponse({
    required this.success,
    required this.bookingId,
    required this.totalHours,
    required this.totalAmount,
    required this.booking,
  });

  factory BookingCreateWithResponse.fromJson(Map<String, dynamic> json) {
    return BookingCreateWithResponse(
      success: json['success'] ?? true,
      bookingId: json['booking_id'] ?? 0,
      totalHours: (json['total_hours'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      booking: json['booking'] ?? {},
    );
  }
  @override
  String toString() =>
      'BookingCreateWithResponse(bookingId: $bookingId, totalAmount: $totalAmount)';
}

class BookingConflictResponse {
  final bool success;
  final String error;
  final List<TimeSlot> availableSlots;

  BookingConflictResponse({
    required this.success,
    required this.error,
    required this.availableSlots,
  });

  factory BookingConflictResponse.fromJson(Map<String, dynamic> json) {
    final slots = <TimeSlot>[];

    try {
      if (json['available_slots'] != null && json['available_slots'] is List) {
        for (final slot in json['available_slots']) {
          if (slot is Map<String, dynamic>) {
            slots.add(TimeSlot.fromJson(slot));
          }
        }
      }
    } catch (e) {
      print('Error parsing available slots: $e');
    }

    return BookingConflictResponse(
      success: json['success'] ?? false,
      error: json['error'] ?? 'Venue not available at selected time',
      availableSlots: slots,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'error': error,
      'available_slots': availableSlots.map((slot) => slot.toJson()).toList(),
    };
  } 
  // Helper methods

  bool get hasAvailableSlots => availableSlots.isNotEmpty;

  int get availableSlotsCount => availableSlots.length;

  List<TimeSlot> get validSlots =>
      availableSlots.where((slot) => slot.available).toList();

  @override
  String toString() =>
      'BookingConflictResponse(error: $error, slots: ${availableSlots.length})';
}


class DetailedTimeSlot {
  final String start;
  final String end;
  final bool available;
  final int durationMinutes;

  DetailedTimeSlot({
    required this.start,
    required this.end,
    required this.available,
    required this.durationMinutes,
  });

  factory DetailedTimeSlot.fromJson(Map<String, dynamic> json) {
    return DetailedTimeSlot(
      start: json['start'],
      end: json['end'],
      available: json['available'],
      durationMinutes: json['duration_minutes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'available': available,
      'duration_minutes': durationMinutes,
    };
  }
}

class CalendarAvailabilityResponse {
  final int placeId;
  final String startDate;
  final String endDate;
  final Map<String, String> availability;

  CalendarAvailabilityResponse({
    required this.placeId,
    required this.startDate,
    required this.endDate,
    required this.availability,
  });

  factory CalendarAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return CalendarAvailabilityResponse(
      placeId: json['place_id'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      availability: Map<String, String>.from(json['availability']),
    );
  }
}

class DetailedSlotsResponse {
  final int placeId;
  final String date;
  final List<DetailedTimeSlot> slots;
  final String venueOperatingHours;

  DetailedSlotsResponse({
    required this.placeId,
    required this.date,
    required this.slots,
    required this.venueOperatingHours,
  });

  factory DetailedSlotsResponse.fromJson(Map<String, dynamic> json) {
    return DetailedSlotsResponse(
      placeId: json['place_id'],
      date: json['date'],
      slots: (json['slots'] as List)
          .map((slot) => DetailedTimeSlot.fromJson(slot))
          .toList(),
      venueOperatingHours: json['venue_operating_hours'],
    );
  }
}
