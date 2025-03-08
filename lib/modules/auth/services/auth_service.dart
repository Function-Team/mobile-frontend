import 'package:function_mobile/modules/auth/models/auth_model.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'https://api-placholder.inimshdummy.com';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // TODO: nanti diganti pake kode untuk manggil API FastAPI
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/auth/login'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode(request.toJson()),
      // );

      if (request.email == "test123@gmail.com" &&
          request.password == "12345678") {
        final mockUser = User(
            id: '1',
            email: request.email,
            username: 'codeblue',
            token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
        await saveToken(mockUser.token ?? '');

        return AuthResponse(
            success: true, message: "Login succesfull", user: mockUser);
      }
      return AuthResponse(success: false, message: "Invalid email or password");
    } catch (e) {
      return AuthResponse(
        success: false,
        message: "Login failed: ${e.toString()}",
      );
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Ganti dengan kode untuk memanggil API FastAPI nanti
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/auth/register'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode(request.toJson()),
      // );

      final mockUser = User(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        email: request.email,
        username: request.username,
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );
      await saveToken(mockUser.token ?? '');

      return AuthResponse(
          success: true, message: 'Login succesful', user: mockUser);
    } catch (e) {
      return AuthResponse(
          success: false, message: 'Login Failed: ${e.toString()}');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await clearToken();
  }
}
