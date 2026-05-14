import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  final Widget targetPage;

  const SplashPage({
    super.key,
    required this.targetPage,
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    // 2.5초 대기
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => widget.targetPage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // 1. 디자인의 빨간색 그라데이션 적용
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF14636), // 상단 진한 빨강
              Color(0xFFFA897B), // 하단 연한 빨강/핑크
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 중앙 콘텐츠 (텍스트와 캐릭터)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // "뭐라 부르지?" 텍스트 (디자인 수치 반영: Size 20, 자간 -5%)
                    const Text(
                      "뭐라 부르지?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Noto Sans KR',
                        letterSpacing: 20 * -0.05, // 자간 -5% 적용
                      ),
                    ),
                    const SizedBox(height: 12),

                    // "뭐부" 메인 타이틀 (디자인 수치 적용: 자간 -5%)
                    const Text(
                      "뭐부",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 100,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Noto Sans KR',
                        letterSpacing: 100 * -0.05, // 자간 -5% 적용
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 캐릭터 이미지 (에셋)
                    _buildRobotAsset(),

                    // 캐릭터와 하단 텍스트 사이 간격 확보를 위한 공간
                    const SizedBox(height: 100),
                  ],
                ),
              ),

              // 하단 정보
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "kkojip @2026",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "v0.1",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRobotAsset() {
    return Image.asset(
      'assets/images/muboo_robot.png',
      width: 240,
      height: 240,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.face_retouching_natural,
          size: 150,
          color: Colors.white38,
        );
      },
    );
  }
}