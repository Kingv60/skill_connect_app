import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../Provider/message_provider.dart';
import '../Services/api-service.dart';
import '../Model/message_model.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String? name;
  final String? image;
  final int conversationId;

  const ChatPage({
    super.key,
    required this.name,
    required this.image,
    required this.conversationId,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Unified Send Message Logic
  Future<void> _onSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      final newMessage = await ApiService().sendMessage(
        widget.conversationId,
        text,
      );

      if (newMessage != null) {
        ref
            .read(messagesProvider(widget.conversationId).notifier)
            .addMessage(newMessage);

        _scrollToBottom();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send: $e")),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Helper to handle SVG or Network Image
  Widget _buildAvatarImage(String? url) {
    // Handle null or empty URL
    if (url == null || url.isEmpty) {
      return const Icon(Icons.person, color: Colors.white);
    }

    // Fix for Android Emulator
    final cleanUrl = url;
    final isSvg = cleanUrl.toLowerCase().endsWith('.svg');

    if (isSvg) {
      return SvgPicture.network(
        cleanUrl,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        placeholderBuilder: (context) => const CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      return Image.network(
        cleanUrl,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20, // Slightly smaller for AppBar
              backgroundColor: Colors.white.withOpacity(0.1),
              child: ClipOval(
                // FIXED: Use widget.image and handle fallback
                child: _buildAvatarImage(widget.image),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.name ?? "User",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text("No messages yet", style: TextStyle(color: Colors.grey)));
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    final bool isMe = message.senderId == ApiService.userId;

                    return ChatBubble(
                      message: message.message,
                      isMe: isMe,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      color: const Color(0xFF121212),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _onSendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _onSendMessage,
            child: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }
}