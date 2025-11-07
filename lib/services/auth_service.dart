import '../models/user.dart';

class AuthService {
  bool _loggedIn = false;
  User? _currentUser;

  bool get isLoggedIn => _loggedIn;
  User? get currentUser => _currentUser;

  /// 모의 로그인: 이메일/비밀번호가 비어있지 않으면 성공
  /// 실제 API 붙일 때 여기서 네트워크 호출/검증 수행
  Future<User> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (email.isEmpty || password.isEmpty) {
      throw Exception('이메일/비밀번호를 입력하세요.');
    }
    if (!email.contains('@')) {
      throw Exception('올바른 이메일 형식이 아닙니다.');
    }
    // 예시: 서버에서 받아온 사용자 정보라고 가정
    _currentUser = User(email: email, displayName: '고갱님');
    _loggedIn = true;
    return _currentUser!;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _loggedIn = false;
    _currentUser = null;
  }
}
