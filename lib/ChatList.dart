import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import '../Provider/chat_provider.dart';
import '../Provider/search_provider.dart';
import 'Constants/constants.dart';
import 'message.dart';

/// -------------------------------
/// UNREAD CHAT PROVIDER
/// -------------------------------
final unreadChatProvider =
StateNotifierProvider<UnreadChatNotifier, Set<int>>((ref) {
  return UnreadChatNotifier();
});

class UnreadChatNotifier extends StateNotifier<Set<int>> {
  UnreadChatNotifier() : super({});

  void markUnread(int conversationId) {
    state = {...state, conversationId};
  }

  void markRead(int conversationId) {
    final newState = {...state};
    newState.remove(conversationId);
    state = newState;
  }
}


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

  void _showUserSelectionSheet(BuildContext context) {
    ref.read(chatSearchProvider.notifier).searchUsers("");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Consumer(
              builder: (context, ref, child) {
                final users = ref.watch(chatSearchProvider);
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.75,
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const Text(
                        "New Message",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: users.isEmpty
                            ? const Center(
                            child: CircularProgressIndicator(
                                color: Colors.blueAccent))
                            : ListView.builder(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              leading: AppAvatar(
                                  url: user["avatar"],
                                  name: user["name"] ?? "U"),
                              title: Text(user["name"],
                                  style: const TextStyle(
                                      color: Colors.white)),
                              onTap: () async {
                                final int? conversationId = await ref
                                    .read(chatSearchProvider.notifier)
                                    .startConversation(user["user_id"]);

                                if (context.mounted) {
                                  Navigator.pop(context);

                                  if (conversationId != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatPage(
                                          name: user["name"],
                                          image: user["avatar"],
                                          conversationId: conversationId,
                                          receiverId: user["user_id"],
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
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(allChatsProvider);
    final searchResults = ref.watch(chatSearchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        child: const Icon(Icons.add_comment_rounded, color: Colors.white),
        onPressed: () => _showUserSelectionSheet(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: searchResults.isNotEmpty &&
                  _searchController.text.isNotEmpty
                  ? _buildSearchResults(searchResults)
                  : _buildChatList(chatsAsync),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Messages",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            onChanged: (val) =>
                ref.read(chatSearchProvider.notifier).searchUsers(val.trim()),
            decoration: InputDecoration(
              hintText: "Search...",
              hintStyle: const TextStyle(color: Colors.white30),
              prefixIcon: const Icon(Icons.search, color: Colors.white30),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(AsyncValue chatsAsync) {
    final unreadChats = ref.watch(unreadChatProvider);

    return chatsAsync.when(
      data: (chats) {
        if (chats.isEmpty) {
          return const Center(
              child: Text("No chats",
                  style: TextStyle(color: Colors.white30)));
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(allChatsProvider.notifier).fetchChats(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              print("Chat: ${chat.name}, Time Raw: ${chat.lastTime}");
              final isUnread =
              unreadChats.contains(chat.conversationId);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isUnread
                      ? Colors.blueAccent.withOpacity(0.08)
                      : Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  onTap: () {
                    ref
                        .read(unreadChatProvider.notifier)
                        .markRead(chat.conversationId);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          name: chat.name,
                          image: chat.avatar,
                          conversationId: chat.conversationId,
                          receiverId: chat.userId,
                        ),
                      ),
                    );
                  },
                  leading: AppAvatar(url: chat.avatar, name: chat.name),
                  title: Text(
                    chat.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                      isUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    chat.lastMessage ?? "Start chatting",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isUnread ? Colors.white : Colors.white54,
                      fontWeight:
                      isUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end, // Align to the right
                    children: [
                      Text(
                        _formatTime(chat.lastTime),
                        style: const TextStyle(
                          color: Colors.white70, // Made brighter for visibility
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                        )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () =>
      const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: Colors.white30, size: 40),
            const SizedBox(height: 10),
            const Text(
              "Chats not loaded",
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: () {
                ref.read(allChatsProvider.notifier).fetchChats();
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return "";

    try {
      // Parse the UTC string from the server and convert to the user's local time
      final DateTime serverDate = DateTime.parse(timeStr).toLocal();
      final DateTime now = DateTime.now();

      // Check if the message was sent today
      if (serverDate.year == now.year &&
          serverDate.month == now.month &&
          serverDate.day == now.day) {
        // Returns "1:23 PM" or "13:23" depending on phone settings
        return DateFormat.jm().format(serverDate);
      }

      // Check if it was sent yesterday
      final yesterday = now.subtract(const Duration(days: 1));
      if (serverDate.year == yesterday.year &&
          serverDate.month == yesterday.month &&
          serverDate.day == yesterday.day) {
        return "Yesterday";
      }

      // Otherwise, show the date (e.g., Mar 21)
      return DateFormat.MMMd().format(serverDate);
    } catch (e) {
      // If parsing fails, return a fallback or empty
      return "";
    }
  }

  Widget _buildSearchResults(List<dynamic> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final user = results[index];

        return ListTile(
          leading: AppAvatar(url: user["avatar"], name: user["name"]),
          title:
          Text(user["name"], style: const TextStyle(color: Colors.white)),
          onTap: () async {
            final int? id = await ref
                .read(chatSearchProvider.notifier)
                .startConversation(user["user_id"]);

            if (id != null && context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    name: user["name"],
                    image: user["avatar"],
                    conversationId: id,
                    receiverId: user["user_id"],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}

/// -------------------------------
/// AVATAR WIDGET
/// -------------------------------
class AppAvatar extends StatelessWidget {
  final String? url;
  final String? name;
  final double radius;

  const AppAvatar({super.key, this.url, this.name, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final String initial =
    (name != null && name!.isNotEmpty) ? name![0].toUpperCase() : "?";

    if (url == null || url!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blueAccent.withOpacity(0.2),
        child: Text(initial,
            style: const TextStyle(
                color: Colors.blueAccent, fontWeight: FontWeight.bold)),
      );
    }

    final bool isSvg = url!.toLowerCase().endsWith('.svg');
    final String fullUrl =
    url!.startsWith('http') ? url! : "$baseUrlImage${url!}";

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blueAccent.withOpacity(0.1),
      child: ClipOval(
        child: isSvg
            ? SvgPicture.network(
          fullUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
        )
            : Image.network(
          fullUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Text(initial),
        ),
      ),
    );
  }
}