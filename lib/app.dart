// lib/app.dart
import 'package:flutter/material.dart';
import 'package:fm2025/home/home_page.dart';
import 'package:fm2025/services/auth_service.dart';
import 'package:fm2025/login/login_page.dart';
import 'package:fm2025/models/user.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _auth = AuthService(); // 로그인 상태/유저 보관
  bool _isDarkMode = false;

  // 로그인 플로우: LoginPage를 push하고, 성공 시 User를 돌려받아 상태만 갱신
  Future<void> _startLoginFlow(BuildContext context) async {
    final User? user = await Navigator.of(context).push<User>(
      MaterialPageRoute(builder: (_) => LoginPage(auth: _auth)),
    );
    if (user != null && mounted) {
      setState(() {}); // _auth.currentUser 갱신됨 → HomePage에 반영
    }
  }

  // 로그아웃: 상태만 초기화하고 리빌드 (화면 전환 없음)
  Future<void> _logout() async {
    await _auth.logout();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '가족사랑 앱 💖',
      theme: _isDarkMode
          ? ThemeData.dark()
          : ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: HomePage(
        isDarkMode: _isDarkMode,
        onToggleDarkMode: () => setState(() => _isDarkMode = !_isDarkMode),
        onLogout: _logout,                               // 로그아웃 시 상태만 갱신
        onLoginRequested: (ctx) => _startLoginFlow(ctx), // 로그인 요청 → 모달
        user: _auth.currentUser,                         // Drawer에 표시할 유저
      ),
    );
  }
}
