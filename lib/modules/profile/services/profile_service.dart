import 'package:get/get.dart';
import 'package:function_mobile/core/services/api_service.dart';

class ProfileService extends GetxService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getProfile() async {
    return await _apiService.getRequest('user/me');
  }
}
