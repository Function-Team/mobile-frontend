import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:function_mobile/core/constants/app_constants.dart';
import 'package:function_mobile/modules/auth/services/auth_service.dart';

class ApiService extends GetxService {
  late final dio.Dio _dio;

  ApiService() {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
      },
    ));
    print("Using API base URL: ${AppConstants.baseUrl}");

    // Logging interceptor
    _dio.interceptors.add(dio.LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: false,
      error: true,
    ));

    // Auth interceptor
    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) async {
        final authService = AuthService();
        final token = await authService.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
      onError: (dio.DioException e, handler) {
        if (e.response != null) {
          throw Exception(
              "Error ${e.response?.statusCode}: ${e.response?.data}");
        } else {
          throw Exception("Error: ${e.message}");
        }
      },
    ));
  }

  // Getter for accessing Dio instance directly if needed
  dio.Dio get dioInstance => _dio;

  Future<dynamic> getRequest(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } on dio.DioException catch (e) {
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
    } on dio.DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<dynamic> postFormRequest(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final formData = dio.FormData.fromMap(data);
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: dio.Options(
          contentType: 'application/x-www-form-urlencoded',
          headers: {
            'Accept': 'application/json',
          },
        ),
      );
      return response.data;
    } on dio.DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<dynamic> putRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on dio.DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<dynamic> deleteRequest(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data;
    } on dio.DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  void _handleDioError(dio.DioException e) {
    switch (e.type) {
      case dio.DioExceptionType.connectionTimeout:
        throw Exception("Koneksi timeout");
      case dio.DioExceptionType.receiveTimeout:
        throw Exception("Timeout saat menerima data");
      case dio.DioExceptionType.badResponse:
        throw Exception("Error ${e.response?.statusCode}: ${e.response?.data}");
      default:
        throw Exception("Error: ${e.message}");
    }
  }
}