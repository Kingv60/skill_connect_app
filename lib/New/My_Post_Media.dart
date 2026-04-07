import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure this is in pubspec.yaml
import 'package:skillconnect/Constants/constants.dart';
import 'package:skillconnect/Widgets/AppDrawer.dart';
import '../Model/media_post_model.dart';
import '../Services/api-service.dart';


class MyPostMediaPage extends StatefulWidget {
  const MyPostMediaPage({super.key});

  @override
  State<MyPostMediaPage> createState() => _MyPostMediaPageState();
}

class _MyPostMediaPageState extends State<MyPostMediaPage> {
  late Future<List<MyPost>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    setState(() {
      _postsFuture = ApiService().fetchMyPosts();
    });
  }

  void _handleDelete(int postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Delete Post", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to delete this post?",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              bool success = await ApiService().deleteMediaPost(postId);
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post deleted")));
                  _loadPosts();
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("My Posts"), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: FutureBuilder<List<MyPost>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text("Error loading posts", style: TextStyle(color: Colors.white)));

          final posts = snapshot.data ?? [];
          return GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MyPostDetailPage(post: post))),
                onLongPress: () => _handleDelete(post.postId),
                child: Container(
                  color: Colors.grey[900],
                  child: Image.network(
                    "$baseUrlImage${post.file}",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.play_circle_fill, color: Colors.white24, size: 40),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MyPostDetailPage extends StatelessWidget {
  final MyPost post;
  const MyPostDetailPage({super.key, required this.post});

  // Reusable Profile Image Builder (Handles SVG/Image/Icon)
  Widget _buildProfileImage(String? avatarUrl, {double radius = 18}) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return CircleAvatar(radius: radius, child: const Icon(Icons.person));
    }
    final String fullUrl = "$baseUrlImage$avatarUrl";
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[800],
      child: ClipOval(
        child: fullUrl.toLowerCase().endsWith('.svg')
            ? SvgPicture.network(fullUrl, fit: BoxFit.cover, width: radius * 2, height: radius * 2)
            : Image.network(fullUrl, fit: BoxFit.cover, width: radius * 2, height: radius * 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isVideo = post.file.toLowerCase().endsWith('.mp4');
    final String fullMediaUrl = "$baseUrlImage${post.file}";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, title: const Text("Post")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: isVideo ? _buildVideoClip(fullMediaUrl) : _buildPostCard(fullMediaUrl),
        ),
      ),
    );
  }

  /// --- VIDEO LAYOUT (REEL STYLE) ---
  Widget _buildVideoClip(String url) {
    return Container(
      height: 600, // CRITICAL: Fixed height prevents the HitTest error
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: ReelVideoPlayer(url: url),
          ),
          // Gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]),
            ),
          ),
          // HEADER (Missing part fixed)
          Positioned(
            top: 15, left: 15, right: 15,
            child: Row(
              children: [
                _buildProfileImage(post.avatarUrl),
                const SizedBox(width: 10),
                Text(post.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const Spacer(),
                const Icon(Icons.more_vert, color: Colors.white),
              ],
            ),
          ),
          // CAPTION & ACTIONS
          Positioned(
            bottom: 25, left: 25, right: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.caption, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _interactionIcon(Icons.favorite_outline, post.likes),
                    const SizedBox(width: 20),
                    _interactionIcon(Icons.chat_bubble_outline, post.comment),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// --- IMAGE LAYOUT (POST STYLE) ---
  Widget _buildPostCard(String url) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: _buildProfileImage(post.avatarUrl),
            title: Text(post.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.more_vert, color: Colors.white),
          ),
          Image.network(url, fit: BoxFit.cover, width: double.infinity),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                _interactionIcon(Icons.favorite_outline, post.likes),
                const SizedBox(width: 20),
                _interactionIcon(Icons.chat_bubble_outline, post.comment),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: Text(post.caption, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _interactionIcon(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 5),
        Text(count, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}