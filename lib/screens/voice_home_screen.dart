import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../const/colors.dart';

class VoiceHomeScreen extends StatefulWidget {
  final VoidCallback? onSwitchToChat;

  const VoiceHomeScreen({super.key, this.onSwitchToChat});

  @override
  State<VoiceHomeScreen> createState() => _VoiceHomeScreenState();
}

class _VoiceHomeScreenState extends State<VoiceHomeScreen>
    with TickerProviderStateMixin {
  // ── Speech / TTS ──
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _recognizedText = '';

  // ── Word-by-word reveal ──
  String _fullResponseText = '';
  List<String> _responseWords = [];
  int _displayedWordCount = 0;

  // ── Mouth animation frames ──
  static const List<String> _mouthFrames = [
    'assets/images/lisa_avatar.png',          // 0: closed
    'assets/images/lisa_mouth_slight.png',    // 1: slightly open
    'assets/images/lisa_mouth_medium.png',    // 2: medium open
    'assets/images/lisa_avatar_speaking.png', // 3: open
    'assets/images/lisa_mouth_wide.png',      // 4: wide open
  ];
  int _currentMouthFrame = 0;
  Timer? _mouthTimer;

  // ── Call state ──
  bool _inCall = false;
  int _callDurationSeconds = 0;
  Timer? _callTimer;

  // ── Proactive greetings ──
  static const List<String> _greetings = [
    "How are you feeling today?",
    "Can I help you with anything?",
    "Did you feel unwell today?",
    "Need any health tips?",
    "Is there something bothering you?",
  ];
  int _currentGreetingIndex = 0;
  Timer? _greetingTimer;

  // ── Animations ──
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _speakBounceController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Fast bounce for speaking state
    _speakBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _initSpeech();
    _initTts();
    _startGreetingCycle();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (error) {
        debugPrint('Speech error: ${error.errorMsg}');
        if (mounted) setState(() => _isListening = false);
        _waveController.stop();
        // Auto-listen again if still in call
        if (_inCall && mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_inCall && mounted && !_isSpeaking) _startListening();
          });
        }
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() => _isListening = false);
            _waveController.stop();
            if (_recognizedText.isNotEmpty) {
              _processUserInput(_recognizedText);
            } else if (_inCall && !_isSpeaking) {
              // Re-listen if call is still active and nothing was said
              Future.delayed(const Duration(milliseconds: 800), () {
                if (_inCall && mounted && !_isSpeaking) _startListening();
              });
            }
          }
        }
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    _tts.setStartHandler(() {
      if (mounted) {
        setState(() => _isSpeaking = true);
        _speakBounceController.repeat(reverse: true);
        _startMouthCycling();
      }
    });
    _tts.setCompletionHandler(() {
      if (mounted) {
        _stopMouthCycling();
        setState(() {
          _isSpeaking = false;
          _currentMouthFrame = 0;
          // Show all words when done
          _displayedWordCount = _responseWords.length;
        });
        _speakBounceController.stop();
        _speakBounceController.reset();
        // Auto-listen after Lisa finishes speaking
        if (_inCall) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_inCall && mounted && !_isSpeaking) _startListening();
          });
        }
      }
    });
    _tts.setErrorHandler((msg) {
      if (mounted) {
        _stopMouthCycling();
        setState(() {
          _isSpeaking = false;
          _currentMouthFrame = 0;
        });
        _speakBounceController.stop();
        _speakBounceController.reset();
      }
    });

    // Progress handler: fires for each word as it's spoken
    _tts.setProgressHandler(
        (String text, int start, int end, String word) {
      if (!mounted || _fullResponseText.isEmpty) return;
      // Count how many words have been spoken so far
      final spokenSoFar = _fullResponseText.substring(0, end).trim();
      final wordCount = spokenSoFar.split(RegExp(r'\s+')).length;
      setState(() {
        _displayedWordCount = wordCount.clamp(0, _responseWords.length);
      });
    });
  }

  // ── Mouth cycling for realistic talking ──

  void _startMouthCycling() {
    _mouthTimer?.cancel();
    final rng = Random();
    // Cycle through mouth frames every 100ms with randomized selection
    _mouthTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || !_isSpeaking) {
        timer.cancel();
        return;
      }
      // Natural pattern: mostly alternate between open positions,
      // occasionally return to closed for natural pauses
      final roll = rng.nextDouble();
      int nextFrame;
      if (roll < 0.1) {
        nextFrame = 0; // closed (brief pause, 10%)
      } else if (roll < 0.3) {
        nextFrame = 1; // slight (20%)
      } else if (roll < 0.55) {
        nextFrame = 2; // medium (25%)
      } else if (roll < 0.8) {
        nextFrame = 3; // open (25%)
      } else {
        nextFrame = 4; // wide (20%)
      }
      setState(() => _currentMouthFrame = nextFrame);
    });
  }

  void _stopMouthCycling() {
    _mouthTimer?.cancel();
    _mouthTimer = null;
  }

  void _startGreetingCycle() {
    _greetingTimer?.cancel();
    _greetingTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!_inCall && mounted) {
        setState(() {
          _currentGreetingIndex =
              (_currentGreetingIndex + 1) % _greetings.length;
        });
      }
    });
  }

  // ── Call actions ──

  void _startCall() {
    _greetingTimer?.cancel();

    setState(() {
      _inCall = true;
      _callDurationSeconds = 0;
      _recognizedText = '';
    });

    // Start call timer
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _callDurationSeconds++);
    });

    // Lisa greets on call start
    const greeting =
        "Hi! I'm Lisa, your health assistant. How are you feeling today?";
    final words = greeting.split(' ');
    setState(() {
      _fullResponseText = greeting;
      _responseWords = words;
      _displayedWordCount = 0;
    });

    _tts.speak(greeting);
  }

  void _endCall() {
    _callTimer?.cancel();
    _stopMouthCycling();
    _speech.stop();
    _tts.stop();
    _waveController.stop();
    _speakBounceController.stop();
    _speakBounceController.reset();

    setState(() {
      _inCall = false;
      _isListening = false;
      _isSpeaking = false;
      _recognizedText = '';
      _fullResponseText = '';
      _responseWords = [];
      _displayedWordCount = 0;
      _currentMouthFrame = 0;
      _callDurationSeconds = 0;
    });

    _startGreetingCycle();
  }

  void _startListening() async {
    if (!_speechAvailable || !_inCall) return;

    setState(() {
      _isListening = true;
      _recognizedText = '';
    });
    _waveController.repeat();

    await _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() => _recognizedText = result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
      ),
    );
  }

  void _processUserInput(String text) {
    final response = _getAIResponse(text);
    final words = response.split(' ');

    setState(() {
      _fullResponseText = response;
      _responseWords = words;
      _displayedWordCount = 0;
    });

    _tts.speak(response);
  }

  // ── Emergency keywords ──
  static const List<String> _emergencyKeywords = [
    "can't breathe", "cannot breathe", "chest pain", "severe chest pain",
    "fainted", "fainting", "heavy bleeding", "heart attack",
    "stroke", "unconscious", "not breathing", "difficulty breathing",
  ];

  bool _checkEmergency(String text) {
    final lower = text.toLowerCase();
    return _emergencyKeywords.any((keyword) => lower.contains(keyword));
  }

  String _getAIResponse(String query) {
    if (_checkEmergency(query)) {
      return "This may be a medical emergency. Please call 112 or visit the nearest hospital immediately. I am an AI and cannot provide emergency medical care.";
    }
    final lower = query.toLowerCase();
    if (lower.contains('headache') || lower.contains('head pain')) {
      return "Headaches can have many causes. Stay hydrated, rest in a quiet dark room, and try gentle relaxation. If it's severe or sudden, please consult a doctor immediately.";
    } else if (lower.contains('fever') || lower.contains('temperature')) {
      return "Fever usually means your body is fighting an infection. Drink plenty of fluids and rest. If it's above 103°F or lasts more than 3 days, see a doctor.";
    } else if (lower.contains('cold') || lower.contains('cough')) {
      return "Common cold and cough are usually viral. Warm fluids, honey, and rest can help. If symptoms persist beyond a week, please see a doctor.";
    } else if (lower.contains('good') ||
        lower.contains('fine') ||
        lower.contains('great') ||
        lower.contains('okay')) {
      return "That's wonderful to hear! Remember to stay hydrated and get enough sleep. I'm here whenever you need health guidance.";
    } else if (lower.contains('stomach') || lower.contains('nausea')) {
      return "Stomach discomfort can have many causes. Try sipping water slowly, eat bland foods, and rest. If pain is severe or persistent, please consult a healthcare professional.";
    } else if (lower.contains('tired') || lower.contains('fatigue')) {
      return "Feeling tired can be caused by many things. Make sure you're getting 7-9 hours of sleep and staying active. If fatigue persists, consider seeing a doctor.";
    } else if (lower.contains('hello') ||
        lower.contains('hi') ||
        lower.contains('hey')) {
      return "Hello! I'm Lisa, your health assistant. Tell me how you're feeling, or ask me any health-related question.";
    } else {
      return "Thank you for sharing. While I can provide general health information, I recommend consulting a registered doctor for personalized advice. Is there anything specific I can help you understand?";
    }
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _speakBounceController.dispose();
    _callTimer?.cancel();
    _greetingTimer?.cancel();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _inCall ? _buildCallScreen() : _buildIdleScreen(),
    );
  }

  // ═══════════════════════════════════════════════
  // ── IDLE SCREEN (before calling) ──
  // ═══════════════════════════════════════════════
  Widget _buildIdleScreen() {
    return Container(
      key: const ValueKey('idle'),
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
            // Top bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AskLisa',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: textWhite,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Your AI Health Assistant',
                        style: TextStyle(fontSize: 12, color: textMuted),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: emergencyRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: emergencyRed.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.emergency_rounded,
                        color: emergencyRed,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Lisa avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryTeal.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/lisa_avatar.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  const Text(
                    'Lisa',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: textWhite,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: successGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: successGreen.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Available',
                        style: TextStyle(
                          fontSize: 14,
                          color: successGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                  const SizedBox(height: 28),

                  // Proactive greeting text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: Text(
                        _greetings[_currentGreetingIndex],
                        key: ValueKey('g_$_currentGreetingIndex'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: textGrey,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Call button ──
                  GestureDetector(
                    onTap: _startCall,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        final glow = 0.15 + _pulseController.value * 0.15;
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [successGreen, Color(0xFF00C853)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    successGreen.withValues(alpha: glow),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.call_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        );
                      },
                    ),
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  const Text(
                    'Tap to call Lisa',
                    style: TextStyle(
                      fontSize: 14,
                      color: textMuted,
                      letterSpacing: 0.3,
                    ),
                  ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

                  const Spacer(flex: 1),

                  // Chat button
                  _buildChatButton(),

                  const SizedBox(height: 14),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'AskLisa provides general health info. Always consult a doctor.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11, color: textMuted, height: 1.3),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // ── ACTIVE CALL SCREEN ──
  // ═══════════════════════════════════════════════
  Widget _buildCallScreen() {
    return Container(
      key: const ValueKey('call'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A1628),
            Color(0xFF0D1B2A),
            Color(0xFF0A0E21),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Call duration
            Text(
              _formatDuration(_callDurationSeconds),
              style: const TextStyle(
                fontSize: 16,
                color: textMuted,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
              ),
            ),

            const Spacer(flex: 2),

            // Lisa avatar with animated rings
            _buildCallAvatar(),

            const SizedBox(height: 28),

            const Text(
              'Lisa',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: textWhite,
              ),
            ),

            const SizedBox(height: 8),

            // Status indicator
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _isSpeaking
                    ? '🔊 Speaking...'
                    : _isListening
                        ? '🎧 Listening...'
                        : 'Connected',
                key: ValueKey('$_isSpeaking-$_isListening'),
                style: TextStyle(
                  fontSize: 14,
                  color: _isSpeaking
                      ? accentCyan
                      : _isListening
                          ? successGreen
                          : textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Lisa's response / user's speech
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _buildCallText(),
              ),
            ),

            const Spacer(flex: 3),

            // Bottom call controls
            _buildCallControls(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCallAvatar() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _speakBounceController]),
      builder: (context, _) {
        final ringColor = _isSpeaking ? accentCyan : primaryTeal;

        // Ring scale: more dramatic during speaking
        final double ringScale;
        if (_isSpeaking) {
          ringScale = 1.15 + _speakBounceController.value * 0.2;
        } else if (_isListening) {
          ringScale = 1.1 + _pulseController.value * 0.1;
        } else {
          ringScale = 1.0 + _pulseController.value * 0.05;
        }

        // Avatar bounce: scales orb up/down while speaking
        final double avatarScale;
        if (_isSpeaking) {
          avatarScale = 1.0 + _speakBounceController.value * 0.12;
        } else {
          avatarScale = 1.0;
        }

        // Glow intensity
        final double glowBlur = _isSpeaking ? 40 : 24;
        final double glowAlpha = _isSpeaking
            ? 0.35 + _speakBounceController.value * 0.25
            : 0.3;

        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Sound wave rings (3 rings, staggered) — visible when speaking
              if (_isSpeaking)
                ..._buildSoundWaves(ringColor),

              // Outer ring
              Container(
                width: 180 * ringScale,
                height: 180 * ringScale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ringColor.withValues(
                        alpha: _isSpeaking ? 0.25 : 0.15),
                    width: _isSpeaking ? 2.5 : 2,
                  ),
                ),
              ),
              // Middle ring
              Container(
                width: 145 * ringScale,
                height: 145 * ringScale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ringColor.withValues(
                        alpha: _isSpeaking ? 0.35 : 0.25),
                    width: _isSpeaking ? 2.5 : 2,
                  ),
                ),
              ),
              // Inner glow ring (only when speaking)
              if (_isSpeaking)
                Container(
                  width: 115 * avatarScale,
                  height: 115 * avatarScale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ringColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                ),
              // Avatar orb
              Transform.scale(
                scale: avatarScale,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ringColor.withValues(alpha: glowAlpha),
                        blurRadius: glowBlur,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      _isSpeaking
                          ? _mouthFrames[_currentMouthFrame]
                          : _mouthFrames[0],
                      key: ValueKey('mouth_${_currentMouthFrame}_$_isSpeaking'),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildSoundWaves(Color color) {
    return List.generate(3, (i) {
      return AnimatedBuilder(
        animation: _speakBounceController,
        builder: (context, _) {
          final delay = i * 0.25;
          final progress = (_speakBounceController.value + delay) % 1.0;
          final waveScale = 1.2 + progress * 0.6;
          final waveAlpha = (1.0 - progress) * 0.2;

          return Transform.scale(
            scale: waveScale,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: max(0, waveAlpha)),
                  width: 1.5,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildCallText() {
    if (_isListening && _recognizedText.isNotEmpty) {
      return Text(
        _recognizedText,
        key: const ValueKey('recognized'),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          color: accentCyan,
          height: 1.5,
          fontStyle: FontStyle.italic,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    }
    if (_responseWords.isNotEmpty && _displayedWordCount > 0) {
      // Word-by-word subtitle display
      final visibleWords = _responseWords
          .take(_displayedWordCount)
          .join(' ');
      return Text(
        visibleWords,
        key: ValueKey('words_$_displayedWordCount'),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          color: textWhite,
          height: 1.5,
        ),
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
      );
    }
    if (_isListening) {
      return const Text(
        'Listening...',
        key: ValueKey('listening'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: textMuted,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    return const SizedBox.shrink(key: ValueKey('empty'));
  }

  Widget _buildCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Chat button (in-call)
        _callControlButton(
          icon: Icons.chat_rounded,
          label: 'Chat',
          color: cardDark,
          iconColor: textGrey,
          onTap: () {
            _endCall();
            widget.onSwitchToChat?.call();
          },
        ),

        // End call button
        GestureDetector(
          onTap: _endCall,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [emergencyRed, emergencyRedLight],
              ),
              boxShadow: [
                BoxShadow(
                  color: emergencyRed.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.call_end_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),

        // Mute / unmute (decorative for now)
        _callControlButton(
          icon: Icons.volume_up_rounded,
          label: 'Speaker',
          color: primaryTeal.withValues(alpha: 0.15),
          iconColor: primaryTeal,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _callControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: borderDark),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: textMuted),
          ),
        ],
      ),
    );
  }

  // ── Chat switch button (idle screen) ──
  Widget _buildChatButton() {
    return GestureDetector(
      onTap: widget.onSwitchToChat,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderDark),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_rounded, color: textMuted, size: 20),
            SizedBox(width: 10),
            Text(
              'Chat instead',
              style: TextStyle(
                fontSize: 14,
                color: textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 700.ms, duration: 400.ms);
  }
}
