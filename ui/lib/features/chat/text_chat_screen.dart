import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import 'settings_screen.dart';

class TextChatScreen extends StatelessWidget {
  const TextChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // 👇 Override system back button
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, AppRoutes.voiceChat);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFE9F8EF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,

          /// BACK BUTTON
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.voiceChat,
              );
            },
          ),

          title: const Text(
            "AgriAssist",
            style: TextStyle(color: Colors.black),
          ),

          actions: [
            /// SETTINGS BUTTON
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
          ],
        ),

        body: SafeArea(
          child: Column(
            children: [
              /// CHAT MESSAGES
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  children: [
                    _botBubble("Hello, how can I help you today?"),
                    _userBubble("Tell me, how are you?"),
                    _botBubble("I am good. How about you?"),
                    _userBubble("I am also fine 😊"),
                  ],
                ),
              ),

              /// INPUT BAR
              _chatInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- BOT MESSAGE ----------------
  Widget _botBubble(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  // ---------------- USER MESSAGE ----------------
  Widget _userBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: Color(0xFF4C8BF5),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }


  // ---------------- INPUT BAR ----------------
  Widget _chatInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// ATTACH BUTTON
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.black45),
            onPressed: () {},
          ),

          /// TEXT FIELD
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Type message here",
                border: InputBorder.none,
              ),
            ),
          ),

          /// MIC BUTTON
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.black54),
            onPressed: () {},
          ),

          /// SEND BUTTON
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0E3D3D),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
