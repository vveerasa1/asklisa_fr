import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../const/colors.dart';
import '../widgets/primary_button.dart';
import 'splash_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [scaffoldDark, Color(0xFF0D1B2A)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Header
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textWhite,
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 28),
              // Avatar & Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderDark),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryTeal, accentCyan],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryTeal.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'User',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '+91 •••••••890',
                      style: TextStyle(
                        fontSize: 14,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 24),
              // Settings section
              _SectionTitle(title: 'Settings'),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Health reminders & alerts',
                    trailing: Switch(
                      value: true,
                      onChanged: (_) {},
                      activeThumbColor: primaryTeal,
                    ),
                  ),
                  const Divider(color: dividerDark, height: 1),
                  _SettingsTile(
                    icon: Icons.language_outlined,
                    title: 'Language',
                    subtitle: 'English',
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: textMuted,
                    ),
                  ),
                  const Divider(color: dividerDark, height: 1),
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Always on',
                    trailing: Switch(
                      value: true,
                      onChanged: (_) {},
                      activeThumbColor: primaryTeal,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 24),
              // DPDP Data Privacy section
              _SectionTitle(title: 'Data & Privacy (DPDP Act)'),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: Icons.visibility_outlined,
                    title: 'View Consent',
                    subtitle: 'Review what you agreed to',
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: textMuted,
                    ),
                  ),
                  const Divider(color: dividerDark, height: 1),
                  _SettingsTile(
                    icon: Icons.download_outlined,
                    title: 'Download My Data',
                    subtitle: 'Get a copy of your data',
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: textMuted,
                    ),
                  ),
                  const Divider(color: dividerDark, height: 1),
                  _SettingsTile(
                    icon: Icons.delete_outline_rounded,
                    title: 'Delete My Data',
                    subtitle: 'Permanently delete all data',
                    iconColor: emergencyRed,
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: emergencyRed,
                    ),
                    onTap: () {
                      _showDeleteDialog(context);
                    },
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 24),
              // About
              _SectionTitle(title: 'About'),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'About AskLisa',
                    subtitle: 'Version 1.0.0',
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: textMuted,
                    ),
                  ),
                  const Divider(color: dividerDark, height: 1),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    subtitle: 'Read our terms',
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: textMuted,
                    ),
                  ),
                  const Divider(color: dividerDark, height: 1),
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'DPDP Act 2023 compliant',
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: textMuted,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 28),
              // Logout
              SecondaryButton(
                text: 'Log Out',
                icon: Icons.logout_rounded,
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                    (route) => false,
                  );
                },
              )
                  .animate()
                  .fadeIn(delay: 900.ms, duration: 400.ms),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: emergencyRed, size: 28),
            SizedBox(width: 12),
            Text(
              'Delete All Data?',
              style: TextStyle(
                color: textWhite,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text(
          'This will permanently delete all your health data, conversation history, and profile information. This action cannot be undone.\n\n'
          'As per DPDP Act 2023, you have the right to request deletion of your personal data.',
          style: TextStyle(
            color: textGrey,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: textMuted, fontSize: 15),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Data deletion request submitted'),
                  backgroundColor: cardDark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: emergencyRed,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textGrey,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderDark),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? primaryTeal).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? primaryTeal,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textWhite,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
