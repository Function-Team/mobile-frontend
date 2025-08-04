import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/modules/venue/data/repositories/venue_repository.dart';
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

  Future<BookingModel> createBooking(BookingCreateRequest request) async {
    try {
      print('Creating booking with data: ${request.toJson()}');

      // Send directly to FastAPI
      final response =
          await _apiService.postRequest('/booking', request.toJson());
      print('Full booking response: $response');

      // Parse booking
      final booking = BookingModel.fromJson(response);

      // Immediately enrich dengan place details untuk consistency
      final enrichedBooking = await _enrichBookingWithPlaceDetails(booking);

      print('Booking created successfully with place details');
      return enrichedBooking;
    } catch (e) {
      print('Error creating booking via FastAPI: $e');
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<dynamic> createBookingWithConflictHandling(BookingCreateRequest request) async {
    try {
      final response = await _apiService.postRequest('/booking', request.toJson());
      
      if (response != null) {
        return BookingCreateResponse.fromJson(response);
      }
      
      throw Exception('Failed to create booking');
    } on DioException catch (e) {
      // Handle 409 Conflict specifically
      if (e.response?.statusCode == 409) {
        final data = e.response?.data;
        if (data != null) {
          final conflictData = data['detail'] ?? data;
          return BookingConflictResponse.fromJson(conflictData);
        }
      }
      throw e;
    }
  }

   Future<BookingValidationResponse> validateBooking(BookingCreateRequest request) async {
    try {
      final response = await _apiService.postRequest(
        '/booking/validate',
        request.toJson(),
      );

      if (response != null) {
        return BookingValidationResponse.fromJson(response);
      }
      
      throw Exception('Failed to validate booking');
    } catch (e) {
      throw e;
    }
  }

  // Check venue availability untuk tanggal tertentu
 Future<VenueAvailabilityResponse> checkVenueAvailability({
    required int placeId,
    required DateTime date,
    int? durationHours,
  }) async {
    try {
      final params = {
        'date': date.toIso8601String().split('T')[0],
        if (durationHours != null) 'duration_hours': durationHours.toString(),
      };

      // Use query string in URL instead of queryParameters
      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      final response = await _apiService.getRequest(
        '/place/$placeId/check-availability?$queryString',
      );

      if (response != null) {
        return VenueAvailabilityResponse.fromJson(response);
      }
      
      throw Exception('Failed to check availability');
    } catch (e) {
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
}
