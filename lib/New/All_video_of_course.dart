import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skillconnect/Constants/constants.dart';
import 'package:skillconnect/Services/api-service.dart';
import 'VideoPlayfor_course.dart';

class CourseVideoPage extends StatelessWidget {
  final dynamic profile;
  final int course_id;

  const CourseVideoPage({
    super.key,
    required this.profile,
    required this.course_id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f0f0f),
      extendBodyBehindAppBar: true, // Content flows under AppBar
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
        title: Text(
          profile.username,
          style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService().getVideosByCourse(course_id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }

          final List<dynamic> videos = snapshot.data ?? [];

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              /// --- MODERN HEADER SECTION ---
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 120, 20, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blueAccent.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildAvatar(profile),
                      const SizedBox(height: 16),
                      Text(
                        profile.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "@${profile.username} • ${videos.length} Lessons",
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(color: Colors.white10, thickness: 1),
                ),
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
                      Text("No videos in this course yet",
                          style: TextStyle(color: Colors.white54, fontSize: 16)),
                    ],
                  ),
                ),
              )
                  : SliverPadding(
                padding: const EdgeInsets.only(top: 10, bottom: 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildYouTubeVideoCard(context, videos[index], profile),
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

  Widget _buildAvatar(dynamic profile) {
    final String? avatarUrl = profile.avatarUrl;
    final String fullUrl = avatarUrl != null ? "$baseUrlImage$avatarUrl" : "";

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: const Color(0xff1a1a1a),
        child: ClipOval(
          child: (avatarUrl != null && avatarUrl.toLowerCase().endsWith('.svg'))
              ? SvgPicture.network(
            fullUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            placeholderBuilder: (_) => const CircularProgressIndicator(),
          )
              : (avatarUrl == null || avatarUrl.isEmpty)
              ? const Icon(Icons.person, color: Colors.white24, size: 50)
              : Image.network(
            fullUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildYouTubeVideoCard(BuildContext context, dynamic video, dynamic creator) {
    final String title = video['title'] ?? "Untitled Video";
    final String thumbUrl = "$baseUrlImage${video['thumbnail_url']}";
    final String videoUrl = "$baseUrlImage${video['video_url']}";

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
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'video_thumb_${video['video_id'] ?? title}',
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    height: 210,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(thumbUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 15,
                  right: 25,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(
                      "Lesson ${video['order_index'] ?? ''}",
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Overlay play icon for modern look
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Module ${video['order_index'] ?? '1'} • 15:00", // Generic duration added for UI
                          style: const TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.white38),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSmall(dynamic profile) {
    final String? avatarUrl = profile.avatarUrl;
    final String fullUrl = avatarUrl != null ? "$baseUrlImage$avatarUrl" : "";
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white10,
        backgroundImage: (avatarUrl != null && !avatarUrl.toLowerCase().endsWith('.svg'))
            ? NetworkImage(fullUrl)
            : null,
        child: (avatarUrl != null && avatarUrl.toLowerCase().endsWith('.svg'))
            ? ClipOval(child: SvgPicture.network(fullUrl))
            : (avatarUrl == null || avatarUrl.isEmpty)
            ? const Icon(Icons.person, color: Colors.white24, size: 20)
            : null,
      ),
    );
  }
}