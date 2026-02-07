import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:audioplayers/audioplayers.dart'; // ✅ Audio Player
import '../../routes/app_routes.dart';
import 'settings_screen.dart';
import '../../services/api_service.dart';
import '../../core/services/auth_service.dart';

class TextChatScreen extends StatefulWidget {
  final String? prefilledQuery;

  const TextChatScreen({super.key, this.prefilledQuery});

  @override
  State<TextChatScreen> createState() => _TextChatScreenState();
}

class _TextChatScreenState extends State<TextChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer(); // ✅ Player instance

  // Changed to dynamic to store 'id' (int) and 'text' (String)
  List<Map<String, dynamic>> messages = [];

  bool isLoading = false;
  int? activeSessionId;

  // Track which message is currently playing audio
  int? _playingMessageIndex;
  bool _isFetchingAudio = false; // Loading state for TTS

  bool _hasSentPrefilledQuery = false;

  @override
  void initState() {
    super.initState();
    _restoreUserFromStorage();

    // Listen to player completion to reset icon
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _playingMessageIndex = null;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.prefilledQuery != null &&
          widget.prefilledQuery!.isNotEmpty &&
          !_hasSentPrefilledQuery) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted && !_hasSentPrefilledQuery) {
            _hasSentPrefilledQuery = true;
            controller.text = widget.prefilledQuery!;
            sendMessage();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    controller.dispose();
    _audioPlayer.dispose(); // ✅ Clean up player
    super.dispose();
  }

  Future<void> _restoreUserFromStorage() async {
    if (ApiService.currentUserId == null) {
      final storedUserId = await AuthService.getUserId();
      if (storedUserId != null) {
        setState(() {
          ApiService.currentUserId = storedUserId;
        });
      }
    }
  }

  Future<void> sendMessage() async {
    String text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": text});
      isLoading = true;
    });

    controller.clear();
    _scrollToBottom();

    try {
      if (ApiService.currentUserId == null) {
        final storedUserId = await AuthService.getUserId();
        if (storedUserId != null) ApiService.currentUserId = storedUserId;
        else throw Exception("User not logged in.");
      }

      if (activeSessionId == null) {
        int? newSessionId = await ApiService.createSession("New Consultation");
        if (newSessionId != null) activeSessionId = newSessionId;
        else throw Exception("Failed to create chat session.");
      }

      // Expecting Map with content and ID
      final responseMap = await ApiService.sendChatMessage(activeSessionId!, text);

      if (!mounted) return;

      if (responseMap != null) {
        setState(() {
          messages.add({
            "role": "bot",
            "text": responseMap['content'],
            "id": responseMap['id'], //  Store the Backend Message ID
          });
        });
      } else {
        setState(() {
          messages.add({
            "role": "bot",
            "text": "⚠️ Server Error: Could not get a response."
          });
        });
      }

    } catch (e) {
      if (!mounted) return;
      setState(() {
        messages.add({
          "role": "bot",
          "text": "❌ Error: ${e.toString()}"
        });
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  // AUDIO HANDLING LOGIC
  Future<void> _handleAudioPlay(int index, int? messageId) async {
    // 1. If currently playing this message, STOP it.
    if (_playingMessageIndex == index) {
      await _audioPlayer.stop();
      setState(() {
        _playingMessageIndex = null;
      });
      return;
    }

    // 2. Stop any other playing message
    await _audioPlayer.stop();

    if (messageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Audio unavailable for this message.")),
      );
      return;
    }

    // 3. Start Loading
    setState(() {
      _playingMessageIndex = index;
      _isFetchingAudio = true;
    });

    try {
      // 4. Fetch Audio Bytes from Backend
      Uint8List? audioBytes = await ApiService.getTtsAudio(messageId);

      if (audioBytes != null && mounted) {
        // 5. Play Audio from Bytes
        await _audioPlayer.play(BytesSource(audioBytes));
        // Note: _playingMessageIndex remains set until onPlayerComplete fires
      } else {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to load audio.")),
          );
          setState(() {
            _playingMessageIndex = null;
          });
        }
      }
    } catch (e) {
      print("Audio Play Error: $e");
      if (mounted) {
        setState(() {
          _playingMessageIndex = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingAudio = false;
        });
      }
    }
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard!'),
          backgroundColor: Color(0xFF0E3D3D),
          duration: Duration(seconds: 1),
        ),
      );
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
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.voiceChat),
          ),
          title: const Text("AgriAssist", style: TextStyle(color: Colors.black)),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.black),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen())
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (widget.prefilledQuery != null && _hasSentPrefilledQuery && messages.isEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  child: const LinearProgressIndicator(color: Color(0xFF0E3D3D)),
                ),
              Expanded(
                child: messages.isEmpty && !isLoading
                    ? _buildEmptyState()
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return _botBubble("Typing...", false, index, null);
                    }
                    final msg = messages[index];
                    if (msg["role"] == "user") {
                      return _userBubble(msg["text"]);
                    }
                    return _botBubble(msg["text"], true, index, msg["id"]);
                  },
                ),
              ),
              _chatInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- BOT MESSAGE ----------------
  Widget _botBubble(String text, bool showButtons, int index, int? messageId) {
    final isPlaying = _playingMessageIndex == index;
    // If this specific bubble is playing AND we are still fetching bytes
    final isLoadingAudio = isPlaying && _isFetchingAudio;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isPlaying ? const Color(0xFFE8F5E9) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: isPlaying
                    ? Border.all(color: Colors.green.withOpacity(0.5))
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: MarkdownBody(data: text),
            ),

            if (showButtons)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Row(
                  children: [
                    // 🔊 SPEAKER BUTTON
                    _actionButton(
                      child: isLoadingAudio
                          ? const SizedBox(
                          width: 12, height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0E3D3D))
                      )
                          : Icon(
                        isPlaying ? Icons.stop : Icons.volume_up,
                        size: 18,
                        color: isPlaying ? Colors.red : const Color(0xFF0E3D3D),
                      ),
                      color: isPlaying ? Colors.red : const Color(0xFF0E3D3D),
                      tooltip: isPlaying ? 'Stop' : 'Listen',
                      onPressed: () => _handleAudioPlay(index, messageId),
                    ),
                    const SizedBox(width: 10),
                    // 📋 COPY BUTTON
                    _actionButton(
                      child: const Icon(Icons.content_copy, size: 18, color: Color(0xFF0E3D3D)),
                      color: const Color(0xFF0E3D3D),
                      tooltip: 'Copy',
                      onPressed: () => _copyToClipboard(text),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required Widget child,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }

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
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 50, color: Color(0xFF0E3D3D)),
          const SizedBox(height: 10),
          const Text("Start a conversation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _chatInputBar() {
    final isLoggedIn = ApiService.currentUserId != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: isLoggedIn,
              decoration: InputDecoration(
                hintText: isLoggedIn ? "Type message..." : "Please login to chat",
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: isLoggedIn ? (_) => sendMessage() : null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF0E3D3D)),
            onPressed: isLoggedIn ? sendMessage : null,
          ),
        ],
      ),
    );
  }
}