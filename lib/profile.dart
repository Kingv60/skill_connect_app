import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillconnect/New/All_video_of_course.dart';
import 'package:skillconnect/New/video_upload_page.dart';

// Assuming these are defined in your project
import 'Constants/constants.dart';
import 'Model/media_post_model.dart';
import 'New/My_Post_Media.dart';
import 'New/VideoPlayfor_course.dart';
import 'New/edit_page.dart';
import 'New/reward_page.dart';
import 'Provider/profile_provider.dart';
import 'Services/AppColors.dart';
import 'Services/api-service.dart';


class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> with SingleTickerProviderStateMixin {
  Color backgroundColor = AppColors.scaffoldBg;
  Color textColor = AppColors.textPrimary;
  late TabController _tabController;
  int? userId;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadColors();
  }

  Future<void> loadColors() async {
    final prefs = await SharedPreferences.getInstance();

    userId = prefs.getInt('user_id');

    int? bg = prefs.getInt('bgColor');
    int? text = prefs.getInt('textColor');

    backgroundColor = bg != null ? Color(bg) : const Color(0xFF000000);
    textColor = text != null ? Color(text) : const Color(0xFFFFFFFF);

    if (mounted) setState(() {});
  }
  void _resetTheme() async {
    const defaultBg = Color(0xFF000000);
    const defaultText = Color(0xFFFFFFFF);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bgColor', defaultBg.value);
    await prefs.setInt('textColor', defaultText.value);

    setState(() {
      backgroundColor = defaultBg;
      textColor = defaultText;
    });

    Navigator.pop(context);
  }

  void _showThemeDialog() {
    final TextEditingController bgController = TextEditingController(
        text: '#${backgroundColor.value.toRadixString(16).substring(2).toUpperCase()}');
    final TextEditingController textController = TextEditingController(
        text: '#${textColor.value.toRadixString(16).substring(2).toUpperCase()}');

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppColors.surface.withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.white10)),
          title: const Text("Custom Appearance", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHexField("Background Color", bgController),
              const SizedBox(height: 15),
              _buildHexField("Text Color", textController),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
            TextButton(
              onPressed: _resetTheme,
              child: const Text(
                "Reset",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () => _applyTheme(bgController.text, textController.text),
              child: const Text("Update Theme"),
            ),
          ],
        ),
      ),
    );
  }

  void _applyTheme(String bgHex, String textHex) async {
    try {
      Color parseHex(String hex) {
        hex = hex.replaceFirst('#', '');
        if (hex.length == 6) hex = 'FF$hex';
        return Color(int.parse(hex, radix: 16));
      }
      final newBg = parseHex(bgHex);
      final newText = parseHex(textHex);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('bgColor', newBg.value);
      await prefs.setInt('textColor', newText.value);
      setState(() { backgroundColor = newBg; textColor = newText; });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Hex Code!")));
    }
  }

  Widget _buildHexField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    if (profile == null) {
      return const Scaffold(backgroundColor: AppColors.scaffoldBg, body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await ref.read(profileProvider.notifier).refreshProfile();
          setState(() {});
        },
        child: CustomScrollView(
          slivers: [
            // --- MODERN SLIVER APP BAR ---
            SliverAppBar(
              expandedHeight: 220,
              backgroundColor: backgroundColor,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(icon: Icon(Icons.palette_outlined, color: textColor), onPressed: _showThemeDialog),
                IconButton(
                  icon: const Icon(Icons.emoji_events_outlined, color: Colors.amberAccent), // Trophy/Reward icon
                  onPressed: () {
                    if (userId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RewardPage(userId: userId!), // Pass current userId
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("User ID not loaded yet")),
                      );
                    }
                  },
                ),
              ],

              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withOpacity(0.2), Colors.transparent],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Avatar with Glow
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.surface,
                          child: ClipOval(child: AppAvatar(url: profile.avatarUrl)),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(profile.name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 22)),
                      Text("@${profile.username}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),

            // --- PROFILE DETAILS SECTION ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Bio/Role Badge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                             Text("Bio",style: TextStyle(color: Colors.white),),
                              const SizedBox(width: 8),
                              Text(profile.role, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(profile.bio, style: TextStyle(color: textColor.withOpacity(0.8), height: 1.4)),
                        ],
                      ),
                    ),

                    const Text("Expertise", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.skills.map((skill) => SkillChip(text: skill)).toList(),
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        Expanded(child: _ActionButton(title: "Edit Profile", icon: Icons.edit_note, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage())).then((_) => ref.read(profileProvider.notifier).refreshProfile());
                        })),
                        const SizedBox(width: 12),
                        Expanded(child: _ActionButton(title: "Upload", icon: Icons.cloud_upload_outlined, isPrimary: true, onTap: () async {
                          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => UploadMediaPage()));
                          if (result == true) {
                            ref.read(profileProvider.notifier).refreshProfile();
                            setState(() {});
                          }
                        })),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // --- TAB SECTION ---
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [Tab(text: "Posts"),Tab(text: "My Videos"), Tab(text: "Courses")],
                ),
                backgroundColor,
              ),
            ),

            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPostsTab(),
                  _buildRecentVideosTab(),
                  _buildPlaylistCoursesTab(profile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab() {
    if (userId == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      );
    }
    return FutureBuilder<List<dynamic>>(
      // Aapka naya ApiService function jo userId leta hai
      future: ApiService().getPostsByUserId(userId!),
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

// Simple Post Item UI
  Widget _buildPostItem(dynamic post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post['image_url'] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "$baseUrlImage${post['image_url']}",
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 12),
          Text(
            post['content'] ?? "",
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            _formatTime(post['created_at']),
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return "";
    try {
      final DateTime serverDate = DateTime.parse(timeStr).toLocal();
      final DateTime now = DateTime.now();

      // If it's today, show the time (e.g., 10:30 AM)
      if (serverDate.year == now.year &&
          serverDate.month == now.month &&
          serverDate.day == now.day) {
        return DateFormat.jm().format(serverDate);
      }

      // If it's yesterday, show "Yesterday"
      final yesterday = now.subtract(const Duration(days: 1));
      if (serverDate.year == yesterday.year &&
          serverDate.month == yesterday.month &&
          serverDate.day == yesterday.day) {
        return "Yesterday";
      }

      // Otherwise, show the date (e.g., Apr 1)
      return DateFormat.MMMd().format(serverDate);
    } catch (e) {
      return "";
    }
  }

  Widget _buildRecentVideosTab() {
    return FutureBuilder<List<dynamic>>(
      future: ApiService().getAllVideosLatest(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState("No videos found");
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) => VideoListItem(video: snapshot.data![index]),
        );
      },
    );
  }

  Widget _buildPlaylistCoursesTab(profile) {
    return FutureBuilder<List<dynamic>>(
      future: ApiService().getMyCreatedCourses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState("No courses created");
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) => CourseListItem(course: snapshot.data![index], profile: profile),
        );
      },
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.folder_open, color: Colors.white12, size: 60),
      const SizedBox(height: 10),
      Text(msg, style: const TextStyle(color: AppColors.textSecondary)),
    ]));
  }
}

// --- SUPPORTING WIDGETS ---

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({required this.title, required this.icon, required this.onTap, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: isPrimary ? AppColors.primaryGradient : null,
          color: isPrimary ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: isPrimary ? null : Border.all(color: Colors.white10),
          boxShadow: isPrimary ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class SkillChip extends StatelessWidget {
  final String text;
  const SkillChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class VideoListItem extends StatelessWidget {
  final dynamic video;
  const VideoListItem({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final String thumbUrl = "$baseUrlImage${video['thumbnail_url'] ?? ""}";
    final String videoUrl = "$baseUrlImage${video['video_url'] ?? ""}";
    final String videoTitle = video['name'] ?? "Untitled";
    final int video_id = video['video_id'];
    final String createdAT =video['created_at'];


    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => YouTubePlayerPage(videoUrl: videoUrl, title: videoTitle, videoId: video_id, createAT: createdAT,))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(thumbUrl, width: 120, height: 75, fit: BoxFit.cover),
                ),
                const Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(videoTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  const Text("Course Video", style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
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
    final String thumbUrl = baseUrlImage + (course['thumbnail_url'] ?? "");
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(thumbUrl, width: 80, height: 60, fit: BoxFit.cover),
        ),
        title: Text(course['title'] ?? "Course", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              _miniChip(course['level'] ?? "Beginner", AppColors.primary),
              const SizedBox(width: 8),
              _miniChip(course['language'] ?? "EN", Colors.white24),
            ],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CourseVideoPage(profile: profile, course_id: course['course_id']))),
      ),
    );
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.4))),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

// Helper for TabBar Pinned Header
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this.bgColor);
  final TabBar _tabBar;
  final Color bgColor;
  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: bgColor, child: _tabBar);
  }
  @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}