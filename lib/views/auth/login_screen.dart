import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../config/theme_config.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../main/main_shell.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isAnonLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle Email & Password login
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService().signInWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      _navigateToHome();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle Google Sign In
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService().signInWithGoogle();
      _navigateToHome();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
      });
    } finally {
      setState(() {
        _isGoogleLoading = false;
      });
    }
  }

  // Handle Anonymous Sign In (Browse as Guest)
  Future<void> _handleAnonymousSignIn() async {
    setState(() {
      _isAnonLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService().signInAnonymously();
      _navigateToHome();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isAnonLoading = false;
      });
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainShell(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      body: Stack(
        children: [
          // Background decorative circles (warm clay tones)
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeConfig.primaryLight.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeConfig.primary.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeConfig.accent.withValues(alpha: 0.08),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),

                    // App Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                ThemeConfig.primary.withValues(alpha: 0.12),
                            blurRadius: 20.0,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.palette_outlined,
                                size: 50,
                                color: ThemeConfig.primary,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Main Heading
                    const Text(
                      'यहाँ लॉगिन करें',
                      style: TextStyle(
                        color: ThemeConfig.primary,
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    const Text(
                      'मारू प्रजापत समुदाय में आपका स्वागत है',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ThemeConfig.textSecondary,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),

                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: ThemeConfig.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: ThemeConfig.error.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: ThemeConfig.error, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: ThemeConfig.error,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'ईमेल',
                      hintText: 'ईमेल दर्ज करें',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'कृपया ईमेल दर्ज करें';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'कृपया सही ईमेल दर्ज करें';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 4),

                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'पासवर्ड',
                      hintText: 'पासवर्ड दर्ज करें',
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'कृपया पासवर्ड दर्ज करें';
                        }
                        if (value.length < 6) {
                          return 'पासवर्ड कम से कम 6 अक्षरों का होना चाहिए';
                        }
                        return null;
                      },
                    ),

                    // Forgot password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Handle forgot password
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'पासवर्ड भूल गए?',
                          style: TextStyle(
                            color: ThemeConfig.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.0,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Login Button
                    CustomButton(
                      text: 'लॉगिन करें',
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                      backgroundColor: ThemeConfig.primary,
                    ),

                    const SizedBox(height: 20),

                    // Create new account link
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: 'नया खाता बनाना है? ',
                          style: TextStyle(
                            color: ThemeConfig.textSecondary,
                            fontSize: 14.0,
                          ),
                          children: [
                            TextSpan(
                              text: 'रजिस्टर करें',
                              style: TextStyle(
                                color: ThemeConfig.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Divider with "अथवा" (Or)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: ThemeConfig.divider,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'अथवा',
                            style: TextStyle(
                              color: ThemeConfig.textSecondary,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: ThemeConfig.divider,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Google Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed:
                            _isGoogleLoading ? null : _handleGoogleSignIn,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          side: BorderSide(
                              color: ThemeConfig.border.withValues(alpha: 0.6)),
                          backgroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: _isGoogleLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ThemeConfig.primary,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Google "G" logo using proper colors
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CustomPaint(
                                      painter: _GoogleGLogoPainter(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'गूगल से लॉगिन करें',
                                    style: TextStyle(
                                      color: ThemeConfig.textPrimary,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Anonymous Browse Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: TextButton(
                        onPressed:
                            _isAnonLoading ? null : _handleAnonymousSignIn,
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          backgroundColor: ThemeConfig.primaryLight
                              .withValues(alpha: 0.12),
                          foregroundColor: ThemeConfig.secondary,
                        ),
                        child: _isAnonLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ThemeConfig.secondary,
                                  ),
                                ),
                              )
                            : const Text(
                                'अतिथि के रूप में आगे बढ़ें',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Proper Google "G" logo painter with official brand colors
class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = w * 0.45; // outer radius
    final double thickness = w * 0.2;

    final Paint arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.butt;

    final Rect arcRect =
        Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Red arc (top-left quadrant area, roughly from 150° to 225°)
    arcPaint.color = const Color(0xFFEA4335);
    canvas.drawArc(arcRect, -2.35, 1.15, false, arcPaint);

    // Yellow arc (bottom-left)
    arcPaint.color = const Color(0xFFFBBC05);
    canvas.drawArc(arcRect, -3.55, 1.2, false, arcPaint);

    // Green arc (bottom-right)
    arcPaint.color = const Color(0xFF34A853);
    canvas.drawArc(arcRect, -4.85, 1.3, false, arcPaint);

    // Blue arc (top-right, partial)
    arcPaint.color = const Color(0xFF4285F4);
    canvas.drawArc(arcRect, -0.55, 0.5, false, arcPaint);

    // Blue horizontal bar (the "G" bar)
    final Paint barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final double barH = thickness;
    canvas.drawRect(
      Rect.fromLTWH(cx - 1, cy - barH / 2, w * 0.48, barH),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
