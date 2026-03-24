import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillconnect/New/All_video_of_course.dart';
import 'package:skillconnect/New/video_upload_page.dart';

import 'Constants/constants.dart';
import 'New/VideoPlayfor_course.dart';
import 'New/edit_page.dart';
import 'Provider/profile_provider.dart';
import 'Services/api-service.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {

  // Theme colors
  Color backgroundColor = const Color(0xff262626);
  Color textColor = Colors.white;

  @override
  void initState() {
    super.initState();
    loadColors();
  }

  Future<void> loadColors() async {
    final prefs = await SharedPreferences.getInstance();

    int? bg = prefs.getInt('bgColor');
    int? text = prefs.getInt('textColor');

    if (bg != null) backgroundColor = Color(bg);
    if (text != null) textColor = Color(text);

    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    /// Widget for the Recent Videos Tab
    /// Widget for the Recent Videos Tab
    Widget _buildRecentVideosTab() {
      return FutureBuilder<List<dynamic>>(
        // Use the new API function we created
        future: ApiService().getAllVideosLatest(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading videos", style: TextStyle(color: Colors.red)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library_outlined, color: Colors.white24, size: 50),
                  SizedBox(height: 10),
                  Text("No videos yet", style: TextStyle(color: Colors.white54)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => VideoListItem(video: snapshot.data![index]),
          );
        },
      );
    }

    /// Widget for the Playlist/Courses Tab
    Widget _buildPlaylistCoursesTab() {
      final profile = ref.watch(profileProvider);
      return FutureBuilder<List<dynamic>>(
        future: ApiService().getMyCreatedCourses(), // Calling your new API function
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No courses created yet", style: TextStyle(color: Colors.white54)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final course = snapshot.data![index];
              return CourseListItem(course: course, profile: profile,);
            },
          );
        },
      );
    }
    final profile = ref.watch(profileProvider);

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          /// Background
          Container(color: backgroundColor),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(height: 30,width: 30,decoration: BoxDecoration(shape: BoxShape.circle,border: Border.all(width: 1,color: Colors.white)),child: const Icon(Icons.close, color: Colors.white, size: 20)),
                      ),
                      Text(
                        profile.username,
                        style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      GestureDetector(
                        onTap: () {}, // Optional: theme menu
                        child: Icon(Icons.more_vert, color: textColor),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                /// Profile Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        height: 85,
                        width: 85,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: textColor, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child:  AppAvatar(url: profile.avatarUrl),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            Text(
                                "${profile.role}\n${profile.bio}",
                              style: TextStyle(
                                  color: textColor.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /// Skills
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Skills",
                        style: TextStyle(
                            color: textColor, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.skills
                            .map((skill) => SkillChip(text: skill))
                            .toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /// Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          title: "Edit Profile",
                          textColor: textColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const EditProfilePage(),
                              ),
                            ).then((_) {
                              ref.read(profileProvider.notifier).refreshProfile();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ActionButton(
                          title: "Video Upload",
                          textColor: textColor,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>UploadMediaPage()));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Add this to your SafArea Column after the "Buttons" Padding:

                const SizedBox(height: 20),

                /// --- NEW VIDEO SECTION ---
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "My Videos",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),


                DefaultTabController(
                  length: 2,
                  child: Expanded(
                    child: Column(
                      children: [

                        /// TAB BAR
                        const TabBar(
                          indicatorColor: Colors.blue,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white54,
                          tabs: [
                            Tab(text: "Recent"),
                            Tab(text: "Playlist"),
                          ],
                        ),

                        /// TAB CONTENT
                        /// TAB CONTENT
                        Expanded(
                          child: TabBarView(
                            children: [
                              /// 1. RECENT TAB (Videos)
                              _buildRecentVideosTab(),

                              /// 2. PLAYLIST TAB (Courses) - UPDATED
                              _buildPlaylistCoursesTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Button
class _ActionButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Color textColor;

  const _ActionButton({
    required this.title,
    this.onTap,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: textColor.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Skill Chip
class SkillChip extends StatelessWidget {
  final String text;
  const SkillChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class VideoListItem extends StatelessWidget {
  final dynamic video;
  const VideoListItem({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    // 1. Correct the Keys to match your "all-latest" JSON
    final String thumbUrl = "$baseUrlImage${video['thumbnail_url'] ?? ""}";
    final String videoUrl = "$baseUrlImage${video['video_url'] ?? ""}";
    final String videoTitle = video['name'] ?? "Untitled Video"; // Changed from 'caption' to 'name'

    // 2. Format Date logic
    String uploadTime = "Just now";
    if (video['created_at'] != null) { // Match 'created_at' from JSON
      try {
        DateTime dt = DateTime.parse(video['created_at']);
        // Format as "Mar 23, 2026" or similar
        uploadTime = "${dt.day}/${dt.month}/${dt.year}";
      } catch (e) {
        uploadTime = "Recent";
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => YouTubePlayerPage(
              videoUrl: videoUrl,
              title: videoTitle,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- THUMBNAIL ---
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 130, // Slightly wider for modern look
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(thumbUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Overlay to show it's a video
                Container(
                  width: 130,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 35),
                ),
              ],
            ),

            const SizedBox(width: 12),

            /// --- DETAILS ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    videoTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.white38, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        uploadTime,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
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

class CourseListItem extends StatelessWidget {
  final dynamic course;
  final dynamic profile;
  const CourseListItem({super.key, required this.course, required this.profile});

  @override
  Widget build(BuildContext context) {
    // Extracting data from the API Map
    final int courseId = course['course_id'] ?? 0; // Use course_id from your API
    final String title = course['title'] ?? "Untitled Course";
    final String thumbUrl = baseUrlImage + (course['thumbnail_url'] ?? "");
    final String level = course['level'] ?? "Beginner";
    final String language = course['language'] ?? "English";

    return GestureDetector(
      onTap: () {
        // Navigate to the details page passing the courseId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseVideoPage(profile: profile, course_id: courseId,),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            /// --- COURSE THUMBNAIL ---
            Container(
              width: 100,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(thumbUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black26,
                ),
                child: const Icon(Icons.playlist_play, color: Colors.white, size: 30),
              ),
            ),
            const SizedBox(width: 16),

            /// --- COURSE INFO ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _infoChip(level, Colors.orangeAccent),
                      const SizedBox(width: 8),
                      _infoChip(language, Colors.blueAccent),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}