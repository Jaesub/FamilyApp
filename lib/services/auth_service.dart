class AuthService {
  bool _loggedIn = false;
  bool get isLoggedIn => _loggedIn;

  /// 모의 로그인: 이메일/비밀번호가 비어있지 않으면 성공
  Future<void> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 로딩 느낌
    if (email.isEmpty || password.isEmpty) {
      throw Exception('이메일과 비밀번호를 입력하세요.');
    }
    // 예시: 아주 단순한 검증. 필요 시 서버/Firebase로 교체.
    if (!email.contains('@')) throw Exception('올바른 이메일 형식이 아닙니다.');
    _loggedIn = true;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _loggedIn = false;
  }
}
