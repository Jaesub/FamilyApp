import 'package:flutter/material.dart';
import 'package:fm2025/services/auth_service.dart';
import 'package:fm2025/models/user.dart';
import 'package:fm2025/login/signup_page.dart';
import 'package:fm2025/login/email_login_page.dart';

class LoginPage extends StatefulWidget {
  final AuthService auth;

  const LoginPage({super.key, required this.auth});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;

  Future<void> _socialLogin(Future<User> Function() login) async {
    setState(() => _loading = true);

    try {
      final user = await login();

      if (!mounted) return;
      Navigator.pop(context, user);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // void _goEmailLogin() {
  //   // 지금은 기존 이메일 로그인 UI를 따로 분리하지 않았으므로 임시 처리
  //   // 나중에 EmailLoginPage로 분리하면 여기서 push 하면 됩니다.
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('이메일 로그인 화면은 다음 단계에서 분리합니다.')),
  //   );
  // }

  Future<void> _goEmailLogin() async {
    final user = await Navigator.of(context).push<User>(
      MaterialPageRoute(
        builder: (_) => EmailLoginPage(auth: widget.auth),
      ),
    );

    if (!mounted) return;

    if (user != null) {
      Navigator.pop(context, user);
    }
  }

  Future<void> _goSignup() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SignupPage(auth: widget.auth),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입이 완료되었습니다. 로그인해주세요.')),
      );
    }
  }

  Widget _socialButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    String? iconText,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 26),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: icon != null
                  ? Icon(icon, color: textColor, size: 28)
                  : Text(
                iconText ?? '',
                style: TextStyle(
                  color: textColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final nav = Navigator.of(context);
            if (nav.canPop()) nav.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '뭐부',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Image.asset(
                    'assets/images/splash_character.png',
                    width: 108,
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    '뭐라\n부르지?',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      letterSpacing: -1.5,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 3),

              _socialButton(
                text: 'Google',
                backgroundColor: const Color(0xFFF2F2F2),
                textColor: const Color(0xFF555555),
                iconText: 'G',
                onTap: () => _socialLogin(widget.auth.loginWithGoogle),
              ),
              const SizedBox(height: 14),

              _socialButton(
                text: '카카오톡',
                backgroundColor: const Color(0xFFFEE500),
                textColor: Colors.black,
                icon: Icons.chat_bubble,
                onTap: () => _socialLogin(widget.auth.loginWithKakao),
              ),
              const SizedBox(height: 14),

              _socialButton(
                text: '네이버',
                backgroundColor: const Color(0xFF03C75A),
                textColor: Colors.white,
                iconText: 'N',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('네이버 로그인은 다음 단계에서 연결합니다.')),
                  );
                },
              ),
              const SizedBox(height: 14),

              _socialButton(
                text: 'Apple',
                backgroundColor: Colors.black,
                textColor: Colors.white,
                icon: Icons.apple,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Apple 로그인은 다음 단계에서 연결합니다.')),
                  );
                },
              ),

              const Spacer(flex: 2),

              TextButton(
                onPressed: _loading ? null : _goEmailLogin,
                child: const Text(
                  '이메일로 로그인',
                  style: TextStyle(
                    color: Colors.black38,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              TextButton(
                onPressed: _loading ? null : _goSignup,
                child: const Text(
                  '회원가입',
                  style: TextStyle(
                    color: Colors.black38,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}