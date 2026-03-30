import 'package:flutter/material.dart';
import 'splash/splash_page.dart';
import 'home/home_page.dart';
import 'models/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '우리집 꿀범벅 가족',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      debugShowCheckedModeBanner: false,

      // SplashPage로 시작하며, 로딩이 끝나면 HomePage로 모든 필수 파라미터를 넘겨줍니다.
      home: SplashPage(
        targetPage: HomePage(
          isDarkMode: false, // 기본 테마 설정
          onToggleDarkMode: () {
            debugPrint("다크모드 토글 요청");
          },
          onLogout: () async {
            debugPrint("로그아웃 로직 실행");
          },
          onLoginRequested: (context) async {
            debugPrint("로그인 화면 이동 요청");
            // 여기서 실제 로그인 페이지로 이동하는 로직이 들어갈 수 있습니다.
          },
          user: null, // "로그인은 로딩 후 home_page 내에서 할 것"이므로 처음엔 null 전달
        ),
      ),
    );
  }
}