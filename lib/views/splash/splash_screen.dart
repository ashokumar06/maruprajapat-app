import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Fade-in animation triggers after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(milliseconds: 1000), _checkAuthAndNavigate);
  }

  void _checkAuthAndNavigate() {
    if (!mounted) return;

    final user = AuthService().currentUser;
    if (user != null) {
      // If user is authenticated, route to Home (Dashboard)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // If not authenticated, route to LoginScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      body: SafeArea(
        child: Center(
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeIn,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.palette_outlined,
                      size: 100,
                      color: ThemeConfig.primary,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
