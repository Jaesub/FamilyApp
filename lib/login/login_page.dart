import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class LoginPage extends StatefulWidget {
  final AuthService auth;
  // final VoidCallback onLoggedIn;

  const LoginPage({super.key, required this.auth});//, required this.onLoggedIn});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtr = TextEditingController();
  final _pwCtr = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtr.dispose();
    _pwCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      // await widget.auth.login(email: _emailCtr.text.trim(), password: _pwCtr.text);
      // widget.onLoggedIn();
      /// 로그인 수행 → AuthService가 User 반환
      final User user = await widget.auth.login(
        email: _emailCtr.text.trim(),
        password: _pwCtr.text,
      );
      /// 로그인 성공 → 현재 페이지 pop 하면서 User 반환
      if (!mounted) return;
      // Navigator.of(context).pop<User>(user); // 성공 시 User 반환
      Navigator.pop(context, user);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('로그인', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtr,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: '이메일',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return '이메일을 입력하세요.';
                        // if (!v.contains('@')) return '올바른 이메일을 입력하세요.';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return '올바른 이메일을 입력하세요.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pwCtr,
                      obscureText: _obscure,
                      keyboardType: TextInputType.visiblePassword,
                      enableSuggestions: false,
                      autocorrect: false,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return '비밀번호를 입력하세요.';
                        if (v.length < 4) return '4자 이상 입력하세요.';
                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _submit,
                        icon: _loading
                            ? const SizedBox(
                            width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.login),
                        label: Text(_loading ? '로그인 중...' : '로그인'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
