import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillconnect/New/All_video_of_course.dart';
import 'package:skillconnect/New/video_upload_page.dart';

// Assuming these are defined in your project
import 'Constants/constants.dart';
import 'New/VideoPlayfor_course.dart';
import 'New/edit_page.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadColors();
  }

  Future<void> loadColors() async {
    final prefs = await SharedPreferences.getInstance();
    int? bg = prefs.getInt('bgColor');
    int? text = prefs.getInt('textColor');
    if (bg != null) backgroundColor = Color(bg);
    if (text != null) textColor = Color(text);
    if (mounted) setState(() {});
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
                    const SizedBox(height: 10),
                    // Bio/Role Badge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.work_outline, color: AppColors.primary, size: 16),
                              const SizedBox(width: 8),
                              Text(profile.role, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(profile.bio, style: TextStyle(color: textColor.withOpacity(0.8), height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
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
                  tabs: const [Tab(text: "My Videos"), Tab(text: "Courses")],
                ),
                backgroundColor,
              ),
            ),

            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
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

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => YouTubePlayerPage(videoUrl: videoUrl, title: videoTitle))),
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