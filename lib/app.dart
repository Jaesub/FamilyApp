import 'package:flutter/material.dart';
import 'home/home_page.dart';
import 'services/auth_service.dart';
import 'login/login_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _auth = AuthService(); // 인증 서비스
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>(); // 로그아웃
  bool _isDarkMode = false;

  void _onLoggedIn() => setState(() {}); // 로그인 성공 시 리빌드
  Future<void> _onLoggedOut()  async {
    await _auth.logout();

    // if (mounted) setState(() {});
    // debugPrint('isLoggedIn(before build) = ${_auth.isLoggedIn}');

    if (!mounted) return;

    // HomePage를 완전히 제거하고 LoginPage만 남기기
    _navKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginPage(auth: _auth, onLoggedIn: _onLoggedIn),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final home = _auth.isLoggedIn
        ? HomePage(
      isDarkMode: _isDarkMode,
      onToggleDarkMode: () => setState(() => _isDarkMode = !_isDarkMode),
      onLogout: _onLoggedOut,                 // 로그아웃 콜백
    ) : LoginPage(auth: _auth, onLoggedIn: _onLoggedIn); // 로그인 페이지

    return MaterialApp(
      navigatorKey: _navKey,
      title: '가족사랑 앱 💖',
      theme: _isDarkMode
          ? ThemeData.dark()
          : ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: HomePage(
        isDarkMode: _isDarkMode,
        onToggleDarkMode: () {
          setState(() {
            _isDarkMode = !_isDarkMode;
          });
        }, onLogout: _onLoggedOut,
      ),
    );
  }
  // // 로그아웃 됨
  //     theme: _isDarkMode ? ThemeData.dark()
  //         : ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
  //     home: _auth.isLoggedIn
  //         ? HomePage(
  //       isDarkMode: _isDarkMode,
  //       onToggleDarkMode: () => setState(() => _isDarkMode = !_isDarkMode),
  //       onLogout: _onLoggedOut, // 콜백 전달
  //     )
  //         : LoginPage(auth: _auth, onLoggedIn: _onLoggedIn),
  //   );
  // }
}
