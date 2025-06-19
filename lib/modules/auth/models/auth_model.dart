class User {
  final int id;
  final String email;
  final String username;
  final String? token;
  final DateTime? createdAt;
  final bool? isVerified;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.token,
    this.createdAt,
    this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      token: json['token'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      isVerified: json['is_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'token': token,
      'created_at': createdAt?.toIso8601String(),
      'is_verified': isVerified,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? username,
    String? token,
    DateTime? createdAt,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  Map<String, dynamic> toFormData() {
    return {
      'username': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String email;
  final String username;
  final String password;

  RegisterRequest({
    required this.email,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'password': password,
    };
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final User? user;
  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;

  AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.tokenType,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown response',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
    );
  }
  factory AuthResponse.fromLoginResponse(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['access_token'] != null,
      message:
          json['access_token'] != null ? 'Login successful' : 'Login failed',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'] ?? ['Bearer'],
    );
  }
}

class RefreshTokenResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  RefreshTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
    );
  }
}
