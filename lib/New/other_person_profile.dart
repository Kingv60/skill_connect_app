import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skillconnect/Constants/constants.dart';
import '../Model/chatModel.dart';
import '../Provider/chat_provider.dart';
import '../Provider/search_provider.dart';
import '../Services/api-service.dart';
import '../message.dart';
import '../profile.dart';

class OtherPersonProfile extends ConsumerStatefulWidget {
  final int userId;
  const OtherPersonProfile({super.key, required this.userId});

  @override
  ConsumerState<OtherPersonProfile> createState() => _OtherPersonProfileState();
}

class _OtherPersonProfileState extends ConsumerState<OtherPersonProfile> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  dynamic otherUserProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService().getOtherUserProfile(widget.userId);
      if (mounted) {
        setState(() {
          otherUserProfile = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Logic for navigation (Maintained)
  void _navigateToChat(String name, String avatar) {
    final chatsState = ref.read(allChatsProvider);
    chatsState.when(
      data: (chats) {
        final existingChat = chats.firstWhere(
              (c) => c.userId == widget.userId,
          orElse: () => ChatSummary(
            conversationId: -1,
            name: name,
            avatar: avatar,
            lastMessage: '',
            userId: widget.userId,
            lastTime: '',
          ),
        );

        if (existingChat.conversationId != -1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(
                name: existingChat.name,
                image: existingChat.avatar,
                conversationId: existingChat.conversationId,
                receiverId: widget.userId,
              ),
            ),
          );
        } else {
          _createAndNavigate(name, avatar);
        }
      },
      loading: () => null,
      error: (err, stack) => debugPrint("Provider Error: $err"),
    );
  }

  Future<void> _createAndNavigate(String name, String avatar) async {
    final int? newId = await ref.read(chatSearchProvider.notifier).startConversation(widget.userId);
    if (newId != null && mounted) {
      ref.read(allChatsProvider.notifier).fetchChats();
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(name: name, image: avatar, conversationId: newId, receiverId: widget.userId)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)));
    }

    final String name = otherUserProfile['name'] ?? "User";
    final String username = otherUserProfile['username'] ?? "creator";
    final String role = otherUserProfile['role'] ?? "Creative Professional";
    final String bio = otherUserProfile['bio'] ?? "No bio available";
    final String avatar = otherUserProfile['avatar'] ?? "";
    final List<dynamic> skills = otherUserProfile['skills'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 210, // Significantly reduced height
              backgroundColor: Colors.black,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [IconButton(icon: const Icon(Icons.more_horiz, color: Colors.white), onPressed: () {})],
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildAvatarHeader(avatar),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                Text("@$username", style: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(role, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildActionButtons(name, avatar),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("About", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 6),
                    Text(bio, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: skills.map((s) => SkillChip(text: s.toString())).toList(),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.blueAccent,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white30,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: "Videos"),
                    Tab(text: "Activity"),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildVideoGrid(),
            _buildActivityTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarHeader(String url) {
    return Container(
      height: 75,
      width: 75,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: ClipOval(
        child: url.isEmpty
            ? const Icon(Icons.person, color: Colors.white24, size: 40)
            : (url.toLowerCase().endsWith(".svg")
            ? SvgPicture.network(baseUrlImage + url, fit: BoxFit.cover)
            : Image.network(baseUrlImage + url, fit: BoxFit.cover)),
      ),
    );
  }

  Widget _buildActionButtons(String name, String avatar) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: () => _navigateToChat(name, avatar),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text("Message", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 18),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildVideoGrid() {
    return FutureBuilder<List<dynamic>>(
      future: ApiService().getVideosByUserId(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No content yet", style: TextStyle(color: Colors.white24)));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) => VideoListItem(video: snapshot.data![index]),
        );
      },
    );
  }

  Widget _buildActivityTab() {
    return const Center(child: Text("No recent activity", style: TextStyle(color: Colors.white24)));
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withOpacity(0.8),
          child: _tabBar,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}