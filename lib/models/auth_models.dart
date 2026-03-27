class SignupRequest {
  final String name;
  final String email;
  final String password;

  SignupRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
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
}

class SocialLoginRequest {
  final String provider;
  final String providerUserId;
  final String email;
  final String name;
  final String? profileImageUrl;

  SocialLoginRequest({
    required this.provider,
    required this.providerUserId,
    required this.email,
    required this.name,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'providerUserId': providerUserId,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
    };
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final String? accessToken;

  AuthResponse({
    required this.success,
    required this.message,
    this.accessToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      accessToken: json['accessToken'],
    );
  }
}