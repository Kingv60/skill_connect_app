import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skillconnect/New/other_person_profile.dart';

import '../Provider/message_provider.dart';
import '../Services/api-service.dart';
import 'Constants/constants.dart';
import 'Model/message_model.dart';
import 'Services/AppColors.dart';

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
  final List<String> _quickEmojis = ["❤️", "🙌", "🔥", "😮", "😢"];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // FIX: Added mounted check to prevent dispose error
  void _handleReaction(int messageId, String emoji) async {
    // 1. Call the API
    final result = await ApiService().toggleReaction(messageId, emoji);

    // 2. FIX: Check if the user is still on this screen before updating
    if (!mounted) return;

    if (result != null) {
      // 3. Use refresh. Combined with skipLoadingOnRefresh below,
      // this will update the emojis silently without a loading spinner.
      ref.refresh(messagesProvider(widget.conversationId));
    }
  }

  void _showReactionMenu(Offset tapPosition, int messageId) {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.05),
      builder: (context) => Stack(
        children: [
          Positioned(
            left: tapPosition.dx > MediaQuery.of(context).size.width / 2 ? null : 20,
            right: tapPosition.dx > MediaQuery.of(context).size.width / 2 ? 20 : null,
            top: tapPosition.dy - 80,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ..._quickEmojis.map((emoji) => GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _handleReaction(messageId, emoji);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    )),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _showFullEmojiPicker(messageId);
                      },
                      child: const CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white10,
                        child: Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullEmojiPicker(int messageId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
        itemCount: 12,
        itemBuilder: (context, index) {
          String emoji = ["👍", "🎉", "🤣", "✨", "🙏", "💯", "🎈", "🥳", "✅", "📍", "👑", "👀"][index];
          return GestureDetector(
            onTap: () {
              setState(() => _quickEmojis[0] = emoji);
              Navigator.pop(context);
              _handleReaction(messageId, emoji);
            },
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
          );
        },
      ),
    );
  }

  Future<void> _onSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    try {
      final newMessage = await ApiService().sendMessage(widget.conversationId, text);

      if (!mounted) return; // FIX: Prevents dispose error

      if (newMessage != null) {
        ref.read(messagesProvider(widget.conversationId).notifier).addMessage(newMessage);
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send: $e"), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOutQuart);
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
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.scaffoldBg,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [AppColors.drawerBg, AppColors.scaffoldBg],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                skipLoadingOnRefresh: true, // FIX: Crucial for smooth reaction updates
                data: (messages) {
                  if (messages.isEmpty) return const Center(child: Text("Say hello!", style: TextStyle(color: AppColors.textMuted)));
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 110, 16, 20),
                    reverse: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      final bool isMe = message.senderId == ApiService.userId;
                      return ChatBubble(
                        message: message,
                        isMe: isMe,
                        onLongPress: (position) => _showReactionMenu(position, message.messageId),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (err, _) => Center(child: Text("Error: $err", style: const TextStyle(color: AppColors.error))),
              ),
            ),
            _buildModernInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AppBar(
            backgroundColor: AppColors.scaffoldBg.withOpacity(0.7),
            elevation: 0,
            leadingWidth: 70,
            leading: Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 36, width: 36,
                  decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                ),
              ),
            ),
            title: GestureDetector(
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OtherPersonProfile(userId: widget.receiverId))),
              child: Row(
                children: [
                  _buildModernAvatar(widget.image),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.name ?? "User", style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                      const Text("Online", style: TextStyle(color: AppColors.success, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernAvatar(String? url) {
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient),
      child: CircleAvatar(radius: 19, backgroundColor: AppColors.cardBg, child: ClipOval(child: _buildAvatarImage(url))),
    );
  }

  Widget _buildModernInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(color: AppColors.scaffoldBg, border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(28)),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.textMuted)),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: const InputDecoration(hintText: "Write a message...", border: InputBorder.none),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _onSendMessage,
            child: Container(
              height: 52, width: 52,
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(String? url) {
    if (url == null || url.isEmpty) return const Icon(Icons.person, color: Colors.white, size: 20);
    final fullUrl = url.startsWith("http") ? url : "$baseUrlImage$url";
    return url.toLowerCase().endsWith(".svg")
        ? SvgPicture.network(fullUrl, fit: BoxFit.cover)
        : Image.network(fullUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white));
  }
}

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final Function(Offset tapPosition) onLongPress;

  const ChatBubble({super.key, required this.message, required this.isMe, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) => onLongPress(details.globalPosition),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    gradient: isMe ? AppColors.primaryGradient : null,
                    color: isMe ? null : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20), topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 4), bottomRight: Radius.circular(isMe ? 4 : 20),
                    ),
                  ),
                  child: Text(message.message, style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary)),
                ),
                if (message.reactions.isNotEmpty)
                  Positioned(
                    bottom: -8, right: isMe ? 10 : null, left: isMe ? null : 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                      child: Text(message.reactions.map((e) => e.emoji).toSet().join(''), style: const TextStyle(fontSize: 12)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}