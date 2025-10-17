import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    // Auto-continue to login/home after short delay
    Future<void>.delayed(const Duration(milliseconds: 1400), () async {
      if (!mounted) return;
      final bool loggedIn = await AuthService().isLoggedIn();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(loggedIn ? '/home' : '/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5A5FAF), // darker variant of primary for splash
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            final bool loggedIn = await AuthService().isLoggedIn();
            if (!mounted) return;
            Navigator.of(context).pushReplacementNamed(loggedIn ? '/home' : '/login');
          },
          child: SizedBox.expand(
            child: Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDFF7A1), width: 3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'MONAS',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDFF7A1),
                      letterSpacing: 2,
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

