import 'package:get/get.dart';
import 'package:function_mobile/core/services/api_service.dart';
import 'package:dio/dio.dart' as dio;

class ProfileService extends GetxService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getProfile() async {
    return await _apiService.getRequest('user/me');
  }

  Future<Map<String, dynamic>> editProfile({
    required String currentPassword,
    String? username,
    String? email,
  }) async {
    try {
      print('ProfileService: Editing profile...');
      
      final requestData = {
        'current_password': currentPassword,
      };
      
      if (username != null && username.isNotEmpty) {
        requestData['username'] = username;
      }
      
      if (email != null && email.isNotEmpty) {
        requestData['email'] = email;
      }

      final response = await _apiService.putRequest('/user/edit', requestData);
      
      if (response != null) {
        print('ProfileService: Profile updated successfully');
        return Map<String, dynamic>.from(response);
      } else {
        throw Exception('Failed to update profile. Please try again.');
      }
    } on dio.DioException catch (e) {
      print('ProfileService: DioException during profile edit: ${e.response?.statusCode} - ${e.response?.data}');
      
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null && errorData['detail'] != null) {
          final detail = errorData['detail'].toString();
          if (detail.toLowerCase().contains('password saat ini tidak benar') || 
              detail.toLowerCase().contains('password saat ini salah')) {
            throw Exception('Current password is incorrect');
          } else if (detail.toLowerCase().contains('username sudah digunakan')) {
            throw Exception('Username is already taken');
          } else if (detail.toLowerCase().contains('email sudah terdaftar')) {
            throw Exception('Email is already registered');
          } else {
            throw Exception(detail);
          }
        }
        throw Exception('Invalid data. Please check your inputs.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 422) {
        throw Exception('Please check your input format and try again.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Failed to send confirmation email. Please try again.');
      } else if (e.response?.statusCode == null) {
        throw Exception('Please check your internet connection.');
      } else {
        throw Exception('Failed to update profile. Please try again.');
      }
    } catch (e) {
      print('ProfileService: General error during profile edit: $e');
      
      if (e.toString().startsWith('Exception:')) {
        rethrow;
      }
      
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<Map<String, dynamic>> confirmEmailChange(String token) async {
    try {
      print('ProfileService: Confirming email change...');
      
      final response = await _apiService.postRequest('/user/confirm-email-change', {
        'token': token,
      });
      
      if (response != null) {
        print('ProfileService: Email change confirmed successfully');
        return Map<String, dynamic>.from(response);
      } else {
        throw Exception('Failed to confirm email change. Please try again.');
      }
    } on dio.DioException catch (e) {
      print('ProfileService: DioException during email confirmation: ${e.response?.statusCode} - ${e.response?.data}');
      
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid or expired confirmation token');
      } else {
        throw Exception('Failed to confirm email change. Please try again.');
      }
    } catch (e) {
      print('ProfileService: General error during email confirmation: $e');
      
      if (e.toString().startsWith('Exception:')) {
        rethrow;
      }
      
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }
}
