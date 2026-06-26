import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../config/theme_config.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await AuthService().signOut();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('लॉगआउट विफल: $e'),
          backgroundColor: ThemeConfig.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;
    final userLabel = currentUser?.email ??
        (currentUser?.isAnonymous == true ? 'अतिथि' : 'उपयोगकर्ता');

    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        title: const Text(
          'मारू प्रजापत',
          style: TextStyle(
            color: ThemeConfig.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          _isLoggingOut
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(ThemeConfig.primary),
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.logout,
                      color: ThemeConfig.secondary),
                  tooltip: 'लॉगआउट',
                  onPressed: _handleLogout,
                ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ThemeConfig.primary.withValues(alpha: 0.15),
                        blurRadius: 24.0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                        color: ThemeConfig.primaryLight.withValues(alpha: 0.3),
                        width: 2.0),
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.palette_outlined,
                            size: 60,
                            color: ThemeConfig.primary,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Welcome message
                const Text(
                  'स्वागत है!',
                  style: TextStyle(
                    color: ThemeConfig.textPrimary,
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'मारू प्रजापत समुदाय में आपका स्वागत है',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ThemeConfig.textSecondary,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // User label
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: ThemeConfig.primaryLight.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    userLabel,
                    style: const TextStyle(
                      color: ThemeConfig.secondary,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoggingOut ? null : _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF6E7D8),
                      foregroundColor: ThemeConfig.secondary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                    child: const Text(
                      'लॉगआउट करें',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
