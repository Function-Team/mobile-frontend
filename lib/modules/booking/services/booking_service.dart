import 'package:flutter/material.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:function_mobile/modules/venue/data/models/venue_model.dart';
import 'package:function_mobile/modules/venue/data/repositories/venue_repository.dart';
import 'package:get/get.dart';

class BookingService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  // Method untuk membuat booking langsung ke FastAPI
  Future<BookingModel> createBooking(BookingCreateRequest request) async {
    try {
      print('Creating booking with data: ${request.toJson()}');
      
      // Kirim langsung ke FastAPI
      final response = await _apiService.postRequest('/booking', request.toJson());
      
      print('Booking created successfully: $response');
      return BookingModel.fromJson(response);
    } catch (e) {
      print('Error creating booking via FastAPI: $e');
      throw Exception('Failed to create booking: $e');
    }
  }

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
            // Fetch venue data for each booking
            VenueModel? venue;
            if (bookingData['place_id'] != null) {
              final venueRepository = VenueRepository();
              venue = await venueRepository.getVenueById(bookingData['place_id']);
            }

            // Create booking model with venue data
            final booking = BookingModel(
              id: bookingData['id'],
              placeId: bookingData['place_id'],
              userId: bookingData['user_id'],
              startTime: bookingData['start_time'],
              endTime: bookingData['end_time'],
              date: DateTime.parse(bookingData['date']),
              isConfirmed: bookingData['is_confirmed'] ?? false,
              createdAt: bookingData['created_at'] != null
                  ? DateTime.parse(bookingData['created_at'])
                  : null,
              place: venue, // Include venue data
            );

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

  // Cancel booking di FastAPI
  Future<void> cancelBooking(int bookingId) async {
    try {
      await _apiService.deleteRequest('/booking/$bookingId');
    } catch (e) {
      print('Error cancelling booking: $e');
      throw Exception('Failed to cancel booking: $e');
    }
  }
  // Helper method to check time conflicts
  Future<bool> checkTimeConflict({
    required int placeId,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final response = await _apiService.getRequest('/bookings/me');
      print('Fetched bookings for conflict check: $response');

      if (response is! List) return false;

      final bookings = <BookingModel>[];
      for (final bookingData in response) {
        if (bookingData['place_id'] == placeId) {
          // Only check bookings for the specific venue
          final booking = BookingModel(
            id: bookingData['id'],
            placeId: bookingData['place_id'],
            userId: bookingData['user_id'],
            startTime: bookingData['start_time'],
            endTime: bookingData['end_time'],
            date: DateTime.parse(bookingData['date']),
            isConfirmed: bookingData['is_confirmed'] ?? false,
            createdAt: bookingData['created_at'] != null
                ? DateTime.parse(bookingData['created_at'])
                : null,
          );
          bookings.add(booking);
        }
      }

      // Filter bookings for the same date
      final conflictingBookings = bookings
          .where((booking) =>
              booking.date.year == date.year &&
              booking.date.month == date.month &&
              booking.date.day == date.day &&
              (booking.status == BookingStatus.confirmed ||
                  booking.status == BookingStatus.pending))
          .toList();

      // Check for time overlaps
      for (final booking in conflictingBookings) {
        if (_timesOverlap(
            startTime, endTime, booking.startTime, booking.endTime)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Error checking time conflict: $e');
      return false; // Assume no conflict if we can't check
    }
  }

  bool _timesOverlap(String start1, String end1, String start2, String end2) {
    final start1Minutes = _timeToMinutes(start1);
    final end1Minutes = _timeToMinutes(end1);
    final start2Minutes = _timeToMinutes(start2);
    final end2Minutes = _timeToMinutes(end2);

    return !(end1Minutes <= start2Minutes || start1Minutes >= end2Minutes);
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  // Utility method to format time for API
  static String formatTimeForAPI(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Utility method to parse time from API
  static TimeOfDay parseTimeFromAPI(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
