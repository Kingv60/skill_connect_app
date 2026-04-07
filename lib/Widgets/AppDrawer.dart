import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillconnect/New/My_Post_Media.dart';
import 'package:skillconnect/Services/AppColors.dart';
import 'package:skillconnect/profile.dart';
import 'package:skillconnect/Screens/user_search.dart';
import 'package:skillconnect/Screens/project-create.dart';
import 'package:skillconnect/New/my_all_project.dart';
import 'package:skillconnect/New/my_enrolled_course.dart';
import 'package:skillconnect/New/get_reel_page.dart';
import 'package:skillconnect/Smooth/presentation/new_login_page.dart';
import 'package:skillconnect/Constants/constants.dart';
import 'package:video_player/video_player.dart'; // For AppAvatar if needed

class AppDrawer extends StatelessWidget {
  final String name;
  final String role;
  final String avatarUrl;

  const AppDrawer({
    super.key,
    required this.name,
    required this.role,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      backgroundColor: AppColors.drawerBg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header Section ---
              _buildHeader(),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(color: Colors.white10),
              ),

              // --- Menu Items ---
              _drawerItem(context, Icons.explore_outlined, "Explore", onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const UserSearchScreen()));
              }),
              _drawerItem(context, Icons.person_outline_rounded, "My Profile", onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
              }),
              _drawerItem(context, Icons.add_box_outlined, "Create Project", onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectCreatePage()));
              }),
              _drawerItem(context, Icons.grid_view_rounded, "My Projects", onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => MyProjectsPage()));
              }),
              _drawerItem(context, Icons.auto_stories_outlined, "Enrolled Courses", onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => MyCoursesListPage()));
              }),
              _drawerItem(context, Icons.photo_album_outlined, "My Posts", onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => MyPostMediaPage()));
              }),
              _drawerItem(context, Icons.video_camera_back_outlined, "My Reels", onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => MyReelsPage()));
              }),

              const Spacer(),

              // --- Logout Item ---
              _drawerItem(context, Icons.logout_rounded, "Sign Out", isLogout: true, onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.cardBg,
              child: ClipOval(
                // Assuming AppAvatar is a custom widget you have defined
                child: AppAvatar(url: avatarUrl),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : "User",
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role.isNotEmpty ? role.toUpperCase() : "DEVELOPER",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
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

  Widget _drawerItem(BuildContext context, IconData icon, String title, {required VoidCallback onTap, bool isLogout = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isLogout ? AppColors.error.withOpacity(0.1) : AppColors.bluePrime.withOpacity(0.1),
          ),
          child: Row(
            children: [
              Icon(icon, size: 24, color: isLogout ? AppColors.error : AppColors.textSecondary),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  color: isLogout ? AppColors.error : AppColors.textPrimary.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Logout", style: TextStyle(color: AppColors.textPrimary)),
        content: const Text("Are you sure you want to logout?", style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout(context);
            },
            child: const Text("Logout", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.setBool("remember_me", false);

    // Using Navigator.pushAndRemoveUntil to clear stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const NewLoginPage()),
          (route) => false,
    );
  }
}

class ReelVideoPlayer extends StatefulWidget {
  final String url;

  const ReelVideoPlayer({super.key, required this.url});
  static late VideoPlayerController controller;
  static void togglePlayPause() {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  late VideoPlayerController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {
          isLoading = false;
        });

        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose(); // VERY IMPORTANT
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ClipRRect(
      child: VideoPlayer(_controller),
    );
  }
}