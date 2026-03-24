import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skillconnect/Constants/constants.dart';
import 'package:skillconnect/Services/api-service.dart'; // Ensure correct import
import 'VideoPlayfor_course.dart';

class CourseVideoPage extends StatelessWidget {
  final dynamic profile;
  final int course_id;

  const CourseVideoPage({
    super.key,
    required this.profile,
    required this.course_id,
  });
  void _handleEnroll(BuildContext context, int courseId) async {
    // Show a simple snackbar to give immediate feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Processing enrollment..."), duration: Duration(seconds: 1)),
    );

    final result = await ApiService().enrollInCourse(courseId);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xff0f0f0f),
      appBar: AppBar(
        backgroundColor: const Color(0xff0f0f0f),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(profile.username, style: const TextStyle(fontSize: 16, color: Colors.white)),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService().getVideosByCourse(course_id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          final List<dynamic> videos = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              /// --- HEADER SECTION ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildAvatar(profile),
                      const SizedBox(height: 12),
                      Text(
                        profile.name,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "@${profile.username} • ${videos.length} videos",
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      // ... inside your CustomScrollView -> SliverToBoxAdapter
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          // CALL THE FUNCTION HERE
                          onPressed: () => _handleEnroll(context, course_id), // ✅ Pass context first, then ID
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text("Join", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: Divider(color: Colors.white12, thickness: 1),
              ),

              /// --- VIDEO LIST SECTION ---
              videos.isEmpty
                  ? const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_library_outlined, color: Colors.white24, size: 60),
                      SizedBox(height: 16),
                      Text("No videos yet", style: TextStyle(color: Colors.white54, fontSize: 16)),
                    ],
                  ),
                ),
              )
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildYouTubeVideoCard(context, videos[index], profile),
                  childCount: videos.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Avatar Helper logic
  Widget _buildAvatar(dynamic profile) {
    final String? avatarUrl = profile.avatarUrl;
    final String fullUrl = avatarUrl != null ? "$baseUrlImage$avatarUrl" : "";

    if (avatarUrl == null || avatarUrl.isEmpty) {
      return CircleAvatar(
        radius: 45,
        backgroundColor: Colors.grey[900],
        child: const Icon(Icons.person, color: Colors.white, size: 40),
      );
    }

    if (avatarUrl.toLowerCase().endsWith('.svg')) {
      return CircleAvatar(
        radius: 45,
        backgroundColor: Colors.grey[900],
        child: ClipOval(
          child: SvgPicture.network(
            fullUrl,
            width: 90, height: 90,
            fit: BoxFit.cover,
            placeholderBuilder: (_) => const CircularProgressIndicator(),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 45,
      backgroundColor: Colors.grey[900],
      backgroundImage: NetworkImage(fullUrl),
    );
  }

  /// VIDEO CARD WIDGET
  Widget _buildYouTubeVideoCard(BuildContext context, dynamic video, dynamic creator) {

    // UPDATED KEYS: Matching your JSON exactly
    final String title = video['title'] ?? "Untitled Video";
    final String thumbUrl = "$baseUrlImage${video['thumbnail_url']}";
    final String videoUrl = "$baseUrlImage${video['video_url']}";
    print(thumbUrl);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => YouTubePlayerPage(
              videoUrl: videoUrl,
              title: title,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Stack(
            children: [
              Image.network(
                thumbUrl,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, e, s) => Container(
                  height: 220,
                  color: Colors.grey[900],
                  child: const Icon(Icons.image_not_supported, color: Colors.white24),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                  child: const Text("Lesson", style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display creator avatar in the video card
                _buildAvatarSmall(creator),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${creator.name} • Lesson ${video['order_index'] ?? ''}",
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: Colors.white, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Small avatar version for the video list items
  Widget _buildAvatarSmall(dynamic profile) {
    final String? avatarUrl = profile.avatarUrl;
    final String fullUrl = avatarUrl != null ? "$baseUrlImage$avatarUrl" : "";
    if (avatarUrl != null && avatarUrl.toLowerCase().endsWith('.svg')) {
      return CircleAvatar(radius: 18, child: ClipOval(child: SvgPicture.network(fullUrl)));
    }
    return CircleAvatar(radius: 18, backgroundImage: NetworkImage(fullUrl));
  }
}