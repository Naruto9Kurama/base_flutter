import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/di/injection.dart';
import '../../../core/api/auth/auth_api.dart';
import '../../features/base/models/http/auth/login_request.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authApi = getIt<AuthApi>();
    final response = await authApi.login(LoginRequest(
      username: _usernameController.text,
      password: _passwordController.text,
    ));
    debugPrint("✅ 登录成功: code=${response.code}, data=${response.data}");
    // 模拟网络请求
    // await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // 登录成功后跳转到首页
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('auth.title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'auth.username'.tr()),
                validator: (value) =>
                value!.isEmpty ? 'auth.username_required'.tr() : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'auth.password'.tr()),
                validator: (value) =>
                value!.isEmpty ? 'auth.password_required'.tr() : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('auth.button'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
