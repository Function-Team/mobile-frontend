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
            final booking = BookingModel.fromJson(bookingData);
            bookings.add(booking);
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

  Future<BookingModel> createBooking(BookingCreateRequest request) async {
    try {
      print('Creating booking with data: ${request.toJson()}');

      // Send directly to FastAPI
      final response =
          await _apiService.postRequest('/booking', request.toJson());
      print('Full booking response: $response');

      print('Booking created successfully: $response');
      return BookingModel.fromJson(response);
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
}
