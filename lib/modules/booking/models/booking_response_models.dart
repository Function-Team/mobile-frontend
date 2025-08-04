// lib/modules/booking/models/booking_response_models.dart

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

class BookingValidationResponse {
  final bool valid;
  final String? error;
  final List<TimeSlot>? availableSlots;
  final Map<String, dynamic>? calculation;

  BookingValidationResponse({
    required this.valid,
    this.error,
    this.availableSlots,
    this.calculation,
  });

  factory BookingValidationResponse.fromJson(Map<String, dynamic> json) {
    return BookingValidationResponse(
      valid: json['valid'] ?? false,
      error: json['error'],
      availableSlots: json['available_slots'] != null
          ? (json['available_slots'] as List<dynamic>)
              .map((slot) => TimeSlot.fromJson(slot))
              .toList()
          : null,
      calculation: json['calculation'],
    );
  }
}

class VenueAvailabilityResponse {
  final int placeId;
  final String date;
  final List<TimeSlot> availableSlots;
  final String venueOperatingHours;

  VenueAvailabilityResponse({
    required this.placeId,
    required this.date,
    required this.availableSlots,
    required this.venueOperatingHours,
  });

  factory VenueAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return VenueAvailabilityResponse(
      placeId: json['place_id'] ?? 0,
      date: json['date'] ?? '',
      availableSlots: (json['available_slots'] as List<dynamic>?)
              ?.map((slot) => TimeSlot.fromJson(slot))
              .toList() ??
          [],
      venueOperatingHours: json['venue_operating_hours'] ?? '00:00-24:00',
    );
  }
}