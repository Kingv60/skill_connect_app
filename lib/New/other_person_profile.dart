import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skillconnect/Constants/constants.dart';
import 'package:skillconnect/New/reel_player%20_for_other.dart';
import '../Model/chatModel.dart';
import '../Model/media_post_model.dart';
import '../Model/other_person_reel_model.dart';
import '../Provider/chat_provider.dart';
import '../Provider/search_provider.dart';
import '../Services/api-service.dart';
import '../message.dart';
import '../profile.dart';
import 'My_Post_Media.dart';
import 'VideoPlayfor_course.dart';
import 'other_person_course.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
            lastTime: '', isProjectChat: false,
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
      body: SafeArea(
        child: NestedScrollView(
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
                      Tab(text: "Posts"),
                      Tab(text: "Reels"),
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
              _buildPostsTab(),     // 2. Posts ke liye (Naya method)
              _buildReelsTab()
            ],
          ),
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
        // This Expanded allows the button group to take up all space
        // except for the small IconButton at the end.
        Expanded(
          child: Row(
            children: [
              // Wrap the FIRST button in Expanded
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
              const SizedBox(width: 10),
              // Wrap the SECOND button in Expanded
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserCoursesScreen(
                            userId: widget.userId,
                            name: otherUserProfile['name'],
                            username: otherUserProfile['username'],
                            profile: otherUserProfile,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text("Courses", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // The small fixed-width button remains as is
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
      // 1. Aapki nayi API call yahan ho rahi hai
      future: ApiService().getVideoByUserIdOther(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white30)));
        }

        final videos = snapshot.data ?? [];

        if (videos.isEmpty) {
          return const Center(
            child: Text("No videos posted yet", style: TextStyle(color: Colors.white24, fontSize: 14)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          physics: const BouncingScrollPhysics(),
          itemCount: videos.length,
          itemBuilder: (context, index) => VideoListItem(
            video: videos[index],
            profile: otherUserProfile, // Passing profile for consistent UI
          ),
        );
      },
    );
  }



  Widget _buildPostsTab() {
    return FutureBuilder<List<dynamic>>(
      // Aapka naya ApiService function jo userId leta hai
      future: ApiService().getPostsByUserId(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading posts", style: TextStyle(color: Colors.white24)));
        }

        final List<dynamic> postsData = snapshot.data ?? [];

        if (postsData.isEmpty) {
          return const Center(child: Text("No posts yet", style: TextStyle(color: Colors.white24)));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: postsData.length,
          itemBuilder: (context, index) {
            final postJson = postsData[index];

            // 1. Map data ko MyPost model mein convert karna
            DateTime parsedDate;
            try {
              parsedDate = postJson['createddate'] != null
                  ? DateTime.parse(postJson['createddate'].toString())
                  : DateTime.now();
            } catch (e) {
              parsedDate = DateTime.now(); // Agar parse fail ho jaye toh current date
            }
            // Taki hum MyPostDetailPage use kar sakein
            final MyPost postModel = MyPost(
              postId: postJson['post_id'] ?? 0,
              caption: postJson['caption'] ?? "",
              file: postJson['file'] ?? "",
              userId: postJson['user_id'] ?? 0,
              username: postJson['username'] ?? "User",
              avatarUrl: postJson['avatar_url'] ?? "",
              likes: postJson['likes']?.toString() ?? "0",
              comment: postJson['comments']?.toString() ?? "0", // Backend key check karein 'comments' vs 'comment'
              createdDate: parsedDate, createdBy: 0,
            );

            return GestureDetector(
              onTap: () {
                // 2. Aapka banaya hua Detail Page yahan call hoga
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyPostDetailPage(post: postModel),
                  ),
                );
              },
              child: Container(
                color: Colors.grey[900],
                child: Image.network(
                  "$baseUrlImage${postModel.file}",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.play_circle_fill, color: Colors.white24, size: 30),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReelsTab() {
    return FutureBuilder<List<OtherPersonReel>>(
      // ApiService ka naya function call kiya
      future: ApiService().fetchReelsByUserId(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white24));
        }

        if (snapshot.hasError) {
          return const Center(
              child: Text("Error loading reels", style: TextStyle(color: Colors.white24))
          );
        }

        final List<OtherPersonReel> reels = snapshot.data ?? [];

        if (reels.isEmpty) {
          return const Center(
              child: Text("No reels yet", style: TextStyle(color: Colors.white24))
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(2),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.6, // Reels vertical (tall) hoti hain
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: reels.length,
          itemBuilder: (context, index) {
            final reel = reels[index];

            return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReelPlaybackPageOther(
                        reels: reels, // Puri list pass karein
                        initialIndex: index,username: otherUserProfile['username'] ?? "User",
                        url: otherUserProfile['avatar'] ?? "", // Jis reel par tap kiya uska index
                      ),
                    ),
                  );
              },
              child: Container(
                color: Colors.grey[900],
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Video Thumbnail (Agar backend se null hai toh play icon)
                    reel.thumbnailUrl != null
                        ? Image.network(
                      "$baseUrlImage${reel.thumbnailUrl}",
                      fit: BoxFit.cover,
                    )
                        : Container(
                      color: Colors.white10,
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white38, size: 40),
                    ),

                    // Views count (Bottom Left par)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Row(
                        children: [
                          const Icon(Icons.play_arrow_outlined,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            reel.views,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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

class VideoListItem extends StatelessWidget {
  final dynamic video;
  const VideoListItem({super.key, required this.video, required profile});

  @override
  Widget build(BuildContext context) {
    // Backend keys handle karein (name vs title)
    final String videoTitle = video['name'] ?? video['title'] ?? "Untitled";
    final String thumbUrl = "$baseUrlImage${video['thumbnail_url'] ?? ""}";
    final String videoUrl = "$baseUrlImage${video['video_url'] ?? ""}";
    final int video_id = video['video_id'];
    final String createdAT =video['created_at'];


    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => YouTubePlayerPage(
              videoUrl: videoUrl,
              title: videoTitle, videoId: video_id, createAT: createdAT,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            // Thumbnail with Play Icon overlay
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    thumbUrl,
                    width: 120,
                    height: 75,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 120, height: 75, color: Colors.white10,
                      child: const Icon(Icons.video_library, color: Colors.white24),
                    ),
                  ),
                ),
                const Icon(Icons.play_circle_fill, color: Colors.white70, size: 30),
              ],
            ),
            const SizedBox(width: 15),
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      videoTitle,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 5),
                  Text(
                      "Lesson • ${video['created_at']?.toString().split('T')[0] ?? 'Recently'}",
                      style: const TextStyle(color: Colors.white38, fontSize: 11)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}