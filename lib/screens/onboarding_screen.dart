import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../const/colors.dart';
import '../widgets/primary_button.dart';
import 'consent_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.smart_toy_rounded,
      title: 'Meet Lisa',
      subtitle: 'Your AI Health Assistant',
      description:
          'Ask health questions, get safe general guidance, and understand your symptoms better — all powered by AI.',
      gradientColors: [primaryTeal, accentCyan],
    ),
    _OnboardingPage(
      icon: Icons.shield_rounded,
      title: 'Your Privacy Matters',
      subtitle: 'DPDP Act Compliant',
      description:
          'Your health data is encrypted, stored securely on Indian servers, and you can delete it anytime. We follow the Digital Personal Data Protection Act.',
      gradientColors: [accentPurple, const Color(0xFF448AFF)],
    ),
    _OnboardingPage(
      icon: Icons.emergency_rounded,
      title: 'Emergency Detection',
      subtitle: 'Safety First, Always',
      description:
          'If we detect an emergency situation, we\'ll immediately guide you to call emergency services. Your safety comes first.',
      gradientColors: [emergencyRed, const Color(0xFFFF6D00)],
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToConsent();
    }
  }

  void _navigateToConsent() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, a1, a2) => const ConsentScreen(),
        transitionsBuilder: (context, anim, a2, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
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
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _navigateToConsent,
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Skip' : '',
                    style: const TextStyle(
                      color: textMuted,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon container
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: page.gradientColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(36),
                              boxShadow: [
                                BoxShadow(
                                  color: page.gradientColors[0]
                                      .withValues(alpha: 0.35),
                                  blurRadius: 40,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Icon(
                              page.icon,
                              size: 56,
                              color: Colors.white,
                            ),
                          )
                              .animate()
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1.0, 1.0),
                                duration: 500.ms,
                                curve: Curves.elasticOut,
                              )
                              .fadeIn(duration: 400.ms),
                          const SizedBox(height: 48),
                          Text(
                            page.title,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: textWhite,
                              letterSpacing: -0.5,
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 400.ms)
                              .slideY(begin: 0.2, end: 0),
                          const SizedBox(height: 10),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: page.gradientColors,
                            ).createShader(bounds),
                            child: Text(
                              page.subtitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 350.ms, duration: 400.ms),
                          const SizedBox(height: 24),
                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: textGrey,
                              height: 1.6,
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 500.ms, duration: 400.ms)
                              .slideY(begin: 0.15, end: 0),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Bottom controls
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                child: Column(
                  children: [
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _pages.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: primaryTeal,
                        dotColor: borderDark,
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 4,
                        spacing: 6,
                      ),
                    ),
                    const SizedBox(height: 36),
                    PrimaryButton(
                      text: _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      icon: _currentPage == _pages.length - 1
                          ? Icons.arrow_forward_rounded
                          : null,
                      onPressed: _nextPage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final List<Color> gradientColors;

  _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.gradientColors,
  });
}
