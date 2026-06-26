import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
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
        builder: (context) => Scaffold(
          body: Center(
            child: Text(
              'स्वागत है! (Welcome)',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Strict white background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Heading without heavy dividers
                const Text(
                  'लॉगिन करें',
                  style: TextStyle(
                    color: Color(0xFF0F172A), // Slate 900
                    fontSize: 32.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'मारू प्रजापत समुदाय में आपका स्वागत है',
                  style: TextStyle(
                    color: Color(0xFF64748B), // Slate 500
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 48),

                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2), // Red 50
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFEF4444), // Red 500
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Input fields
                CustomTextField(
                  controller: _emailController,
                  labelText: 'ईमेल पता (Email)',
                  hintText: 'example@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
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
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'पासवर्ड (Password)',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
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

                const SizedBox(height: 24),

                // Login action button
                CustomButton(
                  text: 'प्रवेश करें (Login)',
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 24),

                // Minimalist visual separator without heavy line lines
                const Center(
                  child: Text(
                    'अथवा (Or)',
                    style: TextStyle(
                      color: Color(0xFF94A3B8), // Slate 400
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Google Sign In button (Premium flat white button, no heavy cards)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
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
                                Color(0xFF6366F1),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Google symbol fallback icon
                              Icon(
                                Icons.g_mobiledata,
                                size: 30,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'गूगल से लॉगिन करें (Google Sign In)',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Anonymous browse action button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    onPressed: _isAnonLoading ? null : _handleAnonymousSignIn,
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      foregroundColor: const Color(0xFF64748B),
                    ),
                    child: _isAnonLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF6366F1),
                              ),
                            ),
                          )
                        : const Text(
                            'अतिथि के रूप में ब्राउज़ करें (Browse as Guest)',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),

                // Routing to Signup screen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'नया खाता बनाना है? ',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14.0,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'रजिस्टर करें (Sign Up)',
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
