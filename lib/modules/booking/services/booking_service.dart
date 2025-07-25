import 'package:flutter/material.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/modules/venue/data/repositories/venue_repository.dart';
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
            // Parse booking first
            final booking = BookingModel.fromJson(bookingData);

            // SOLUSI UTAMA: Fetch place details jika tidak ada atau tidak lengkap
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

  // Cancel booking di FastAPI
  Future<void> cancelBooking(int bookingId) async {
    try {
      await _apiService.patchRequest('/booking/user/cancel/$bookingId', {});
    } catch (e) {
      print('Error cancelling booking: $e');
      throw Exception('Failed to cancel booking: $e');
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
