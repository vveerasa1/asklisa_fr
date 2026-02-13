import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../const/colors.dart';
import '../widgets/primary_button.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  int _resendSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _resendSeconds = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-verify when all 6 digits entered
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      _verifyOtp();
    }
  }

  void _verifyOtp() {
    setState(() => _isLoading = true);
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

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
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
                const SizedBox(height: 16),
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cardDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderDark),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: textWhite,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Title
                const Text(
                  'Verify OTP',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: textWhite,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: 10),
                Text(
                  'Enter the 6-digit code sent to\n+91 ${widget.phoneNumber}',
                  style: const TextStyle(
                    fontSize: 15,
                    color: textGrey,
                    height: 1.4,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: 48),
                // OTP boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      height: 60,
                      child: TextFormField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: textWhite,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          filled: true,
                          fillColor: _controllers[index].text.isNotEmpty
                              ? primaryTeal.withValues(alpha: 0.1)
                              : cardDark,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: _controllers[index].text.isNotEmpty
                                  ? primaryTeal
                                  : borderDark,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: _controllers[index].text.isNotEmpty
                                  ? primaryTeal.withValues(alpha: 0.5)
                                  : borderDark,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: primaryTeal, width: 2),
                          ),
                        ),
                        onChanged: (v) => _onOtpChanged(v, index),
                      ),
                    );
                  }),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms)
                    .slideY(begin: 0.15, end: 0),
                const SizedBox(height: 32),
                // Resend timer
                Center(
                  child: _resendSeconds > 0
                      ? Text(
                          'Resend OTP in ${_resendSeconds}s',
                          style: const TextStyle(
                            fontSize: 14,
                            color: textMuted,
                          ),
                        )
                      : GestureDetector(
                          onTap: _startTimer,
                          child: const Text(
                            'Resend OTP',
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryTeal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 400.ms),
                const SizedBox(height: 40),
                PrimaryButton(
                  text: 'Verify',
                  icon: Icons.verified_outlined,
                  onPressed: _verifyOtp,
                  isLoading: _isLoading,
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
