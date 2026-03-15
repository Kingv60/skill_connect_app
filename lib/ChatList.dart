import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../Provider/chat_provider.dart';
import '../Provider/search_provider.dart';
import 'message.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- NEW: Helper to show the 10 users list ---
  void _showUserSelectionSheet(BuildContext context) {
    // This triggers the Node.js "query === ''" block to get 10 recent users
    ref.read(chatSearchProvider.notifier).searchUsers("");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B2C33),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final users = ref.watch(chatSearchProvider);

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7, // 70% of screen height
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    height: 4, width: 40,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                  ),
                  const Text(
                    "New Chat",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(color: Colors.white10),
                  Flexible(
                    child: users.isEmpty
                        ? const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: Colors.blueAccent),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: AppAvatar(url: user["avatar"], name: user["name"] ?? "U"),
                          title: Text(user["name"], style: const TextStyle(color: Colors.white)),
                          onTap: () async {
                            final int? conversationId = await ref
                                .read(chatSearchProvider.notifier)
                                .startConversation(user["user_id"]);

                            if (context.mounted) {
                              Navigator.pop(context); // Close sheet
                              if (conversationId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatPage(
                                      name: user["name"],
                                      image: user["avatar"],
                                      conversationId: conversationId,
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(allChatsProvider);
    final searchResults = ref.watch(chatSearchProvider);

    String formatChatTime(String dateTimeString) {
      try {
        final dateTime = DateTime.parse(dateTimeString).toLocal();
        final now = DateTime.now();
        final difference = now.difference(dateTime);
        if (difference.inSeconds < 60) return "Now";
        if (difference.inMinutes < 60) return "${difference.inMinutes}m ago";
        if (difference.inHours < 24) return "${difference.inHours}h ago";
        if (difference.inDays == 1) return "Yesterday";
        return "${dateTime.day}/${dateTime.month}";
      } catch (e) { return ""; }
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        onPressed: () => _showUserSelectionSheet(context), // Trigger the sheet
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Chats", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  cursorColor: Colors.white,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    ref.read(chatSearchProvider.notifier).searchUsers(value.trim());
                  },
                  decoration: InputDecoration(
                    hintText: "Search users...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: searchResults.isNotEmpty && _searchController.text.isNotEmpty
                    ? _buildSearchResults(searchResults)
                    : _buildChatList(chatsAsync, formatChatTime),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<dynamic> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final user = results[index];
        return ListTile(
          leading: AppAvatar(url: user["avatar"], name: user["name"] ?? "U"),
          title: Text(user["name"], style: const TextStyle(color: Colors.white)),
          onTap: () async {
            final int? conversationId = await ref
                .read(chatSearchProvider.notifier)
                .startConversation(user["user_id"]);

            if (conversationId != null && context.mounted) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    name: user["name"],
                    image: user["avatar"],
                    conversationId: conversationId,
                  ),
                ),
              );
              _searchController.clear();
              ref.read(chatSearchProvider.notifier).searchUsers("");
            }
          },
        );
      },
    );
  }

  // --- KEEP YOUR EXISTING _buildChatList AND _buildAvatarImage METHODS HERE ---
  Widget _buildChatList(AsyncValue chatsAsync, Function formatTime) {
    return chatsAsync.when(
      data: (chats) {
        if (chats.isEmpty) {
          return const Center(child: Text("No chats yet", style: TextStyle(color: Colors.white)));
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(allChatsProvider.notifier).fetchChats(),
          color: Colors.blueAccent,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(name: chat.name, image: chat.avatar, conversationId: chat.conversationId)));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(18)),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 26, backgroundColor: Colors.white.withOpacity(0.1), child: ClipOval(child: _buildAvatarImage(chat.avatar))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(chat.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(chat.lastMessage ?? "Start a conversation", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade400)),
                          ],
                        ),
                      ),
                      Text(formatTime(chat.lastTime), style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text("Error: $error", style: const TextStyle(color: Colors.white))),
    );
  }

  Widget _buildAvatarImage(String url) {
    final isSvg = url.toLowerCase().endsWith('.svg');
    if (isSvg) {
      return SvgPicture.network(url, width: 52, height: 52, fit: BoxFit.cover,
          placeholderBuilder: (context) => const CircularProgressIndicator(strokeWidth: 2));
    } else {
      return Image.network(url, width: 52, height: 52, fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white));
    }
  }
}

// --- KEEP YOUR EXISTING AppAvatar CLASS HERE ---
class AppAvatar extends StatelessWidget {
  final String? url;
  final String name;
  final double radius;
  const AppAvatar({super.key, required this.url, required this.name, this.radius = 26});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return CircleAvatar(radius: radius, backgroundColor: Colors.blueAccent, child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white)));
    }
    final cleanUrl = url!;
    final isSvg = cleanUrl.toLowerCase().endsWith('.svg');
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withOpacity(0.1),
      child: ClipOval(
        child: isSvg
            ? SvgPicture.network(cleanUrl, width: radius * 2, height: radius * 2, fit: BoxFit.cover, placeholderBuilder: (_) => const CircularProgressIndicator(strokeWidth: 2))
            : Image.network(cleanUrl, width: radius * 2, height: radius * 2, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}