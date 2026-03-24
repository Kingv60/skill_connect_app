import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skillconnect/New/other_person_profile.dart';


import '../Provider/message_provider.dart';
import '../Services/api-service.dart';
import 'Constants/constants.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String? name;
  final String? image;
  final int conversationId;
  final int receiverId;

  const ChatPage({
    super.key,
    required this.name,
    required this.image,
    required this.conversationId,
    required this.receiverId,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
        curve: Curves.easeOutQuart,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));

    return Scaffold(
      extendBodyBehindAppBar: true, // Allows content to scroll under blurred AppBar
      backgroundColor: const Color(0xFF0F0F0F), // Deeper OLED black
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: Colors.black.withOpacity(0.5),
              elevation: 0,
              leading: IconButton(
                icon: Container(height: 30,width: 30,decoration: BoxDecoration(shape: BoxShape.circle,border: Border.all(width: 1,color: Colors.white)),child: const Icon(Icons.close, color: Colors.white, size: 20)),
                onPressed: () => Navigator.pop(context),
              ),
              title: Row(
                children: [


                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name ?? "User",
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),

                    ],
                  ),
                  Spacer(),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white12,
                    child: GestureDetector(onTap:(){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>OtherPersonProfile(userId: 2)));},child: ClipOval(child: _buildAvatarImage(widget.image))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Pattern (Optional)
          Positioned.fill(
            child: Image.network(
              'https://www.transparenttextures.com/patterns/cubes.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: messagesAsync.when(
                  data: (messages) {
                    if (messages.isEmpty) {
                      return const Center(child: Text("Start a conversation", style: TextStyle(color: Colors.grey)));
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[messages.length - 1 - index];
                        final bool isMe = message.senderId == ApiService.userId;
                        return ChatBubble(message: message.message, isMe: isMe);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
                  error: (err, _) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
                ),
              ),
              _buildModernInput(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernInput() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: const Border(top: BorderSide(color: Colors.white10, width: 0.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 15),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _onSendMessage,
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                    ),
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage(String? url) {
    if (url == null || url.isEmpty) {
      return const Icon(Icons.person, color: Colors.white, size: 20);
    }

    final fullUrl = url.startsWith("http") ? url : "$baseUrlImage$url";

    // SVG
    if (url.toLowerCase().endsWith(".svg")) {
      return SvgPicture.network(
        fullUrl,
        fit: BoxFit.cover,
        placeholderBuilder: (_) =>
        const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    // Normal Image
    if (url.toLowerCase().endsWith(".png") ||
        url.toLowerCase().endsWith(".jpg") ||
        url.toLowerCase().endsWith(".jpeg") ||
        url.toLowerCase().endsWith(".webp")) {
      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
        const Icon(Icons.person, color: Colors.white),
      );
    }

    // If unknown format
    return const Icon(Icons.person, color: Colors.white, size: 20);
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
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
          gradient: isMe
              ? const LinearGradient(
            colors: [Color(0xFF9333EA),
              Color(0xFFDB2777),],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : const LinearGradient(
            colors: [
              Color(0xFF3B82F6), // blue
              Color(0xFF06B6D4), // cyan
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          color: isMe ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}