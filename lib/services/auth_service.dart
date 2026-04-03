import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fm2025/models/user.dart';
import 'package:fm2025/models/auth_models.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // test 용도 (true : 테스트 , false : 실제서버)
  static const bool useTest = false;

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

  Future<void> signup(SignupRequest request) async {
    // test 모드 사용 여부
    if (useTest) {
      await Future.delayed(const Duration(milliseconds: 500));

      // 실패 케이스
      if (request.email == 'dup@test.com') {
        throw Exception('이미 가입된 이메일입니다.');
      }

      return;
    }

    final res = await http.post(
      Uri.parse('$baseUrl/api/Auth/signup'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    print("signup statusCode: ${res.statusCode}");
    print("signup body: ${res.body}");

    if (res.statusCode != 200 && res.statusCode != 201) {
      try {
        final json = jsonDecode(res.body);
        throw Exception(json['message'] ?? '회원가입 실패');
      } catch (_) {
        throw Exception('회원가입 실패');
      }
    }
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    // test 모드 사용 여부
    if (useTest) {
      await Future.delayed(const Duration(milliseconds: 500));

      // 실패 케이스
      if (email == 'fail@test.com') {
        throw Exception('로그인 실패');
      }

      _accessToken = 'test-token';
      _currentUser = User(
        email: email,
        displayName: '테스트사용자',
      );
      _loggedIn = true;
      return _currentUser!;
    }

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
      try {
        final json = jsonDecode(loginRes.body) as Map<String, dynamic>;
        throw Exception(json['message'] ?? '로그인 실패');
      } catch (_) {
        throw Exception('로그인 실패');
      }
    }

    final loginJson = jsonDecode(loginRes.body) as Map<String, dynamic>;
    final token = loginJson['accessToken'] as String?;

    // headers: {
    //   "Authorization": "Bearer $token"
    // }

    if (token == null || token.isEmpty) {
      throw Exception('토큰을 받지 못했습니다.');
    }

    _accessToken = token;

    final user = await getMe();

    _currentUser = user;
    _loggedIn = true;
    return _currentUser!;
  }

  Future<User> loginWithGoogle() async {
    if (useTest) {
      await Future.delayed(const Duration(milliseconds: 500));

      _accessToken = 'mock-google-token';
      _currentUser = User(
        email: 'google@test.com',
        displayName: '구글사용자',
      );
      _loggedIn = true;

      return _currentUser!;
    }

    final GoogleSignIn googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize(
      // 백엔드에서 Google ID 토큰 검증할 거면
      // Google Cloud Console의 Web client ID를 넣는 게 일반적입니다.
      // serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
    );

    final GoogleSignInAccount account = await googleSignIn.authenticate();

    final auth = account.authentication;
    final idToken = auth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google ID 토큰을 받지 못했습니다.');
    }

    final user = await socialLogin(
      SocialLoginRequest(
        provider: 'google',
        providerUserId: account.id,
        email: account.email,
        name: account.displayName ?? account.email.split('@').first,
        profileImageUrl: account.photoUrl,
        idToken: idToken,
      ),
    );

    return user;
  }

  Future<User> getMe() async {
    final token = _accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('액세스 토큰이 없습니다.');
    }

    final meRes = await http.get(
        Uri.parse('$baseUrl/api/Auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

    print("me statusCode: ${meRes.statusCode}");
    print("me body: ${meRes.body}");

    if (meRes.statusCode != 200) {
      throw Exception('사용자 정보 조회 실패: ${meRes.body}');
    }

    final meJson = jsonDecode(meRes.body) as Map<String, dynamic>;
    final userEmail = meJson['email'] as String? ?? '';
    final displayName =
        (meJson['displayName'] as String?) ??
        (meJson['name'] as String?) ??
        (userEmail.isNotEmpty ? userEmail.split('@').first : '사용자');

    _currentUser = User(
        email: userEmail,
        displayName: displayName,
        );

    _loggedIn = true;
    return _currentUser!;
  }

  Future<User> socialLogin(SocialLoginRequest request) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/Auth/social-login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    print("social login statusCode: ${res.statusCode}");
    print("social login body: ${res.body}");

    if (res.statusCode != 200) {
      try {
        final json = jsonDecode(res.body);
        throw Exception(json['message'] ?? '소셜 로그인 실패');
      } catch (_) {
        throw Exception('소셜 로그인 실패');
      }
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final token = json['accessToken'] as String?;

    if (token == null || token.isEmpty) {
      throw Exception('토큰을 받지 못했습니다.');
    }

    _accessToken = token;

    final user = await getMe();

    _currentUser = user;
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
