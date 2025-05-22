// Fixed API Service with better authentication handling
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:function_mobile/core/constants/app_constants.dart';

class ApiService extends GetxService {
  late final dio.Dio _dio;

  ApiService() {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ));

    print("API Service initialized with base URL: ${AppConstants.baseUrl}");

    // Enhanced logging interceptor
    _dio.interceptors.add(dio.LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) {
        print("API: $obj");
      },
    ));

    // Fixed auth interceptor
    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          // Import the secure storage service directly to avoid circular dependency
          const storage = FlutterSecureStorage();
          final token = await storage.read(key: AppConstants.tokenKey);

          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
            print(
                "Added auth token to ${options.method} ${options.path}: Bearer ${token.substring(0, 10)}...");
          } else {
            print("No auth token found for ${options.method} ${options.path}");
          }
        } catch (e) {
          print(
              "Warning: Could not add auth token to ${options.method} ${options.path}: $e");
        }

        // Debug: Print all headers being sent
        print("Request headers: ${options.headers}");
        print("${options.method} ${options.path}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("${response.statusCode} ${response.requestOptions.path}");
        return handler.next(response);
      },
      onError: (dio.DioException e, handler) {
        print("API Error: ${e.type} - ${e.message}");
        print("URL: ${e.requestOptions.uri}");

        // Handle 401 Unauthorized specifically
        if (e.response?.statusCode == 401) {
          print("Authentication failed - token may be invalid or expired");
          // Clear the token from storage
          _clearInvalidToken();
        }

        return handler.next(e);
      },
    ));
  }

  Future<void> _clearInvalidToken() async {
    try {
      const storage = FlutterSecureStorage();
      await storage.delete(key: AppConstants.tokenKey);
      print("Cleared invalid token from storage");
    } catch (e) {
      print("Error clearing token: $e");
    }
  }

  Future<dynamic> getRequest(String endpoint,
      {Map<String, dynamic>? headers}) async {
    try {
      print("GET Request: $endpoint");

      final options = headers != null ? dio.Options(headers: headers) : null;
      final response = await _dio.get(endpoint, options: options);

      print("GET Response: ${response.statusCode}");

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else if (response.statusCode == 401) {
        throw Exception("Authentication required. Please login again.");
      } else {
        throw Exception("HTTP ${response.statusCode}: ${response.data}");
      }
    } on dio.DioException catch (e) {
      print("GET Error for $endpoint: ${e.type} - ${e.message}");
      if (e.response?.statusCode == 401) {
        throw Exception("Authentication required. Please login again.");
      }
      _handleDioError(e, endpoint);
      rethrow;
    } catch (e) {
      print("Unexpected error in GET $endpoint: $e");
      throw Exception("Unexpected error: $e");
    }
  }

  Future<dynamic> postRequest(
      String endpoint, Map<String, dynamic> data) async {
    try {
      print("POST Request: $endpoint");
      print("POST Data: $data");

      final response = await _dio.post(endpoint, data: data);

      print("POST Response: ${response.statusCode}");

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else if (response.statusCode == 401) {
        throw Exception("Authentication required. Please login again.");
      } else {
        throw Exception("HTTP ${response.statusCode}: ${response.data}");
      }
    } on dio.DioException catch (e) {
      print("POST Error for $endpoint: ${e.type} - ${e.message}");
      if (e.response?.statusCode == 401) {
        throw Exception("Authentication required. Please login again.");
      }
      _handleDioError(e, endpoint);
      rethrow;
    } catch (e) {
      print("Unexpected error in POST $endpoint: $e");
      throw Exception("Unexpected error: $e");
    }
  }

  Future<dynamic> postFormRequest(
      String endpoint, Map<String, dynamic> data) async {
    try {
      print("POST Form Request: $endpoint");

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

      print("POST Form Response: ${response.statusCode}");

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else {
        throw Exception("HTTP ${response.statusCode}: ${response.data}");
      }
    } on dio.DioException catch (e) {
      print("POST Form Error for $endpoint: ${e.type} - ${e.message}");
      _handleDioError(e, endpoint);
      rethrow;
    } catch (e) {
      print("Unexpected error in POST Form $endpoint: $e");
      throw Exception("Unexpected error: $e");
    }
  }

  Future<dynamic> putRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      print("PUT Request: $endpoint");

      final response = await _dio.put(endpoint, data: data);

      print("PUT Response: ${response.statusCode}");

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else if (response.statusCode == 401) {
        throw Exception("Authentication required. Please login again.");
      } else {
        throw Exception("HTTP ${response.statusCode}: ${response.data}");
      }
    } on dio.DioException catch (e) {
      print("PUT Error for $endpoint: ${e.type} - ${e.message}");
      if (e.response?.statusCode == 401) {
        throw Exception("Authentication required. Please login again.");
      }
      _handleDioError(e, endpoint);
      rethrow;
    } catch (e) {
      print("Unexpected error in PUT $endpoint: $e");
      throw Exception("Unexpected error: $e");
    }
  }

  Future<dynamic> patchRequest(
      String endpoint, Map<String, dynamic> data) async {
    try {
      print("PATCH Request: $endpoint");

      final response = await _dio.patch(endpoint, data: data);

      print("PATCH Response: ${response.statusCode}");

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else if (response.statusCode == 401) {
        throw Exception("Authentication required. Please login again.");
      } else {
        throw Exception("HTTP ${response.statusCode}: ${response.data}");
      }
    } on dio.DioException catch (e) {
      print("PATCH Error for $endpoint: ${e.type} - ${e.message}");
      if (e.response?.statusCode == 401) {
        throw Exception("Authentication required. Please login again.");
      }
      _handleDioError(e, endpoint);
      rethrow;
    } catch (e) {
      print("Unexpected error in PATCH $endpoint: $e");
      throw Exception("Unexpected error: $e");
    }
  }

  Future<dynamic> deleteRequest(String endpoint) async {
    try {
      print("DELETE Request: $endpoint");

      final response = await _dio.delete(endpoint);

      print("DELETE Response: ${response.statusCode}");

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      } else if (response.statusCode == 401) {
        throw Exception("Authentication required. Please login again.");
      } else {
        throw Exception("HTTP ${response.statusCode}: ${response.data}");
      }
    } on dio.DioException catch (e) {
      print("DELETE Error for $endpoint: ${e.type} - ${e.message}");
      if (e.response?.statusCode == 401) {
        throw Exception("Authentication required. Please login again.");
      }
      _handleDioError(e, endpoint);
      rethrow;
    } catch (e) {
      print("Unexpected error in DELETE $endpoint: $e");
      throw Exception("Unexpected error: $e");
    }
  }

  void _handleDioError(dio.DioException e, String endpoint) {
    String userMessage;

    switch (e.type) {
      case dio.DioExceptionType.connectionTimeout:
        userMessage =
            "Connection timeout. Please check if the server is running.";
        break;

      case dio.DioExceptionType.receiveTimeout:
        userMessage = "Server is taking too long to respond";
        break;

      case dio.DioExceptionType.sendTimeout:
        userMessage = "Request is taking too long to send";
        break;

      case dio.DioExceptionType.connectionError:
        userMessage =
            "Cannot connect to server. Please check your internet connection and server status.";
        break;

      case dio.DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        if (statusCode == 401) {
          userMessage = "Authentication required. Please login again.";
        } else if (statusCode == 404) {
          userMessage = "Endpoint not found.";
        } else if (statusCode == 500) {
          userMessage = "Server error occurred.";
        } else {
          userMessage = "Server error ($statusCode): $responseData";
        }
        break;

      case dio.DioExceptionType.cancel:
        userMessage = "Request was cancelled";
        break;

      case dio.DioExceptionType.unknown:
        userMessage = "Unknown network error occurred";
        break;
      case dio.DioExceptionType.badCertificate:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    throw Exception(userMessage);
  }

  // Debug method to check token
  Future<Map<String, dynamic>> debugToken() async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: AppConstants.tokenKey);

      return {
        'has_token': token != null,
        'token_length': token?.length ?? 0,
        'token_preview':
            token != null ? token.substring(0, 10) + '...' : 'none',
        'storage_key': AppConstants.tokenKey,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
}
