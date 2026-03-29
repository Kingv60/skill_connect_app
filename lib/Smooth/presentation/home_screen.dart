import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../ChatList.dart';
import '../../New/my_all_project.dart';
import '../../New/my_enrolled_course.dart';
import '../../Screens/project-create.dart';
import '../../Screens/user_search.dart';
import '../../profile.dart';
import '../bloc/home/home_bloc.dart';
import 'new_login_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(LoadHomeData()),
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        endDrawer: const HomeDrawer(),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return SafeArea(
              child: Stack(
                children: [
                  /// BODY
                  if (state is HomeLoading || state is HomeInitial)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF8F94FB)))
                  else if (state is HomeError)
                    _buildRetryView(context)
                  else if (state is HomeLoaded)
                      SafeArea(
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            const SliverToBoxAdapter(child: SizedBox(height: 70)),
                            _buildModernFeed(),
                            const SliverToBoxAdapter(child: SizedBox(height: 10)),
                          ],
                        ),
                      ),

                  /// HEADER
                  _buildNeonHeader(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRetryView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Failed to load data", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => context.read<HomeBloc>().add(LoadHomeData()),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildNeonHeader(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text("SKILL CONNECT",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 15)),
                const Spacer(),
                Builder(
                  builder: (context) => GestureDetector(
                    onTap: () => Scaffold.of(context).openEndDrawer(),
                    child: const Icon(Icons.menu, color: Colors.white, size: 26),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernFeed() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildVideoClip("https://picsum.photos/600/1000?random=10", "Motion Graphics", "12k watching"),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildPostCard("https://picsum.photos/500/500?random=11", "Branding")),
              const SizedBox(width: 16),
              Expanded(child: _buildPostCard("https://picsum.photos/500/500?random=12", "UI UX")),
            ],
          ),
          const SizedBox(height: 24),
          _buildVideoClip("https://picsum.photos/600/1000?random=13", "Cyberpunk Art", "5.2k likes"),
        ]),
      ),
    );
  }

  Widget _buildVideoClip(String url, String title, String stats) {
    return Container(
      height: 550,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(38), child: Image.network(url, fit: BoxFit.cover)),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(38),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.6, 1.0],
                  colors: [Colors.transparent, Colors.black.withOpacity(0.9)]),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
                  child: const Text("LIVE",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
                const SizedBox(height: 10),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                Text(stats, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(String url, String label) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: Image.network(url, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }
}

/// --- SEPARATE DRAWER WIDGET ---
class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final profile = (state is HomeLoaded) ? state.profile : null;

        return Drawer(
          width: MediaQuery.of(context).size.width * 0.8,
          backgroundColor: const Color(0xFF111111),
          child: Column(
            children: [
              DrawerHeader(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.transparent,
                          child: ClipOval(
                            child: SizedBox(
                              width: 70, height: 70,
                              child: AppAvatar(url: profile?.avatarUrl ?? ""),
                            ),
                          )),
                      const SizedBox(height: 15),
                      Text(profile?.name ?? "User",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(profile?.role ?? "Developer", style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
              _drawerItem(context, Icons.search, "Search", () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const UserSearchScreen()));
              }),
              _drawerItem(context, Icons.person, "Profile", () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
              }),
              _drawerItem(context, Icons.add_box, "Projects Create", () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectCreatePage()));
              }),
              _drawerItem(context, Icons.check_box_outline_blank_outlined, "My Projects", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => MyProjectsPage()));
              }),
              _drawerItem(context, Icons.check_box_outline_blank_outlined, "My Enrolled Courses", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => MyCoursesListPage()));
              }),
              _drawerItem(context, Icons.settings, "Settings", () {}),
              const Spacer(),
              const Divider(color: Colors.white12),
              _drawerItem(context, Icons.logout, "Logout", () => _showLogoutDialog(context), isLogout: true),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.redAccent : Colors.white),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.redAccent : Colors.white)),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove("token");
              await prefs.setBool("remember_me", false);
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const NewLoginPage()), (route) => false);
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}