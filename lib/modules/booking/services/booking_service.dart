import 'package:get/get.dart';
import 'package:function_mobile/core/services/api_service.dart';

class BookingService extends GetxService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getBookingById(int id) async {
    return await _apiService.getRequest('bookings/$id');
  }

  Future<Map<String, dynamic>> getBookings() async {
    return await _apiService.getRequest('bookings');
  }
}
