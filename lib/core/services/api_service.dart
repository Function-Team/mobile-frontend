import 'package:function_mobile/core/constants/app_constants.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService extends GetxService {
  late final dio.Dio _dio;
  bool _isRefreshing = false;
  final List<dio.RequestOptions> _failedRequests = [];
  int _retryCount = 0;
  static const int _maxRetries = 3;

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

    _dio.interceptors.add(dio.LogInterceptor(
      requestHeader: false,
      requestBody: false,
      responseHeader: false,
      responseBody: false,
      error: true,
      logPrint: (obj) {
        final logString = obj.toString();

        if (logString.contains('GET') ||
            logString.contains('/place/') ||
            logString.contains('*** Request ***') ||
            logString.contains('*** Response ***') ||
            logString.contains('uri: https://') ||
            logString.contains('method: GET') ||
            logString.contains('responseType:') ||
            logString.contains('Timeout:')) {
          return; // Skip logging
        }

        // HANYA tampilkan yang penting
        print("API: $obj");
      },
    ));

    // Fixed auth interceptor
    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) async {
        await _addAuthToken(options);
        handler.next(options);
      },
      onResponse: (response, handler) {
        // Reset retry count on successful response
        if (response.statusCode == 200) {
          _retryCount = 0;
        }

        // Only log non-GET requests to reduce noise
        if (response.requestOptions.method != 'GET') {
          print("${response.statusCode} ${response.requestOptions.path}");
        }
        handler.next(response);
      },
      onError: (dio.DioException e, handler) async {
        print("API Error: ${e.type} - ${e.message}");
        print("URL: ${e.requestOptions.uri}");

        // Handle 401 Unauthorized with refresh token logic
        if (e.response?.statusCode == 401 &&
            !_isRefreshing &&
            _retryCount < _maxRetries) {
          print(
              "Authentication failed - attempting token refresh (attempt ${_retryCount + 1}/$_maxRetries)");

          _retryCount++;
          final refreshSuccess = await _handleTokenRefresh(e.requestOptions);

          if (refreshSuccess) {
            // Retry the original request with new token
            try {
              await _addAuthToken(e.requestOptions);
              final retryResponse = await _dio.fetch(e.requestOptions);
              _retryCount = 0; // Reset on success
              return handler.resolve(retryResponse);
            } catch (retryError) {
              print("Retry after refresh failed: $retryError");
            }
          }

          // If refresh fails or max retries reached, clear tokens and redirect to login
          if (_retryCount >= _maxRetries) {
            print(
                "Max retry attempts reached. Clearing tokens and redirecting to login.");
            await _clearInvalidTokens();
            _retryCount = 0;
            // TODO: Redirect user to login screen
            Get.offAllNamed('/login'); // Adjust route as needed
          }
        }

        handler.next(e);
      },
    ));
  }

  Future<void> _addAuthToken(dio.RequestOptions options) async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: AppConstants.tokenKey);

      if (token != null && token.isNotEmpty && token != 'null') {
        options.headers['Authorization'] = 'Bearer $token';

        // Only log for non-GET requests to reduce noise
        if (options.method != 'GET') {
          print("🔐 Auth: ${options.method} ${options.path}");
        }
      } else {
        // Only log missing token for protected endpoints
        if (!_isPublicEndpoint(options.path)) {
          print("⚠️ No auth token found for ${options.method} ${options.path}");
        }
      }
    } catch (e) {
      print(
          "Warning: Could not add auth token to ${options.method} ${options.path}: $e");
    }
  }

  bool _isPublicEndpoint(String path) {
    final publicPaths = ['/login', '/signup', '/refresh', '/verify'];
    return publicPaths.any((publicPath) => path.contains(publicPath));
  }

  Future<bool> _handleTokenRefresh(dio.RequestOptions failedRequest) async {
    if (_isRefreshing) {
      // Already refreshing, add to queue but limit queue size
      if (_failedRequests.length < 10) {
        _failedRequests.add(failedRequest);
      }
      return false;
    }

    _isRefreshing = true;

    try {
      const storage = FlutterSecureStorage();
      final refreshToken =
          await storage.read(key: AppConstants.refreshTokenKey);

      if (refreshToken == null ||
          refreshToken.isEmpty ||
          refreshToken == 'null') {
        print("No valid refresh token available");
        return false;
      }

      print("Attempting to refresh access token...");

      // Create a new Dio instance for refresh request to avoid interceptor loops
      final refreshDio = dio.Dio(_dio.options.copyWith(
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
      ));

      final response = await refreshDio.get(
        '/refresh',
        queryParameters: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['access_token'] != null &&
          response.data['refresh_token'] != null) {
        // Save new tokens
        await storage.write(
            key: AppConstants.tokenKey, value: response.data['access_token']);
        await storage.write(
            key: AppConstants.refreshTokenKey,
            value: response.data['refresh_token']);

        print("Token refresh successful");

        // Retry failed requests (with limit)
        await _retryFailedRequests();

        return true;
      } else {
        print("Token refresh failed: Invalid response - ${response.data}");
        return false;
      }
    } catch (e) {
      print("Token refresh error: $e");

      // If refresh token is also expired/invalid, clear everything
      if (e.toString().contains('401') || e.toString().contains('Invalid')) {
        await _clearInvalidTokens();
      }

      return false;
    } finally {
      _isRefreshing = false;
      _failedRequests.clear();
    }
  }

  // Retry failed requests after successful token refresh
  Future<void> _retryFailedRequests() async {
    final requestsToRetry = List<dio.RequestOptions>.from(_failedRequests);

    // Limit the number of requests to retry
    final maxRetryRequests = 5;
    final limitedRequests = requestsToRetry.take(maxRetryRequests).toList();

    for (final request in limitedRequests) {
      try {
        await _addAuthToken(request);
        await _dio.fetch(request);
        print("Successfully retried request: ${request.path}");
      } catch (e) {
        print("Failed to retry request ${request.path}: $e");
        // Don't retry again to prevent loops
      }
    }
  }

  Future<void> _clearInvalidTokens() async {
    try {
      const storage = FlutterSecureStorage();
      await Future.wait([
        storage.delete(key: AppConstants.tokenKey),
        storage.delete(key: AppConstants.refreshTokenKey),
      ]);
      print("Cleared invalid tokens from storage");
    } catch (e) {
      print("Error clearing tokens: $e");
    }
  }

  Future<dynamic> getRequest(String endpoint,
      {Map<String, dynamic>? headers}) async {
    try {
      final options = headers != null ? dio.Options(headers: headers) : null;
      final response = await _dio.get(endpoint, options: options);

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
      final response = await _dio.post(endpoint, data: data);

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
      print("POST Form Data: $data");

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
      } else if (response.statusCode == 401) {
        throw Exception("Authentication required. Please login again.");
      } else {
        throw Exception("HTTP ${response.statusCode}: ${response.data}");
      }
    } on dio.DioException catch (e) {
      print("POST Form Error for $endpoint: ${e.type} - ${e.message}");
      if (e.response?.statusCode == 401) {
        throw Exception("Authentication required. Please login again.");
      }
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
        userMessage = "Certificate error occurred";
        break;
    }

    throw Exception(userMessage);
  }

  Future<Map<String, dynamic>> debugToken() async {
    try {
      const storage = FlutterSecureStorage();
      final accessToken = await storage.read(key: AppConstants.tokenKey);
      final refreshToken =
          await storage.read(key: AppConstants.refreshTokenKey);

      return {
        'has_access_token': accessToken != null,
        'has_refresh_token': refreshToken != null,
        'access_token_length': accessToken?.length ?? 0,
        'refresh_token_length': refreshToken?.length ?? 0,
        'access_token_preview':
            accessToken != null ? accessToken.substring(0, 10) + '...' : 'none',
        'refresh_token_preview': refreshToken != null
            ? refreshToken.substring(0, 10) + '...'
            : 'none',
        'storage_keys': {
          'access_token': AppConstants.tokenKey,
          'refresh_token': AppConstants.refreshTokenKey,
        },
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
}
