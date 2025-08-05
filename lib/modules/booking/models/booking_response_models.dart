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
}

class BookingCreateResponse {
  final bool success;
  final int bookingId;
  final double totalHours;
  final double totalAmount;
  final Map<String, dynamic> booking;

  BookingCreateResponse({
    required this.success,
    required this.bookingId,
    required this.totalHours,
    required this.totalAmount,
    required this.booking,
  });

  factory BookingCreateResponse.fromJson(Map<String, dynamic> json) {
    return BookingCreateResponse(
      success: json['success'] ?? true,
      bookingId: json['booking_id'] ?? 0,
      totalHours: (json['total_hours'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      booking: json['booking'] ?? {},
    );
  }
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
    return BookingConflictResponse(
      success: json['success'] ?? false,
      error: json['error'] ?? 'Venue not available',
      availableSlots: (json['available_slots'] as List<dynamic>?)
              ?.map((slot) => TimeSlot.fromJson(slot))
              .toList() ??
          [],
    );
  }
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
      success: json['success'],
      bookingId: json['booking_id'],
      totalHours: (json['total_hours'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      booking: json['booking'],
    );
  }
}