import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillconnect/New/video_upload_page.dart';

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
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            color: textColor, size: 20),
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
                          child: profile.avatarUrl.endsWith(".svg")
                              ? SvgPicture.network(
                            profile.avatarUrl,
                            placeholderBuilder: (context) =>
                            const CircularProgressIndicator(),
                            fit: BoxFit.cover,
                          )
                              : Image.network(
                            "http://localhost:8000${profile.avatarUrl}",
                            fit: BoxFit.cover,
                          )
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

                const SizedBox(height: 10),

                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: ApiService().getMyFeed(), // Your class-top token is used here
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text("No videos yet", style: TextStyle(color: Colors.white54)),
                        );
                      }

                      // YouTube-style Grid
                      // Change this section inside your Expanded(child: FutureBuilder(...))
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final video = snapshot.data![index];
                          return VideoListItem(video: video); // Use the new List Item widget
                        },
                      );
                    },
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
    // Construct URLs - adjust baseUrl as per your ApiService
    final String thumbUrl = video['thumbnail_url'] ?? "";
    final String videoUrl = video['media_url'] ?? "";
    final String videoTitle = video['caption'] ?? "Untitled Video";

    // Format Date (Assuming backend returns 'createdAt')
    String uploadTime = "Just now";
    if (video['createdAt'] != null) {
      DateTime dt = DateTime.parse(video['createdAt']);
      uploadTime = "${dt.day}/${dt.month}/${dt.year}";
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
            /// --- THUMBNAIL (LEFT) ---
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120, // Fixed width for thumbnail
                  height: 85,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1,color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(thumbUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Icon(Icons.play_circle_fill, color: Colors.white70, size: 30),
              ],
            ),

            const SizedBox(width: 12),

            /// --- DETAILS (RIGHT COLUMN) ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    videoTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Uploaded: $uploadTime",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
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