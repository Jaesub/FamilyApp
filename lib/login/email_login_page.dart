import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class EmailLoginPage extends StatefulWidget {
  final AuthService auth;

  const EmailLoginPage({
    super.key,
    required this.auth,
  });

  @override
  State<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  final _emailCtr = TextEditingController();
  final _passwordCtr = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _rememberLogin = true;
  bool _obscurePassword = true;
  bool _loading = false;

  static const _primaryRed = Color(0xFFF04438);
  static const _borderGrey = Color(0xFFDADADA);
  static const _textGrey = Color(0xFFB5B5B5);

  @override
  void dispose() {
    _emailCtr.dispose();
    _passwordCtr.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtr.text.trim();
    final password = _passwordCtr.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final User user = await widget.auth.login(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.pop(context, user);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _canLogin =>
      _emailCtr.text.trim().isNotEmpty && _passwordCtr.text.trim().isNotEmpty;

  Widget _inputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, _) {
        final focused = focusNode.hasFocus;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 84,
          decoration: BoxDecoration(
            border: Border.all(
              color: focused ? _primaryRed : _borderGrey,
              width: focused ? 1.6 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(
                color: _textGrey,
                fontSize: 18,
              ),
              suffixIcon: suffixIcon,
            ),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canLogin = _canLogin;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 92, 40, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '뭐부',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '이메일 로그인',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -1.2,
                ),
              ),

              const SizedBox(height: 64),

              _inputField(
                controller: _emailCtr,
                focusNode: _emailFocus,
                hintText: '아이디(이메일)',
              ),

              const SizedBox(height: 14),

              _inputField(
                controller: _passwordCtr,
                focusNode: _passwordFocus,
                hintText: '비밀번호',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey.shade300,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 76,
                child: ElevatedButton(
                  onPressed: (!_loading && canLogin) ? _login : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: _primaryRed,
                    disabledBackgroundColor: Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    '로그인',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: _rememberLogin,
                      activeColor: _primaryRed,
                      activeTrackColor: const Color(0xFFFFE1DE),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.shade200,
                      onChanged: (v) {
                        setState(() => _rememberLogin = v);
                      },
                    ),
                    const Text(
                      '로그인 기억하기',
                      style: TextStyle(
                        color: _textGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        '비밀번호 찾기',
                        style: TextStyle(color: _textGrey),
                      ),
                    ),
                    const Text('|', style: TextStyle(color: _textGrey)),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        '이메일 회원가입',
                        style: TextStyle(color: _textGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}