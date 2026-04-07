import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'Constants/constants.dart';
import '../Provider/chat_provider.dart';
import '../Provider/search_provider.dart';
import 'Services/AppColors.dart';
import 'message.dart';

// --- UnreadChatProvider remains unchanged ---
final unreadChatProvider = StateNotifierProvider<UnreadChatNotifier, Set<int>>((ref) => UnreadChatNotifier());
class UnreadChatNotifier extends StateNotifier<Set<int>> {
  UnreadChatNotifier() : super({});
  void markUnread(int conversationId) => state = {...state, conversationId};
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

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(allChatsProvider);
    final searchResults = ref.watch(chatSearchProvider);
    final isSearching = _searchController.text.isNotEmpty;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        floatingActionButton: _buildFab(),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),

              // Only show Slider Tabs if not searching
              if (!isSearching) _buildSliderTabs(),

              Expanded(
                child: isSearching
                    ? _buildSearchResults(searchResults)
                    : TabBarView(
                  children: [
                    _buildChatList(chatsAsync, showProjects: false), // Direct
                    _buildChatList(chatsAsync, showProjects: true),  // Groups/Projects
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- NEW: SLIDER TAB DESIGN ---
  Widget _buildSliderTabs() {
    return Container(
      // 1. Reduced vertical margin to 4 to save vertical space
      margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),

      // 2. Set explicit height (38 is a great "sweet spot" for slim tabs)
      height: 38,

      // 3. Reduced padding to 3 so the indicator has room to breathe
      padding: const EdgeInsets.all(3),

      decoration: BoxDecoration(
        color: AppColors.surface,
        // 4. Slightly reduced radius for a sharper, cleaner look
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textMuted,

        // 5. Reduced font size to 12 to match the shorter height
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),

        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: AppColors.primaryGradient,
        ),
        tabs: const [
          Tab(text: "Direct"),
          Tab(text: "Groups"),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Messages", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.more_vert, color: AppColors.textSecondary),
              )
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary),
              onChanged: (val) {
                setState(() {}); // Trigger rebuild to toggle TabBar/TabBarView
                final query = val.trim();
                if (query.length > 2) ref.read(chatSearchProvider.notifier).searchUsers(query);
                else if (query.isEmpty) ref.read(chatSearchProvider.notifier).searchUsers("");
              },
              decoration: const InputDecoration(
                hintText: "Search conversations...",
                hintStyle: TextStyle(color: AppColors.textMuted),
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(AsyncValue chatsAsync, {required bool showProjects}) {
    final unreadChats = ref.watch(unreadChatProvider);
    return chatsAsync.when(
      data: (chats) {
        // FILTERING: Separation based on 'isProjectChat' from your model
        final filteredChats = chats.where((chat) => chat.isProjectChat == showProjects).toList();

        if (filteredChats.isEmpty) {
          return Center(
            child: Text(
              showProjects ? "No project groups yet" : "No direct messages yet",
              style: const TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(allChatsProvider.notifier).fetchChats(),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: filteredChats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final chat = filteredChats[index];
              final isUnread = unreadChats.contains(chat.conversationId);
              return _buildModernChatCard(chat, isUnread);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => _buildErrorState(),
    );
  }

  Widget _buildModernChatCard(dynamic chat, bool isUnread) {
    return GestureDetector(
      onTap: () {
        ref.read(unreadChatProvider.notifier).markRead(chat.conversationId);
        Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(name: chat.name, image: chat.avatar, conversationId: chat.conversationId, receiverId: chat.userId)));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 10),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.surface : AppColors.cardBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isUnread ? AppColors.primary.withOpacity(0.3) : Colors.white.withOpacity(0.03)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                AppAvatar(url: chat.avatar, name: chat.name, radius: 20),
                if (isUnread)
                  Positioned(
                    right: 0, top: 0,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: AppColors.scaffoldBg, width: 2)),
                    ),
                  )
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chat.name, style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: isUnread ? FontWeight.bold : FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(chat.lastMessage ?? "Tap to chat", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isUnread ? AppColors.textPrimary.withOpacity(0.9) : AppColors.textSecondary, fontSize: 14)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_formatTime(chat.lastTime), style: TextStyle(color: isUnread ? AppColors.primary : AppColors.textMuted, fontSize: 12, fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
                const SizedBox(height: 8),
                if (isUnread)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                    child: const Text("NEW", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                  )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        onPressed: () => _showUserSelectionSheet(context),
      ),
    );
  }

  // --- (Keeping all your other helper methods: _showUserSelectionSheet, _buildErrorState, etc.) ---
  void _showUserSelectionSheet(BuildContext context) {
    ref.read(chatSearchProvider.notifier).searchUsers("");
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.drawerBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
          ),
          child: Consumer(
            builder: (context, ref, child) {
              final users = ref.watch(chatSearchProvider);
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(height: 4, width: 40, decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(10))),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("New Conversation", style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                    Expanded(
                      child: users.isEmpty ? const Center(child: Text("No users found", style: TextStyle(color: AppColors.textMuted))) : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        itemCount: users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return _buildModernListTile(
                            onTap: () async {
                              final id = await ref.read(chatSearchProvider.notifier).startConversation(user["user_id"]);
                              if (context.mounted && id != null) {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(name: user["name"], image: user["avatar"], conversationId: id, receiverId: user["user_id"])));
                              }
                            },
                            leading: AppAvatar(url: user["avatar"], name: user["name"], radius: 26),
                            title: user["name"],
                            subtitle: "Start a new chat",
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
      ),
    );
  }

  Widget _buildModernListTile({required VoidCallback onTap, required Widget leading, required String title, required String subtitle}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: AppColors.surface.withOpacity(0.5),
      leading: leading,
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, color: AppColors.error.withOpacity(0.5), size: 60),
          const SizedBox(height: 16),
          const Text("Connection lost", style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => ref.read(allChatsProvider.notifier).fetchChats(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Try Again"),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          )
        ],
      ),
    );
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return "";
    try {
      final DateTime serverDate = DateTime.parse(timeStr).toLocal();
      final DateTime now = DateTime.now();
      if (serverDate.year == now.year && serverDate.month == now.month && serverDate.day == now.day) return DateFormat.jm().format(serverDate);
      final yesterday = now.subtract(const Duration(days: 1));
      if (serverDate.year == yesterday.year && serverDate.month == yesterday.month && serverDate.day == yesterday.day) return "Yesterday";
      return DateFormat.MMMd().format(serverDate);
    } catch (e) { return ""; }
  }

  Widget _buildSearchResults(List<dynamic> results) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final user = results[index];
        return _buildModernListTile(
          onTap: () async {
            final id = await ref.read(chatSearchProvider.notifier).startConversation(user["user_id"]);
            if (id != null && context.mounted) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(name: user["name"], image: user["avatar"], conversationId: id, receiverId: user["user_id"])));
            }
          },
          leading: AppAvatar(url: user["avatar"], name: user["name"]),
          title: user["name"],
          subtitle: "View Profile",
        );
      },
    );
  }
}

// AppAvatar remains exactly the same as your provided code
class AppAvatar extends StatelessWidget {
  final String? url;
  final String? name;
  final double radius;
  const AppAvatar({super.key, this.url, this.name, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final String initial = (name != null && name!.isNotEmpty) ? name![0].toUpperCase() : "?";
    final bool hasImage = url != null && url!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColors.blueGradient),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surface,
        child: ClipOval(
          child: !hasImage
              ? Text(initial, style: TextStyle(color: AppColors.accentBlue, fontWeight: FontWeight.bold, fontSize: radius * 0.8))
              : (url!.toLowerCase().endsWith('.svg')
              ? SvgPicture.network("${url!.startsWith('http') ? '' : baseUrlImage}$url", width: radius * 1.5, height: radius * 1.5, fit: BoxFit.cover)
              : Image.network("${url!.startsWith('http') ? '' : baseUrlImage}$url", width: radius * 1.5, height: radius * 1.5, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Text(initial))),
        ),
      ),
    );
  }
}