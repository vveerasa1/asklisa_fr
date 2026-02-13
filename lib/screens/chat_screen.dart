import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../const/colors.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/emergency_banner.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _showEmergency = false;

  // Emergency keywords
  static const List<String> _emergencyKeywords = [
    "can't breathe",
    "cannot breathe",
    "chest pain",
    "severe chest pain",
    "fainted",
    "fainting",
    "heavy bleeding",
    "heart attack",
    "stroke",
    "unconscious",
    "not breathing",
    "difficulty breathing",
  ];

  @override
  void initState() {
    super.initState();
    // AI introduction
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            message:
                "Hello! I'm Lisa, your AI health assistant. 👋\n\n⚕️ Please note: I am NOT a doctor. I can provide general health information and guidance, but I cannot diagnose conditions or prescribe medicines.\n\nHow can I help you today?",
            isUser: false,
            time: _currentTime(),
          ));
        });
      }
    });
  }

  String _currentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  bool _checkEmergency(String text) {
    final lower = text.toLowerCase();
    return _emergencyKeywords.any((keyword) => lower.contains(keyword));
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        message: text,
        isUser: true,
        time: _currentTime(),
      ));
      _messageController.clear();
    });

    _scrollToBottom();

    // Check for emergency
    if (_checkEmergency(text)) {
      setState(() => _showEmergency = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _messages.add(_ChatMessage(
              message:
                  "🚨 This may be a medical emergency.\n\nPlease call local emergency services (112) or visit the nearest hospital immediately.\n\nI am an AI and cannot provide emergency medical care. Your safety is the top priority.",
              isUser: false,
              time: _currentTime(),
            ));
          });
          _scrollToBottom();
        }
      });
      return;
    }

    // Simulate AI response
    setState(() => _isTyping = true);
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(_ChatMessage(
            message: _getAIResponse(text),
            isUser: false,
            time: _currentTime(),
          ));
        });
        _scrollToBottom();
      }
    });
  }

  String _getAIResponse(String query) {
    final lower = query.toLowerCase();
    if (lower.contains('headache') || lower.contains('head pain')) {
      return "Headaches can have many causes. Here are some general tips:\n\n"
          "💧 Stay hydrated — drink water\n"
          "😌 Rest in a quiet, dark room\n"
          "🧘 Try gentle relaxation techniques\n\n"
          "⚠️ If your headache is severe, sudden, or accompanied by vision changes, "
          "please consult a doctor immediately.\n\n"
          "Would you like to tell me more about your symptoms?";
    } else if (lower.contains('fever') || lower.contains('temperature')) {
      return "Fever is often a sign that your body is fighting an infection.\n\n"
          "General self-care tips:\n"
          "💧 Drink plenty of fluids\n"
          "🛌 Get adequate rest\n"
          "🌡️ Monitor your temperature\n\n"
          "⚠️ If your fever is above 103°F (39.4°C) or persists for more than 3 days, "
          "please see a doctor.\n\n"
          "How long have you had the fever?";
    } else if (lower.contains('cold') || lower.contains('cough')) {
      return "Common cold and cough are usually caused by viral infections.\n\n"
          "General wellness tips:\n"
          "🍵 Warm fluids like tea or soup can help\n"
          "🍯 Honey may soothe a sore throat\n"
          "💤 Rest is important for recovery\n"
          "🧼 Wash hands frequently\n\n"
          "⚠️ If symptoms persist beyond a week or you have difficulty breathing, "
          "please consult a healthcare professional.\n\n"
          "Note: I cannot recommend specific medicines. Please see a doctor for prescriptions.";
    } else {
      return "Thank you for sharing. While I can provide general health information, "
          "I want to remind you that I'm not a doctor and cannot diagnose conditions.\n\n"
          "For personalized medical advice, I recommend:\n"
          "👨‍⚕️ Consulting a registered doctor\n"
          "🏥 Visiting a healthcare facility\n\n"
          "Is there anything specific about your health I can help you understand better?";
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryTeal, accentCyan],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lisa AI',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: textWhite,
                          ),
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 4,
                              backgroundColor: successGreen,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Online • Not a doctor',
                              style: TextStyle(
                                fontSize: 12,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: textGrey),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Container(height: 0.5, color: borderDark),
            // Emergency banner
            if (_showEmergency)
              EmergencyBanner(
                onCallEmergency: () {
                  // TODO: Launch phone dialer
                },
                onDismiss: () => setState(() => _showEmergency = false),
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: -0.2, end: 0),
            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return const TypingIndicator();
                  }
                  final msg = _messages[index];
                  return ChatBubble(
                    message: msg.message,
                    isUser: msg.isUser,
                    time: msg.time,
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.1, end: 0);
                },
              ),
            ),
            // Input area
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              decoration: BoxDecoration(
                color: surfaceDark,
                border: Border(
                  top: BorderSide(color: borderDark.withValues(alpha: 0.5)),
                ),
              ),
              child: Row(
                children: [
                  // Voice button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderDark),
                    ),
                    child: const Icon(
                      Icons.mic_outlined,
                      color: textMuted,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Text input
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: cardDark,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderDark),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(
                          color: textWhite,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Ask Lisa about your health...',
                          hintStyle: TextStyle(
                            color: textMuted,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Send button
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryTeal, accentCyan],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: primaryTeal.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String message;
  final bool isUser;
  final String time;

  _ChatMessage({
    required this.message,
    required this.isUser,
    required this.time,
  });
}
