import 'package:dio/dio.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/modules/booking/models/booking_response_models.dart';
import 'package:get/get.dart';

class BookingService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  // Get booking by ID dari FastAPI
  Future<BookingModel?> getBookingById(int bookingId) async {
    try {
      final response = await _apiService.getRequest('/booking/$bookingId');
      return BookingModel.fromJson(response);
    } catch (e) {
      print('Error fetching booking by ID: $e');
      return null;
    }
  }

  Future<List<BookingModel>> getUserBookings() async {
    try {
      final response = await _apiService.getRequest('/bookings/me');
      print('Fetched bookings: $response');

      if (response is List) {
        final bookings = <BookingModel>[];

        for (final bookingData in response) {
          try {
            final booking = BookingModel.fromJson(bookingData);

            BookingModel enrichedBooking = booking;
            if (_needsPlaceEnrichment(booking)) {
              enrichedBooking = await _enrichBookingWithPlaceDetails(booking);
            }

            bookings.add(enrichedBooking);
          } catch (e) {
            print('Error processing booking ${bookingData['id']}: $e');
            // Skip this booking but continue with others
          }
        }

        return bookings;
      }
      return [];
    } catch (e) {
      print('Error fetching bookings from API: $e');
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  // Helper method untuk cek apakah booking perlu di-enrich dengan place details
  bool _needsPlaceEnrichment(BookingModel booking) {
    // Enrich jika place null atau place ada tapi address kosong
    return booking.place == null ||
        booking.place?.address == null ||
        booking.place!.address!.isEmpty;
  }

  // Helper method untuk enrich booking dengan place details
  Future<BookingModel> _enrichBookingWithPlaceDetails(
      BookingModel booking) async {
    try {
      if (booking.placeId == null) {
        print('Cannot enrich booking ${booking.id}: placeId is null');
        return booking;
      }

      // Fetch place details
      final placeResponse =
          await _apiService.getRequest('/place/${booking.placeId}');
      print('Fetched place details for booking ${booking.id}: $placeResponse');

      final venueModel = VenueModel.fromJson(placeResponse);

      // Return booking dengan place data yang lengkap
      return booking.copyWith(place: venueModel);
    } catch (e) {
      print('Error enriching booking ${booking.id} with place details: $e');
      return booking; // Return original jika gagal
    }
  }

Future<dynamic> createBookingWithBuiltInValidation(BookingCreateRequest request) async {
  try {
    final response = await _apiService.postRequest(
      '/booking/create', 
      request.toJson()
    );
    
    if (response != null) {
      return BookingCreateWithResponse.fromJson(response);
    }
    
    throw Exception('Failed to create booking');
  } on DioException catch (e) {
    // Handle 409 Conflict specifically
    if (e.response?.statusCode == 409) {
      final data = e.response?.data;
      if (data != null) {
        // Parse available_slots from backend response
        final availableSlots = <TimeSlot>[];
        if (data['available_slots'] != null) {
          for (final slot in data['available_slots']) {
            availableSlots.add(TimeSlot(
              start: slot['start'],
              end: slot['end'], 
              available: slot['available'] ?? true,
            ));
          }
        }
        
        return BookingConflictResponse(
          success: false,
          error: data['error'] ?? 'Venue not available at selected time',
          availableSlots: availableSlots,
        );
      }
    }
    throw e;
  }
}

  // Cancel booking
  Future<bool> cancelBooking(int bookingId) async {
    try {
      final response = await _apiService.patchRequest(
        '/booking/user/cancel/$bookingId',
        {},
      );
      
      return response != null;
    } catch (e) {
      print('Error cancelling booking: $e');
      throw e;
    }
  }

  // Method baru untuk refresh booking details
  Future<BookingModel?> refreshBookingWithPlaceDetails(int bookingId) async {
    try {
      final booking = await getBookingById(bookingId);
      if (booking == null) return null;

      return await _enrichBookingWithPlaceDetails(booking);
    } catch (e) {
      print('Error refreshing booking $bookingId: $e');
      return null;
    }
  }

  // Batch enrich bookings (untuk optimasi jika perlu)
  Future<List<BookingModel>> enrichBookingsWithPlaceDetails(
      List<BookingModel> bookings) async {
    final enrichedBookings = <BookingModel>[];

    for (final booking in bookings) {
      if (_needsPlaceEnrichment(booking)) {
        final enriched = await _enrichBookingWithPlaceDetails(booking);
        enrichedBookings.add(enriched);
      } else {
        enrichedBookings.add(booking);
      }
    }

    return enrichedBookings;
  }

  // CALENDER

  Future<CalendarAvailabilityResponse> getCalendarAvailability({
    required int placeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];
      
      final response = await _apiService.getRequest(
        '/place/$placeId/calendar-availability?start_date=$startDateStr&end_date=$endDateStr'
      );
      
      return CalendarAvailabilityResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get calendar availability: $e');
    }
  }

  // Get detailed time slots for specific date
  Future<DetailedSlotsResponse> getDetailedTimeSlots({
    required int placeId,
    required DateTime date,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      
      final response = await _apiService.getRequest(
        '/place/$placeId/detailed-slots?date=$dateStr'
      );
      
      return DetailedSlotsResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get detailed time slots: $e');
    }
  }
  
}
