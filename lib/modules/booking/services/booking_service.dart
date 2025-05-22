import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:function_mobile/modules/booking/models/booking_model.dart';
import 'package:get/get.dart';
import 'dart:convert';

class BookingService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final _storage = const FlutterSecureStorage();

  // API Methods
  Future<BookingModel> createBooking(BookingCreateRequest request) async {
    try {
      print('Creating booking with data: ${request.toJson()}');
      final response = await _apiService.postRequest('/booking', request.toJson());
      print('Booking created successfully: $response');
      return BookingModel.fromJson(response);
    } catch (e) {
      print('Error creating booking via API: $e');
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<List<BookingModel>> getUserBookings() async {
    try {
      final response = await _apiService.getRequest('/booking');
      print('Fetched bookings: $response');
      
      if (response is List) {
        return response.map((json) => BookingModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching bookings from API: $e');
      // Fallback to local storage
      return await getLocalBookings();
    }
  }

  Future<BookingModel?> getBookingById(int bookingId) async {
    try {
      final response = await _apiService.getRequest('/booking/$bookingId');
      return BookingModel.fromJson(response);
    } catch (e) {
      print('Error fetching booking by ID: $e');
      return null;
    }
  }

  Future<BookingModel> confirmBooking(int bookingId) async {
    try {
      final response = await _apiService.putRequest('/booking/$bookingId', {});
      return BookingModel.fromJson(response);
    } catch (e) {
      print('Error confirming booking: $e');
      throw Exception('Failed to confirm booking: $e');
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    try {
      await _apiService.deleteRequest('/booking/$bookingId');
    } catch (e) {
      print('Error cancelling booking: $e');
      throw Exception('Failed to cancel booking: $e');
    }
  }

  Future<List<BookingModel>> getBookingsByMonth(int month, int year) async {
    try {
      final response = await _apiService.getRequest('/booking?month=$month&year=$year');
      if (response is List) {
        return response.map((json) => BookingModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching bookings by month: $e');
      return [];
    }
  }

  // Local Storage Methods (for offline support)
  Future<void> saveLocalBookings(List<BookingModel> bookings) async {
    final jsonList = bookings.map((booking) => booking.toJson()).toList();
    await _storage.write(key: 'local_bookings', value: jsonEncode(jsonList));
  }

  Future<List<BookingModel>> getLocalBookings() async {
    try {
      final bookingsJson = await _storage.read(key: 'local_bookings');
      if (bookingsJson == null) return [];
      
      final List<dynamic> jsonList = jsonDecode(bookingsJson);
      return jsonList.map((json) => BookingModel.fromJson(json)).toList();
    } catch (e) {
      print('Error reading local bookings: $e');
      return [];
    }
  }

  Future<void> addLocalBooking(BookingModel booking) async {
    final bookings = await getLocalBookings();
    bookings.add(booking);
    await saveLocalBookings(bookings);
  }

  Future<void> updateLocalBooking(BookingModel updatedBooking) async {
    final bookings = await getLocalBookings();
    final index = bookings.indexWhere((b) => b.id == updatedBooking.id);
    if (index != -1) {
      bookings[index] = updatedBooking;
      await saveLocalBookings(bookings);
    }
  }

  Future<void> removeLocalBooking(int bookingId) async {
    final bookings = await getLocalBookings();
    bookings.removeWhere((booking) => booking.id == bookingId);
    await saveLocalBookings(bookings);
  }

  // Sync Methods
  Future<List<BookingModel>> syncBookings() async {
    try {
      // Try to get from API first
      final apiBookings = await getUserBookings();
      
      // Save to local storage
      await saveLocalBookings(apiBookings);
      
      return apiBookings;
    } catch (e) {
      print('Sync failed, using local bookings: $e');
      return await getLocalBookings();
    }
  }

  // Helper method to check if booking time conflicts exist
  Future<bool> checkTimeConflict({
    required int placeId,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final bookings = await getUserBookings();
      
      // Filter bookings for the same place and date
      final conflictingBookings = bookings.where((booking) => 
        booking.placeId == placeId && 
        booking.date.year == date.year &&
        booking.date.month == date.month &&
        booking.date.day == date.day &&
        (booking.status == BookingStatus.confirmed || booking.status == BookingStatus.pending)
      ).toList();

      // Check for time overlaps
      for (final booking in conflictingBookings) {
        if (_timesOverlap(startTime, endTime, booking.startTime, booking.endTime)) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Error checking time conflict: $e');
      return false;
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
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  // Utility method to parse time from API
  static TimeOfDay parseTimeFromAPI(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}