import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../config/theme_config.dart';
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

      // Registration successful -> Show verification notice
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('पंजीकरण सफल! कृपया अपना ईमेल सत्यापित करें।'),
          backgroundColor: ThemeConfig.success,
        ),
      );

      // Redirect back to login
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
      backgroundColor: ThemeConfig.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ThemeConfig.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background decorative faint circles (Matching Mockup)
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeConfig.primaryLight.withValues(alpha: 0.1),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header title
                      const Text(
                        'खाता बनाएं',
                        style: TextStyle(
                          color: ThemeConfig.primary,
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Subtitle
                      const Text(
                        'समुदाय का हिस्सा बनने के लिए रजिस्टर करें',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ThemeConfig.textPrimary,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 36),

                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: ThemeConfig.error,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Input fields (No prefix icons, styled like the mockup)
                      CustomTextField(
                        controller: _nameController,
                        labelText: 'पूरा नाम',
                        hintText: 'अपना पूरा नाम दर्ज करें',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'कृपया अपना पूरा नाम दर्ज करें';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      CustomTextField(
                        controller: _emailController,
                        labelText: 'ईमेल',
                        hintText: 'ईमेल पता दर्ज करें',
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
                      const SizedBox(height: 8),

                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'पासवर्ड',
                        hintText: 'कम से कम 6 अक्षर का पासवर्ड',
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
                      const SizedBox(height: 8),

                      CustomTextField(
                        controller: _confirmPasswordController,
                        labelText: 'पासवर्ड की पुष्टि करें',
                        hintText: 'पासवर्ड दोबारा दर्ज करें',
                        isPassword: true,
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

                      const SizedBox(height: 32),

                      // Solid Primary Sign Up Button
                      CustomButton(
                        text: 'रजिस्टर करें',
                        onPressed: _handleSignup,
                        isLoading: _isLoading,
                        backgroundColor: ThemeConfig.primary,
                      ),

                      const SizedBox(height: 24),

                      // Already have an account link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'पहले से खाता है? ',
                            style: TextStyle(
                              color: ThemeConfig.textSecondary,
                              fontSize: 14.0,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Text(
                              'लॉगिन करें',
                              style: TextStyle(
                                color: ThemeConfig.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
