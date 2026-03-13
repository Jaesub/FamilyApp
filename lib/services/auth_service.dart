import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fm2025/models/user.dart';

class AuthService {
  bool _loggedIn = false;
  User? _currentUser;
  String? _accessToken;

  bool get isLoggedIn => _loggedIn;
  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;

  // 에뮬레이터/실기기 환경에 따라 주소 바뀔 수 있음
  // 안드로이드 에뮬레이터면 보통 10.0.2.2 사용
  // 웹/윈도우면 localhost 가능
  final String baseUrl = 'http://10.0.2.2:5254';

  Future<User> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('이메일/비밀번호를 입력하세요.');
    }

    final loginRes = await http.post(
      Uri.parse('$baseUrl/api/Auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print("login statusCode: ${loginRes.statusCode}");
    print("login body: ${loginRes.body}");

    if (loginRes.statusCode != 200) {
      throw Exception('로그인 실패');
    }

    final loginJson = jsonDecode(loginRes.body) as Map<String, dynamic>;
    final token = loginJson['accessToken'] as String?;

    // headers: {
    //   "Authorization": "Bearer $token"
    // }

    if (token == null || token!.isEmpty) {
      throw Exception('토큰을 받지 못했습니다.');
    }

    _accessToken = token;

    final meRes = await http.get(
      Uri.parse('$baseUrl/api/Auth/me'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (meRes.statusCode != 200) {
      throw Exception('사용자 정보 조회 실패: ${meRes.body}');
    }

    final meJson = jsonDecode(meRes.body) as Map<String, dynamic>;
    final userEmail = meJson['email'] as String? ?? email;
    final displayName = userEmail.split('@').first;

    _currentUser = User(
      email: userEmail,
      displayName: displayName,
    );

    _loggedIn = true;
    return _currentUser!;
  }

  Future<void> logout() async {
    _loggedIn = false;
    _currentUser = null;
    _accessToken = null;
  }
}


//// API 사용 전 모의 버전
// import '../models/user.dart';
//
// class AuthService {
//   bool _loggedIn = false;
//   User? _currentUser;
//
//   bool get isLoggedIn => _loggedIn;
//   User? get currentUser => _currentUser;
//
//   /// 모의 로그인: 이메일/비밀번호가 비어있지 않으면 성공
//   /// 실제 API 붙일 때 여기서 네트워크 호출/검증 수행
//   Future<User> login({required String email, required String password}) async {
//     await Future.delayed(const Duration(milliseconds: 400));
//     if (email.isEmpty || password.isEmpty) {
//       throw Exception('이메일/비밀번호를 입력하세요.');
//     }
//     if (!email.contains('@')) {
//       throw Exception('올바른 이메일 형식이 아닙니다.');
//     }
//     // 예시: 서버에서 받아온 사용자 정보라고 가정
//     _currentUser = User(email: email, displayName: '고갱님');
//     _loggedIn = true;
//     return _currentUser!;
//   }
//
//   Future<void> logout() async {
//     await Future.delayed(const Duration(milliseconds: 200));
//     _loggedIn = false;
//     _currentUser = null;
//   }
// }
