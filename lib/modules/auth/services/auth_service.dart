import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Fix the base URL to point to the actual backend
  static const String baseUrl = 'http://backend.thefunction.id';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('Attempting login with username: $username');
      print('API URL: $baseUrl/api/login');

      // Changed to use application/json instead of form-urlencoded
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['access_token'] != null) {
          await saveToken(data['access_token']);
        }
        return data;
      } else {
        String errorMessage =
            'Login failed with status: ${response.statusCode}';

        try {
          final errorData = json.decode(response.body);
          if (errorData['detail'] != null) {
            if (errorData['detail'] is List) {
              final details = errorData['detail'] as List;
              if (details.isNotEmpty) {
                errorMessage = details.map((e) => e['msg']).join(", ");
              }
            } else {
              errorMessage = errorData['detail'];
            }
          }
        } catch (e) {
          if (response.body.isNotEmpty) {
            errorMessage = 'Server error: ${response.body}';
          }
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error during login: $e');
      throw Exception('Error during login: $e');
    }
  }

  Future<Map<String, dynamic>> signup(
      String username, String password, String email) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/api/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'username': username, 'password': password, 'email': email}),
      )
          .timeout(Duration(seconds: 10), onTimeout: () {
        throw Exception('Network timeout. Please check your connection.');
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = json.decode(response.body);
          if (data['access_token'] != null) {
            await saveToken(data['access_token']);
          }
          return data;
        } catch (e) {
          throw Exception('Invalid response format from server');
        }
      } else {
        String errorMessage =
            'Signup failed with status: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['detail'] ?? errorMessage;
        } catch (e) {
          if (response.body.isNotEmpty) {
            errorMessage = 'Server error: ${response.body}';
          }
        }

        // Handle the specific 500 error case
        if (response.statusCode == 500 &&
            response.body.contains('Internal Server Error')) {
          errorMessage =
              'The server is currently unavailable. Please try again later or contact support.';
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error during signup: $e');
      if (e.toString().contains('FormatException')) {
        throw Exception(
            'Server returned an invalid response. Please try again later.');
      } else {
        throw Exception('Error during signup: $e');
      }
    }
  }

  // Rest of the methods remain the same
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> fetchProtectedData(String endPoint) async {
    final headers = await getAuthHeaders();
    final response = await http
        .get(
      Uri.parse('$baseUrl$endPoint'),
      headers: headers,
    )
        .timeout(Duration(seconds: 10), onTimeout: () {
      throw Exception('Network timeout. Please check your connection.');
    });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      await removeToken();
      throw Exception('Unauthorized, please login again');
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await removeToken();
  }
}
