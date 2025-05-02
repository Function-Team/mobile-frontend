import 'package:function_mobile/modules/auth/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:function_mobile/core/constants/app_constants.dart';

class ApiService extends GetxService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        "Content-Type": "application/json",
      },
    ));

    // Konfigurasi interceptor untuk handling error
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Ambil token dari AuthService
        final authService = AuthService();
        final token = await authService.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers["Authorization"] = "Bearer $token";
        }
        // Lanjutkan permintaan
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle error secara global
        if (e.response != null) {
          throw Exception(
              "Error ${e.response?.statusCode}: ${e.response?.data}");
        } else {
          throw Exception("Error: ${e.message}");
        }
      },
    ));
  }

  Future<dynamic> getRequest(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<dynamic> postRequest(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<dynamic> putRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<dynamic> deleteRequest(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  void _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        throw Exception("Koneksi timeout");
      case DioExceptionType.receiveTimeout:
        throw Exception("Timeout saat menerima data");
      case DioExceptionType.badResponse:
        throw Exception("Error ${e.response?.statusCode}: ${e.response?.data}");
      default:
        throw Exception("Error: ${e.message}");
    }
  }
}
