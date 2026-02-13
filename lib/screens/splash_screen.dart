import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../const/colors.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, a1, a2) => const OnboardingScreen(),
            transitionsBuilder: (context, anim, a2, child) {
              return FadeTransition(opacity: anim, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E21),
              Color(0xFF0D1B2A),
              Color(0xFF0A2233),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background orbs
            Positioned(
              top: -80,
              right: -80,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          primaryTeal.withValues(alpha: 0.15 + _pulseController.value * 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accentCyan.withValues(alpha: 0.1 + _pulseController.value * 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryTeal, accentCyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: primaryTeal.withValues(alpha: 0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 28),
                  // App name
                  const Text(
                    'AskLisa',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: textWhite,
                      letterSpacing: 1.5,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 500.ms)
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 10),
                  // Tagline
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [primaryTeal, accentCyan],
                    ).createShader(bounds),
                    child: const Text(
                      'Your AI Health Assistant',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 500.ms)
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 60),
                  // Loading indicator
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          primaryTeal.withValues(alpha: 0.6)),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 900.ms, duration: 400.ms),
                ],
              ),
            ),
            // Bottom disclaimer
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: const Text(
                'Not a substitute for medical advice',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: textMuted,
                ),
              )
                  .animate()
                  .fadeIn(delay: 1200.ms, duration: 400.ms),
            ),
          ],
        ),
      ),
    );
  }
}
