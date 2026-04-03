import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fm2025/home/home_page.dart';
import 'package:fm2025/services/auth_service.dart';

class SplashPage extends StatefulWidget {
  final AuthService auth;
  final bool isDarkMode;
  final VoidCallback onToggleDarkMode;
  final Future<void> Function() onLogout;
  final Future<void> Function(BuildContext context) onLoginRequested;

  const SplashPage({
    super.key,
    required this.auth,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.onLogout,
    required this.onLoginRequested,
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _moveNext();
  }

  Future<void> _moveNext() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(
          isDarkMode: widget.isDarkMode,
          onToggleDarkMode: widget.onToggleDarkMode,
          onLogout: widget.onLogout,
          onLoginRequested: widget.onLoginRequested,
          user: widget.auth.currentUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF4A3D),
              Color(0xFFFF8A80),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              const Text(
                '뭐라 부르지?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '뭐부',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/splash_character.png',
                width: 220,
              ),
              const Spacer(),
              const Text(
                'kkojip @2026',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'v0.1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}