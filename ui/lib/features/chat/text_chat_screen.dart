import 'dart:convert';
import 'dart:io'; // Import Platform
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../routes/app_routes.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'settings_screen.dart';

class TextChatScreen extends StatefulWidget {
  const TextChatScreen({super.key});

  @override
  State<TextChatScreen> createState() => _TextChatScreenState();
}

class _TextChatScreenState extends State<TextChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // Added for auto-scroll
  List<Map<String, String>> messages = [];
  bool isLoading = false; // To show a loading indicator if needed

  String getBaseUrl() {

    //If using real device then comment this code
    // if (Platform.isAndroid) {
    //   return "http://10.0.2.2:8000";
    // } else {
    //   return "http://127.0.0.1:8000";
    // }
     return "http://10.108.2.174:8000"; // Uncomment and set this for real devices
  }

  // ⭐ SEND MESSAGE FUNCTION
  Future<void> sendMessage() async {
    String text = controller.text.trim();
    if (text.isEmpty) return;

    // 1. Add User Message immediately
    setState(() {
      messages.add({"role": "user", "text": text});
      isLoading = true;
    });

    controller.clear();
    _scrollToBottom(); // Auto scroll down

    try {
      final String baseUrl = getBaseUrl();

      // 2. Send request to Backend
      final response = await http.post(
        Uri.parse("$baseUrl/chat/send"), // 👈 MATCHED TO BACKEND ENDPOINT
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": text}),
      );

      if (!mounted) return; // Prevent setState if screen is closed

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 3. Add Bot Response
        setState(() {
          messages.add({
            "role": "bot",
            "text": data["response"] ?? "No reply received."
          });
        });
      } else {
        setState(() {
          messages.add({
            "role": "bot",
            "text": "Server Error: ${response.statusCode}"
          });
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        messages.add({
          "role": "bot",
          "text": "Connection failed. Make sure the server is running."
        });
      });
      print("Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, AppRoutes.voiceChat);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFE9F8EF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
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
                child: ListView.builder(
                  controller: _scrollController, // Attach controller
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      // Show loading indicator bubble
                      return _botBubble("Typing...");
                    }

                    final msg = messages[index];
                    if (msg["role"] == "user") {
                      return _userBubble(msg["text"]!);
                    }
                    return _botBubble(msg["text"]!);
                  },
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
        constraints: const BoxConstraints(maxWidth: 280), // Slightly wider for better formatting
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
        child: MarkdownBody(
          data: text,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(fontSize: 14, color: Colors.black),
            strong: const TextStyle(fontWeight: FontWeight.bold), // Handles **bold**
          ),
        ),
      ),
    );
  }

  // ---------------- USER MESSAGE ----------------
  Widget _userBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
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
        child: MarkdownBody(
          data: text,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(color: Colors.white, fontSize: 14),
            strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
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
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.black45),
            onPressed: () {},
          ),

          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Type message here",
                border: InputBorder.none,
              ),
              onSubmitted: (_) => sendMessage(), // Allow Enter key to send
            ),
          ),

          IconButton(
            icon: const Icon(Icons.mic, color: Colors.black54),
            onPressed: () {},
          ),

          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0E3D3D),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}