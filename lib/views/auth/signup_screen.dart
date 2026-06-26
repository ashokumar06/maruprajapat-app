import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Handle Signup Action
  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService().signUpWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Registration successful -> Show verification notice dialogues/alerts
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'पंजीकरण सफल! कृपया अपना ईमेल सत्यापित करें। (Registration Successful! Please verify your email.)',
          ),
          backgroundColor: Color(0xFF10B981), // Emerald 500
        ),
      );

      // Redirect back to login so they can verify email and login
      Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Strict white background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'खाता बनाएं',
                  style: TextStyle(
                    color: Color(0xFF0F172A), // Slate 900
                    fontSize: 32.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'समुदाय का हिस्सा बनने के लिए रजिस्टर करें',
                  style: TextStyle(
                    color: Color(0xFF64748B), // Slate 500
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 36),

                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Input fields
                CustomTextField(
                  controller: _nameController,
                  labelText: 'पूरा नाम (Full Name)',
                  hintText: 'अशोक प्रजापत',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'कृपया अपना पूरा नाम दर्ज करें';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'ईमेल पता (Email Address)',
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
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'पासवर्ड की पुष्टि करें (Confirm Password)',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'कृपया पासवर्ड दोबारा दर्ज करें';
                    }
                    if (value != _passwordController.text) {
                      return 'पासवर्ड मेल नहीं खाते हैं';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 36),

                // Register action button
                CustomButton(
                  text: 'रजिस्टर करें (Sign Up)',
                  onPressed: _handleSignup,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 32),

                // Navigation back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'पहले से खाता है? ',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14.0,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Text(
                        'लॉगिन करें (Login)',
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
