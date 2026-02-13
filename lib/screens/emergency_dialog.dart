import 'package:flutter/material.dart';
import '../const/colors.dart';
import '../widgets/primary_button.dart';

class EmergencyDialog extends StatelessWidget {
  const EmergencyDialog({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Emergency',
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, a1, a2) => const EmergencyDialog(),
      transitionBuilder: (context, anim, a2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2D0A0A),
                Color(0xFF1A0505),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: emergencyRed.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: emergencyRed.withValues(alpha: 0.25),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [emergencyRed, emergencyRedLight],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: emergencyRed.withValues(alpha: 0.5),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emergency_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '🚨 Medical Emergency',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'This may be a medical emergency. Please call local emergency services or visit the nearest hospital immediately.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: textGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'AI cannot provide emergency medical care.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 28),
              // Call Emergency
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [emergencyRed, emergencyRedLight],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: emergencyRed.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Call 112 Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Find Hospital
              SecondaryButton(
                text: 'Find Nearest Hospital',
                icon: Icons.local_hospital_outlined,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 14),
              // Dismiss
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'I am safe, dismiss',
                  style: TextStyle(
                    fontSize: 14,
                    color: textMuted,
                    decoration: TextDecoration.underline,
                    decorationColor: textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
