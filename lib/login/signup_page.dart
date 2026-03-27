import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/auth_models.dart';

class SignupPage extends StatefulWidget {
  final AuthService auth;

  const SignupPage({super.key, required this.auth});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtr = TextEditingController();
  final _emailCtr = TextEditingController();
  final _pwCtr = TextEditingController();
  final _pwConfirmCtr = TextEditingController();

  bool _obscurePw = true;
  bool _obscurePwConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtr.dispose();
    _emailCtr.dispose();
    _pwCtr.dispose();
    _pwConfirmCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await widget.auth.signup(
        SignupRequest(
          name: _nameCtr.text.trim(),
          email: _emailCtr.text.trim(),
          password: _pwCtr.text,
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final nav = Navigator.of(context);
            if (nav.canPop()) {
              nav.pop();
            }
          },
        ),
      ),
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
                    Text('회원가입', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameCtr,
                      decoration: const InputDecoration(
                        labelText: '이름',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return '이름을 입력하세요.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailCtr,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: '이메일',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return '이메일을 입력하세요.';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                          return '올바른 이메일을 입력하세요.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pwCtr,
                      obscureText: _obscurePw,
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePw ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscurePw = !_obscurePw),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return '비밀번호를 입력하세요.';
                        if (v.length < 8) return '비밀번호는 8자 이상 입력하세요.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pwConfirmCtr,
                      obscureText: _obscurePwConfirm,
                      decoration: InputDecoration(
                        labelText: '비밀번호 확인',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePwConfirm ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePwConfirm = !_obscurePwConfirm),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return '비밀번호 확인을 입력하세요.';
                        if (v != _pwCtr.text) return '비밀번호가 일치하지 않습니다.';
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
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.person_add),
                        label: Text(_loading ? '가입 중...' : '회원가입'),
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