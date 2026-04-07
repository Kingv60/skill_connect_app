import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillconnect/Constants/constants.dart';
import 'package:skillconnect/New/get_reel_page.dart';
import 'package:skillconnect/New/my_all_project.dart';
import 'package:skillconnect/New/my_enrolled_course.dart';
import 'package:skillconnect/New/other_person_profile.dart';
import 'package:skillconnect/Screens/project-create.dart';
import 'package:skillconnect/Screens/user_search.dart';
import 'package:skillconnect/profile.dart';
import 'package:video_player/video_player.dart';

import '../Model/Post_model.dart';
import '../Provider/profile_provider.dart';
import '../Services/AppColors.dart';
import '../Services/api-service.dart';
import '../Smooth/presentation/new_login_page.dart';
import '../Widgets/AppDrawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool showRetry = false;
  String name = "";
  String username = "";
  String role = "";
  String bio = "";
  String avatarUrl = "";
  List<String> skills = [];

  // 1. ADD LOCAL STATE FOR POSTS
  List<Post> _posts = [];
  bool _isLoading = true;
  final Set<int> _likedPostIds = {}; // Tracks liked posts locally

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Initial Load Logic
  Future<void> _loadInitialData() async {
    ref.read(profileProvider.notifier).loadProfile();
    await _fetchFeed(); // Load posts into local list
  }

  // Fetch Feed Logic (Used for init and Pull-to-Refresh)
  Future<void> _fetchFeed() async {
    try {
      final data = await ApiService().fetchFeed();
      if (mounted) {
        setState(() {
          _posts = data;
          _isLoading = false;
          // Note: Yahan hum _likedPostIds ko clear nahi kar rahe taaki
          // session ke dauran liked posts red hi rahein.
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. OPTIMISTIC LIKE (Instant UI update)
  Future<void> _handleLike(int postId, int index) async {
    // 1. Optimistic Update: Turant UI badlo
    setState(() {
      int currentLikes = int.tryParse(_posts[index].likes) ?? 0;

      if (_likedPostIds.contains(postId)) {
        // Agar pehle se liked tha toh unlike karo
        _likedPostIds.remove(postId);
        _posts[index].likes = (currentLikes > 0 ? currentLikes - 1 : 0).toString();
      } else {
        // Agar liked nahi tha toh like karo
        _likedPostIds.add(postId);
        _posts[index].likes = (currentLikes + 1).toString();
      }
    });

    try {
      // 2. API Call in background
      final success = await ApiService().togglePostLike(postId);

      // Agar API fail ho jaye toh purana state wapis lao
      if (!success) {
        _fetchFeed(); // Reset feed if error occurs
      }
    } catch (e) {
      _fetchFeed(); // Reset feed if crash occurs
    }
  }

  // 3. INSTANT COMMENT SHEET
  void _showCommentSheet(int postId, int index) {
    final TextEditingController _commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6, // Increased height to show list
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Top Handle
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text("Comments", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const Divider(color: Colors.white10),

                /// --- UPDATED: COMMENT LIST AREA ---
                Expanded(
                  child: FutureBuilder<List<dynamic>?>(
                    future: ApiService().getPostComments(postId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                      }

                      if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                        return const Center(child: Text("No comments yet", style: TextStyle(color: Colors.white38)));
                      }

                      final comments = snapshot.data!;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: comments.length,
                        itemBuilder: (context, i) {
                          final comment = comments[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildAvatar(comment['avatar_url']),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comment['username'] ?? "User",
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        comment['comment_text'],
                                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                /// Input Area (Same as before)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  color: const Color(0xFF1E1E1E),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Add a comment...",
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (_commentController.text.trim().isEmpty) return;
                          final res = await ApiService().addPostComment(postId, _commentController.text.trim());
                          if (res != null) {
                            setState(() {
                              int current = int.tryParse(_posts[index].comments) ?? 0;
                              _posts[index].comments = (current + 1).toString();
                            });
                            Navigator.pop(context);
                            // Optional: Show success snackbar
                          }
                        },
                        child: const Text("Post", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    if (profile != null) {
      name = profile.name;
      username = profile.username;
      role = profile.role;
      bio = profile.bio;
      avatarUrl = profile.avatarUrl;
      skills = profile.skills;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      endDrawer: AppDrawer(name: name, role: role, avatarUrl: avatarUrl),
      body: SafeArea(
        child: Stack(
          children: [
            profile == null ? _buildLoadingState() : _buildScrollableContent(),
            _buildNeonHeader(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2));
  }

  Widget _buildScrollableContent() {
    // 4. ADD REFRESH INDICATOR
    return RefreshIndicator(
      color: Colors.blueAccent,
      backgroundColor: const Color(0xFF1E1E1E),
      onRefresh: _fetchFeed,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 70)),
          _buildSectionTitle("Trending Now"),
          _buildModernFeed(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2)),
      ),
    );
  }

  Widget _buildNeonHeader() {
    return Positioned(
      top: 15, left: 15, right: 15,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 55, padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1))),
            child: Row(
              children: [
                const Text("SKILL CONNECT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
                const Spacer(),
                Builder(builder: (context) => GestureDetector(
                  onTap: () => Scaffold.of(context).openEndDrawer(),
                  child: Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.menu_rounded, color: Colors.white, size: 22)),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 5. SIMPLIFIED FEED (No FutureBuilder flicker)
  Widget _buildModernFeed() {
    if (_isLoading) {
      return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: Colors.blueAccent))));
    }

    if (_posts.isEmpty) {
      return const SliverToBoxAdapter(child: Center(child: Text("No posts found", style: TextStyle(color: Colors.white54))));
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final post = _posts[index];
            final imageUrl = "$baseUrlImage${post.file}";
            final isLiked = _likedPostIds.contains(post.postId);

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: post.file.endsWith(".mp4")
                  ? _buildVideoClip(
                index,
                post.postId,
                imageUrl,
                post.caption,
                post.likes,
                post.comments,
                isLiked,
                post.username,
                baseUrlImage+post.avatarUrl,
              )
                  : _buildPostCard(
                index,
                post.postId,
                imageUrl,
                post.caption,
                post.likes,
                post.comments,
                isLiked,
                post.username,
                baseUrlImage+post.avatarUrl,
              ),
            );
          },
          childCount: _posts.length,
        ),
      ),
    );
  }
  Widget _buildAvatar(String? avatarUrl) {
    // 1. Handle Null or Empty Case
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return const CircleAvatar(
        radius: 16,
        backgroundColor: Colors.white10,
        child: Icon(Icons.person, size: 18, color: Colors.white38),
      );
    }

    // 2. Handle SVG Case
    if (avatarUrl.toLowerCase().endsWith('.svg')) {
      return ClipOval(
        child: SvgPicture.network(
          baseUrlImage+avatarUrl,
          width: 45,
          height: 45,
          fit: BoxFit.cover,
          placeholderBuilder: (BuildContext context) => const CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // 3. Handle Standard Image Case (JPG, PNG, etc.)
    return CircleAvatar(
      radius: 16,
      backgroundImage: NetworkImage(baseUrlImage+avatarUrl),
      onBackgroundImageError: (exception, stackTrace) {
        // Fallback if the network image fails to load
        print("Error loading avatar: $exception");
      },
    );
  }

  Widget _buildVideoClip(
      int index,
      int id,
      String url,
      String title,
      String likes,
      String comments,
      bool isLiked,
      String username,
      String? profileUrl,
      ) {
    return Container(
      height: 500,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [

          /// VIDEO
          ReelVideoPlayer(url: url),
          _buildPostHeader(profileUrl, username,_posts[index].user_id),

          /// GRADIENT
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),

          /// TEXT + BUTTONS
          Positioned(
            bottom: 15,
            left: 25,
            right: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _handleLike(id, index),
                      child: _interactionIcon(
                        isLiked ? Icons.favorite : Icons.favorite_outline,
                        likes,
                        color: isLiked ? Colors.red : Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),

                    GestureDetector(
                      onTap: () => _showCommentSheet(id, index),
                      child: _interactionIcon(Icons.chat_bubble_outline, comments),
                    ),

                    const Spacer(),

                    GestureDetector(
                      onTap: () {
                        ReelVideoPlayer.togglePlayPause();
                      },
                      child: const Icon(
                        Icons.pause_circle_outline,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(
      int index,
      int id,
      String url,
      String label,
      String likes,
      String comments,
      bool isLiked,
      String username,
      String? profileUrl,
      ) {
    return Container(
      decoration: BoxDecoration(


      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// HEADER
          Padding(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>OtherPersonProfile(userId: _posts[index].user_id )));},
              child: Row(
                children: [
                  _buildProfileImage(profileUrl),
                  const SizedBox(width: 10),
                  Text(
                    username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.more_vert, color: Colors.white),
                ],
              ),
            ),
          ),

          /// IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              width: double.infinity,
             
            ),
          ),

          /// ACTIONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _handleLike(id, index),
                  child: _interactionIcon(
                    isLiked ? Icons.favorite : Icons.favorite_outline,
                    likes,
                    color: isLiked ? Colors.red : Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => _showCommentSheet(id, index),
                  child: _interactionIcon(
                    Icons.chat_bubble_outline,
                    comments,
                  ),
                ),
              ],
            ),
          ),

          /// CAPTION
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _interactionIcon(IconData icon, String count, {Color color = Colors.white}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 5),
        Text(count, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }
  Widget _buildProfileImage(String? url) {
    if (url == null || url.isEmpty) {
      return const CircleAvatar(
        radius: 15,
        child: Icon(Icons.person, size: 18),
      );
    }

    if (url.endsWith(".svg")) {
      return CircleAvatar(
        radius: 15,
        backgroundColor: Colors.white,
        child: ClipOval(
          child: SvgPicture.network(
            url,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 15,
      backgroundImage: NetworkImage(url),
    );
  }
  Widget _buildPostHeader(String? profileUrl, String username, int user_id) {
    return Positioned(
      top: 15,
      left: 15,
      right: 15,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtherPersonProfile(userId: user_id),
            ),
          );
        },
        child: Row(
          children: [
            _buildProfileImage(profileUrl),
            const SizedBox(width: 10),
            Text(
              username,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            const Icon(Icons.more_vert, color: Colors.white),
          ],
        ),
      ),
    );
  }
}