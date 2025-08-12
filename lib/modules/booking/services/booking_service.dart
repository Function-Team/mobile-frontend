import 'dart:convert' show json;

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
      print('Fetching user bookings...');
      final response = await _apiService.getRequest('/bookings/me');

      if (response == null || response is! List) {
        return [];
      }

      final bookings = <BookingModel>[];

      for (int i = 0; i < response.length; i++) {
        try {
          final bookingData = response[i];
          if (bookingData is! Map<String, dynamic>) continue;

          final booking = BookingModel.fromJson(bookingData);

          // Safe enrichment dengan better error handling
          BookingModel enrichedBooking = booking;
          if (_needsPlaceEnrichment(booking)) {
            try {
              enrichedBooking = await _enrichBookingWithPlaceDetails(booking);
            } catch (enrichError) {
              print(
                  '⚠️ Failed to enrich booking ${booking.id}, using original: $enrichError');
              // Use original booking if enrichment fails
            }
          }

          bookings.add(enrichedBooking);
        } catch (e) {
          print('❌ Error processing booking at index $i: $e');
          // Skip this booking and continue
        }
      }

      return bookings;
    } catch (e) {
      print('❌ Error fetching user bookings: $e');
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

  Future<dynamic> createBookingWithBuiltInValidation(
      BookingCreateRequest request) async {
    try {
      print('Request data: ${request.toJson()}');

      final response =
          await _apiService.postRequest('/booking/create', request.toJson());

      print('API Response: $response');

      if (response != null) {
        print('Booking created successfully');
        return BookingCreateWithResponse.fromJson(response);
      }

      throw Exception('Failed to create booking: Empty response');
    } on DioException catch (e) {
      // Handle specific error codes
      if (e.response?.statusCode == 400) {
        final errorDetail =
            e.response?.data?['detail'] ?? 'Invalid request data';
        print('400 Error detail: $errorDetail');
        throw Exception('Validation Error: $errorDetail');
      } else if (e.response?.statusCode == 404) {
        print('404 Error: Venue not found');
        throw Exception('Venue not found');
      } else if (e.response?.statusCode == 409) {
        print('409 Conflict detected - handling conflict response');

        final data = e.response?.data;
        print('Conflict response data: $data');

        if (data != null && data is Map<String, dynamic>) {
          print('🔍 Parsing conflict response...');

          try {
            final availableSlots = <TimeSlot>[];

            if (data['available_slots'] != null &&
                data['available_slots'] is List) {
              print(
                  'Found ${data['available_slots'].length} available slots to parse');

              for (final slot in data['available_slots']) {
                if (slot is Map<String, dynamic>) {
                  try {
                    final timeSlot = TimeSlot.fromJson(slot);
                    availableSlots.add(timeSlot);
                    print('Parsed slot: ${timeSlot.displayTime}');
                  } catch (slotError) {
                    print('Slot data: $slot');
                  }
                }
              }
            }

            print(
                'Successfully parsed ${availableSlots.length} available slots');

            final conflictResponse = BookingConflictResponse(
              success: false,
              error: data['error'] ?? 'Venue not available at selected time',
              availableSlots: availableSlots,
            );

            print(
                'Returning BookingConflictResponse with ${availableSlots.length} slots');
            return conflictResponse;
          } catch (parseError) {
            print('Error parsing conflict response: $parseError');
            print('Conflict data structure: $data');

            // Return conflict response with empty slots if parsing fails
            return BookingConflictResponse(
              success: false,
              error: data['error'] ?? 'Venue not available at selected time',
              availableSlots: [],
            );
          }
        } else {
          print('Invalid conflict response data format');

          // Return basic conflict response if data is invalid
          return BookingConflictResponse(
            success: false,
            error: 'Venue not available at selected time',
            availableSlots: [],
          );
        }
      }

      // Handle other HTTP errors
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ??
            e.response!.data?['detail'] ??
            'HTTP Error $statusCode';

        print('HTTP Error $statusCode: $message');
        throw Exception('Server Error ($statusCode): $message');
      }

      // Handle network/connection errors
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          print('Timeout error: ${e.type}');
          throw Exception(
              'Connection timeout. Please check your internet connection.');

        case DioExceptionType.connectionError:
          print('Connection error: ${e.message}');
          throw Exception(
              'Network error. Please check your internet connection.');

        default:
          print('Other DioException: ${e.type} - ${e.message}');
          throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      // Handle non-Dio exceptions
      if (e is Exception && e.toString().startsWith('Exception: ')) {
        print('Re-throwing known exception: $e');
        rethrow; // Re-throw our custom exceptions
      }

      print('Unexpected error in createBookingWithBuiltInValidation: $e');
      print('Error type: ${e.runtimeType}');
      throw Exception('Unexpected error: $e');
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
          '/place/$placeId/calendar-availability?start_date=$startDateStr&end_date=$endDateStr');

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

      final response = await _apiService
          .getRequest('/place/$placeId/detailed-slots?date=$dateStr');

      return DetailedSlotsResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get detailed time slots: $e');
    }
  }
}
