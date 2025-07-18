import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../user_provider.dart';
import '../theme/app_theme.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _checkSignIn();
  }

  Future<void> _checkSignIn() async {
    try {
      print('Splash: Checking sign-in...');
      await Future.delayed(const Duration(seconds: 2));
      final googleSignIn = GoogleSignIn();
      final isSignedIn = await googleSignIn.isSignedIn();
      print('Splash: isSignedIn = $isSignedIn');
      if (isSignedIn) {
        final user = googleSignIn.currentUser ?? await googleSignIn.signInSilently();
        print('Splash: user = $user');
        if (user != null) {
          userNotifier.value = user;
          if (mounted) Navigator.of(context).pushReplacementNamed('/main_nav');
          return;
        }
      }
      if (mounted) Navigator.of(context).pushReplacementNamed('/google_login');
    } catch (e, st) {
      print('Splash error: $e\n$st');
      setState(() => _error = 'Failed to check sign-in: $e');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.of(context).pushReplacementNamed('/google_login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _fadeAnim,
              builder: (context, child) => Opacity(
                opacity: _fadeAnim.value,
                child: child,
              ),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.accent, AppTheme.accent2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withOpacity(0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.train,
                    color: Colors.black,
                    size: 54,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: _fadeAnim,
              child: Text(
                'MyRail Lite',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 36,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: AppTheme.accent.withOpacity(0.18),
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fadeAnim,
              child: const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  color: AppTheme.accent,
                  strokeWidth: 3.2,
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 24),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ],
          ],
        ),
      ),
    );
  }
} 