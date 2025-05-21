import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'dart:convert';

class BookingService extends GetxService {
  // final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  // Future<Map<String, dynamic>> getBookingById(int id) async {
  //   return await _apiService.getRequest('bookings/$id');
  // }

  // Future<Map<String, dynamic>> getBookings() async {
  //   return await _apiService.getRequest('bookings');
  // }

  Future<void> saveBookings(List<Map<String, dynamic>> bookings) async {
    await _storage.write(key: 'bookings', value: jsonEncode(bookings));
  }

  Future<List<Map<String, dynamic>>> getBookings() async {
    final bookingsJson = await _storage.read(key: 'bookings');
    if (bookingsJson == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(bookingsJson));
  }
  
  Future<List<int>> getFavorites() async {
    final favoritesJson = await _storage.read(key: 'favorites');
    if (favoritesJson == null) return [];
    return List<int>.from(jsonDecode(favoritesJson));
  }

  Future<void> addBooking(Map<String, dynamic> booking) async {
    final bookings = await getBookings();
    bookings.add(booking);
    await saveBookings(bookings);
  }

  Future<void> removeBooking(int bookingId) async {
    final bookings = await getBookings();
    bookings.removeWhere((booking) => booking['id'] == bookingId);
    await saveBookings(bookings);
  }

  Future<void> updateBooking(Map<String, dynamic> updatedBooking) async {
    final bookings = await getBookings();
    final index =
        bookings.indexWhere((booking) => booking['id'] == updatedBooking['id']);
    if (index != -1) {
      bookings[index] = updatedBooking;
      await saveBookings(bookings);
    }
  }
}
