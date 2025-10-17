import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loading = false;

  Future<void> _doLogin() async {
    setState(() => _loading = true);
    await AuthService().login(_name.text.trim().isEmpty ? 'User' : _name.text.trim());
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 32),
              Text('Selamat datang', style: Theme.of(context).textTheme.headlineSmall),
              Text('Masuk untuk melanjutkan', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              TextField(decoration: const InputDecoration(labelText: 'Nama'), controller: _name),
              const SizedBox(height: 12),
              TextField(decoration: const InputDecoration(labelText: 'Password'), controller: _password, obscureText: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _doLogin,
                  child: Text(_loading ? 'Memproses...' : 'Masuk'),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('Belum punya akun?'),
                  TextButton(onPressed: () => Navigator.of(context).pushNamed('/register'), child: const Text('Daftar')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loading = false;

  Future<void> _doRegister() async {
    setState(() => _loading = true);
    await AuthService().login(_name.text.trim().isEmpty ? 'User' : _name.text.trim());
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 32),
              Text('Buat akun', style: Theme.of(context).textTheme.headlineSmall),
              Text('Registrasi untuk mulai', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              TextField(decoration: const InputDecoration(labelText: 'Nama'), controller: _name),
              const SizedBox(height: 12),
              TextField(decoration: const InputDecoration(labelText: 'Password'), controller: _password, obscureText: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _doRegister,
                  child: Text(_loading ? 'Memproses...' : 'Daftar'),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('Sudah punya akun?'),
                  TextButton(onPressed: () => Navigator.of(context).pushReplacementNamed('/login'), child: const Text('Masuk')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}




