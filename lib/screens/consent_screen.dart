import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../const/colors.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _consentGiven = false;
  bool _disclaimerAccepted = false;

  bool get _canProceed => _consentGiven && _disclaimerAccepted;

  void _proceed() {
    if (!_canProceed) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: accentPurple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Privacy & Consent',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textWhite,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
                const SizedBox(height: 28),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Disclaimer card
                        _InfoCard(
                          icon: Icons.info_outline_rounded,
                          iconColor: accentCyan,
                          title: 'Important Disclaimer',
                          content:
                              'AskLisa is an AI health assistant and is NOT a doctor. It cannot diagnose conditions, prescribe medicines, or replace professional medical advice. Always consult a registered medical practitioner for health decisions.',
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 400.ms)
                            .slideY(begin: 0.1, end: 0),
                        const SizedBox(height: 16),
                        // DPDP card
                        _InfoCard(
                          icon: Icons.lock_outline_rounded,
                          iconColor: primaryTeal,
                          title: 'Data Collection (DPDP Act 2023)',
                          content:
                              'We collect the following data to provide health guidance:\n\n'
                              '• Basic profile information (name, age, gender)\n'
                              '• Health queries and conversation history\n'
                              '• Symptom descriptions you share\n\n'
                              'Your data is:\n'
                              '✓ Encrypted end-to-end\n'
                              '✓ Stored on Indian servers\n'
                              '✓ Never sold to third parties\n'
                              '✓ Deletable at any time from your profile',
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 400.ms)
                            .slideY(begin: 0.1, end: 0),
                        const SizedBox(height: 16),
                        // Emergency card
                        _InfoCard(
                          icon: Icons.emergency_rounded,
                          iconColor: emergencyRed,
                          title: 'Emergency Situations',
                          content:
                              'If the AI detects potential emergencies (chest pain, difficulty breathing, fainting, heavy bleeding), it will immediately advise you to call emergency services (112) or visit the nearest hospital.',
                        )
                            .animate()
                            .fadeIn(delay: 600.ms, duration: 400.ms)
                            .slideY(begin: 0.1, end: 0),
                        const SizedBox(height: 28),
                        // Consent checkboxes
                        _ConsentCheckbox(
                          value: _disclaimerAccepted,
                          onChanged: (v) =>
                              setState(() => _disclaimerAccepted = v ?? false),
                          label:
                              'I understand that AskLisa is not a substitute for professional medical advice, diagnosis, or treatment.',
                        )
                            .animate()
                            .fadeIn(delay: 800.ms, duration: 400.ms),
                        const SizedBox(height: 14),
                        _ConsentCheckbox(
                          value: _consentGiven,
                          onChanged: (v) =>
                              setState(() => _consentGiven = v ?? false),
                          label:
                              'I consent to the collection and processing of my health data as described above, in accordance with the DPDP Act 2023.',
                        )
                            .animate()
                            .fadeIn(delay: 1000.ms, duration: 400.ms),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                // Bottom button
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PrimaryButton(
                    text: 'I Agree & Continue',
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: _proceed,
                    enabled: _canProceed,
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13.5,
              color: textGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;

  const _ConsentCheckbox({
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value
              ? primaryTeal.withValues(alpha: 0.08)
              : cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value ? primaryTeal.withValues(alpha: 0.4) : borderDark,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? primaryTeal : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: value ? primaryTeal : textMuted,
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  color: value ? textWhite : textGrey,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
