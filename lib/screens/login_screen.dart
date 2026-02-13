import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../const/colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Basic validation
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      _showError('Please enter a valid email address');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);

    // Simulate login
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: emergencyRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [scaffoldDark, Color(0xFF0D1B2A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                // Welcome
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 16,
                    color: textGrey,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: 6),
                const Text(
                  'AskLisa',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: textWhite,
                    letterSpacing: 0.5,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [primaryTeal, accentCyan],
                  ).createShader(bounds),
                  child: const Text(
                    'Your AI Health Assistant',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms),
                const SizedBox(height: 50),

                // Email label
                const Text(
                  'Email Address',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textGrey,
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                const SizedBox(height: 12),
                // Email input
                CustomTextField(
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                const SizedBox(height: 24),

                // Password label
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textGrey,
                  ),
                ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                const SizedBox(height: 12),
                // Password input
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderDark),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(
                      color: textWhite,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: const TextStyle(
                        color: textMuted,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: textMuted,
                        size: 22,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: textMuted,
                          size: 22,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _login(),
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 400.ms),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: GestureDetector(
                      onTap: () {
                        _showError('Forgot password feature coming soon');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 13,
                          color: primaryTeal.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 900.ms, duration: 400.ms),

                const SizedBox(height: 36),
                PrimaryButton(
                  text: 'Login',
                  icon: Icons.login_rounded,
                  onPressed: _login,
                  isLoading: _isLoading,
                )
                    .animate()
                    .fadeIn(delay: 1000.ms, duration: 400.ms),
                const Spacer(),
                // Terms footer
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          color: textMuted,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                              text: 'By continuing, you agree to our '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: primaryTeal.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: primaryTeal.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1200.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
