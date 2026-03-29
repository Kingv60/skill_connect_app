import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillconnect/Constants/constants.dart';
import 'package:skillconnect/New/get_reel_page.dart';
import 'package:skillconnect/New/my_all_project.dart';
import 'package:skillconnect/New/my_enrolled_course.dart';
import 'package:skillconnect/Screens/project-create.dart';
import 'package:skillconnect/Screens/user_search.dart';
import 'package:skillconnect/profile.dart';

import '../Provider/profile_provider.dart';
import '../Services/AppColors.dart';
import '../Smooth/presentation/new_login_page.dart';

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

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profileProvider.notifier).loadProfile();
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        final profile = ref.read(profileProvider);
        if (profile == null) {
          setState(() => showRetry = true);
        }
      }
    });
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
      endDrawer: _buildDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            /// MAIN CONTENT
            profile == null ? _buildLoadingState() : _buildScrollableContent(),

            /// MODERN FLOATING HEADER
            _buildNeonHeader(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: showRetry
          ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Connection lost", style: TextStyle(color: Colors.white38)),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () {
              setState(() => showRetry = false);
              ref.read(profileProvider.notifier).loadProfile();
            },
            child: const Text("Retry", style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      )
          : const CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2),
    );
  }

  Widget _buildScrollableContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Space for floating header
        const SliverToBoxAdapter(child: SizedBox(height: 100)),

        _buildSectionTitle("Trending Now"),
        _buildModernFeed(),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  // 🌌 NEON HEADER (MODERNIZED)
  Widget _buildNeonHeader() {
    return Positioned(
      top: 15,
      left: 15,
      right: 15,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Text(
                  "SKILL CONNECT",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Builder(
                  builder: (context) => GestureDetector(
                    onTap: () => Scaffold.of(context).openEndDrawer(),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🧩 BENTO FEED (MODERNIZED)
  Widget _buildModernFeed() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildVideoClip(
              "https://picsum.photos/600/1000?random=10", "Motion Graphics", "12k watching"),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildPostCard("https://picsum.photos/500/500?random=11", "Branding")),
              const SizedBox(width: 16),
              Expanded(child: _buildPostCard("https://picsum.photos/500/500?random=12", "UI UX")),
            ],
          ),
          const SizedBox(height: 20),
          _buildVideoClip(
              "https://picsum.photos/600/1000?random=13", "Cyberpunk Art", "5.2k likes"),
        ]),
      ),
    );
  }

  // 🎬 VIDEO CLIP (MODERNIZED)
  Widget _buildVideoClip(String url, String title, String stats) {
    return Container(
      height: 500,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: -10,
          )
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.network(url, fit: BoxFit.cover),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            left: 25,
            right: 25,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(stats, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                )
              ],
            ),
          ),
          // Live Badge
          Positioned(
            top: 20,
            left: 20,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text("LIVE",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🖼️ POST CARD (MODERNIZED)
  Widget _buildPostCard(String url, String label) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(url, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }

  // Logic remains identical to your provided code...
  Widget _buildDrawer() {
    // [DRAWER CODE PROVIDED IN YOUR PROMPT IS KEPT EXACTLY THE SAME]
    // ... Copy-paste your existing drawer code here ...
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      backgroundColor: AppColors.drawerBg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
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
                        child: ClipOval(child: AppAvatar(url: avatarUrl)),
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
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              role.isNotEmpty ? role.toUpperCase() : "DEVELOPER",
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Divider(color: Colors.white10)),
              _drawerItem(Icons.explore_outlined, "Explore", onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const UserSearchScreen()));
              }),
              _drawerItem(Icons.person_outline_rounded, "My Profile", onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
              }),
              _drawerItem(Icons.add_box_outlined, "Create Project", onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectCreatePage()));
              }),
              _drawerItem(Icons.grid_view_rounded, "My Projects", onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => MyProjectsPage()));
              }),
              _drawerItem(Icons.auto_stories_outlined, "Enrolled Courses", onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => MyCoursesListPage()));
              }),
              _drawerItem(Icons.settings_outlined, "Settings", onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => MyReelsPage()));
              }),
              const Spacer(),
              _drawerItem(Icons.logout_rounded, "Sign Out", isLogout: true, onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Rest of helper methods like _drawerItem, _logout, _showLogoutDialog...
  // [IDENTICAL TO YOUR LOGIC]
  Widget _drawerItem(IconData icon, String title, {required VoidCallback onTap, bool isLogout = false}) {
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
              Text(title, style: TextStyle(color: isLogout ? AppColors.error : AppColors.textPrimary.withOpacity(0.9), fontSize: 15, fontWeight: FontWeight.w500)),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: AppColors.textMuted))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text("Logout", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.setBool("remember_me", false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const NewLoginPage()), (route) => false);
  }
}