import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skillconnect/Constants/constants.dart';
import 'package:skillconnect/Services/api-service.dart';
import 'VideoPlayfor_course.dart';

class OtherUserVideosPage extends StatefulWidget {
  final dynamic otherUserProfile;
  final int userId;

  const OtherUserVideosPage({
    super.key,
    required this.otherUserProfile,
    required this.userId,
  });

  @override
  State<OtherUserVideosPage> createState() => _OtherUserVideosPageState();
}

class _OtherUserVideosPageState extends State<OtherUserVideosPage> {
  late Future<List<dynamic>> _videosFuture;
  @override
  void initState() {
    super.initState();
    // We call the API here once, and store the result in our variable
    _videosFuture = ApiService().getVideosByUserId(widget.userId);
  }
  bool _isEnrolling = false; // To show loading on button
  Future<void> _handleEnroll(BuildContext context) async {
    setState(() => _isEnrolling = true);

    try {
      // Assuming courseId is the same as widget.userId or
      // passed within widget.otherUserProfile['course_id']
      final int courseId = widget.userId;

      final result = await ApiService().enrollInCourse(courseId);

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An unexpected error occurred.")),
      );
    } finally {
      if (mounted) setState(() => _isEnrolling = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    final String name = widget.otherUserProfile['name'] ?? "User";
    final String username = widget.otherUserProfile['username'] ?? "creator";
    final String avatar = widget.otherUserProfile['avatar'] ?? "";

    return Scaffold(
      backgroundColor: const Color(0xff0f0f0f),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<dynamic>>( // Keeping List<dynamic> because your API returns a List
        future: _videosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
          }

          // Since ApiService already returns the list, we use snapshot.data directly
          final List<dynamic> videos = snapshot.data ?? [];

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              /// --- HEADER SECTION ---
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 120, 20, 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blueAccent.withOpacity(0.15), Colors.transparent],
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildHeaderAvatar(avatar),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "@$username • ${videos.length} Lessons",
                        style: const TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                      const SizedBox(height: 20),

                      /// --- ENROLL BUTTON ---
                      SizedBox(
                        width: 200,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () => _handleEnroll(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text("Enroll in Course",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// --- VIDEO LIST ---
              videos.isEmpty
                  ? const SliverFillRemaining(
                child: Center(
                  child: Text("No videos found", style: TextStyle(color: Colors.white38)),
                ),
              )
                  : SliverPadding(
                padding: const EdgeInsets.only(bottom: 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildVideoCard(context, videos[index], avatar),
                    childCount: videos.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _buildHeaderAvatar(String url) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
      ),
      child: CircleAvatar(
        radius: 45,
        backgroundColor: Colors.white10,
        child: ClipOval(
          child: url.isEmpty
              ? const Icon(Icons.person, color: Colors.white24, size: 40)
              : (url.toLowerCase().endsWith(".svg")
              ? SvgPicture.network(baseUrlImage + url, fit: BoxFit.cover)
              : Image.network(baseUrlImage + url, fit: BoxFit.cover)),
        ),
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, dynamic video, String avatarUrl) {
    final String title = video['title'] ?? "Untitled";
    final String thumbUrl = "$baseUrlImage${video['thumbnail_url']}";
    final String videoUrl = "$baseUrlImage${video['video_url']}";
    final int video_id = video['video_id'];
    final String createdAT =video['created_at'];


    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => YouTubePlayerPage(videoUrl: videoUrl, title: title, videoId: video_id, createAT: createdAT,),
          ),
        );
      },
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(thumbUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Icon(Icons.play_circle_fill,
                      color: Colors.white.withOpacity(0.8), size: 50),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white10,
                  backgroundImage: (avatarUrl.isNotEmpty && !avatarUrl.toLowerCase().endsWith('.svg'))
                      ? NetworkImage(baseUrlImage + avatarUrl)
                      : null,
                  child: avatarUrl.toLowerCase().endsWith('.svg')
                      ? SvgPicture.network(baseUrlImage + avatarUrl)
                      : (avatarUrl.isEmpty ? const Icon(Icons.person, size: 18) : null),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                          maxLines: 2),
                      const SizedBox(height: 4),
                      Text("Lesson • ${video['created_at'] ?? 'Recently'}",
                          style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: Colors.white38, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}