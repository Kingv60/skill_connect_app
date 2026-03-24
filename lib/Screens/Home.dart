import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillconnect/Constants/constants.dart';
import 'package:skillconnect/New/my_all_project.dart';
import 'package:skillconnect/New/my_enrolled_course.dart';
import 'package:skillconnect/Screens/project-create.dart';
import 'package:skillconnect/profile.dart';

import '../New/login-page.dart';
import '../New/other_person_profile.dart';
import '../Provider/profile_provider.dart';
import '../Provider/search_provider.dart';


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
  bool isLoading = true;


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
          setState(() {
            showRetry = true;
          });
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

      /// Drawer ALWAYS AVAILABLE
      endDrawer: _buildDrawer(),

      body: SafeArea(
        child: Stack(
          children: [
        
            /// BODY
            profile == null
                ? Center(
              child: showRetry
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Failed to load data",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showRetry = false;
                      });
        
                      ref.read(profileProvider.notifier).loadProfile();
        
                      Future.delayed(const Duration(seconds: 5), () {
                        if (mounted && ref.read(profileProvider) == null) {
                          setState(() {
                            showRetry = true;
                          });
                        }
                      });
                    },
                    child: const Text("Retry"),
                  ),
                ],
              )
                  : const CircularProgressIndicator(),
            )
                : SafeArea(
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
            _buildNeonHeader(),
          ],
        ),
      ),
    );
  }

  // 🌌 NEON HEADER
  Widget _buildNeonHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [





                const Text(
                  "SKILL CONNECT",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 15,
                  ),
                ),
                Spacer(),
                Builder(
                  builder: (context) => GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    child: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 26,
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

  // 🧩 BENTO FEED
  Widget _buildModernFeed() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildVideoClip(
              "https://picsum.photos/600/1000?random=10",
              "Motion Graphics",
              "12k watching"),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                  child: _buildPostCard(
                      "https://picsum.photos/500/500?random=11",
                      "Branding")),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildPostCard(
                      "https://picsum.photos/500/500?random=12",
                      "UI UX")),
            ],
          ),
          const SizedBox(height: 24),

          _buildVideoClip(
              "https://picsum.photos/600/1000?random=13",
              "Cyberpunk Art",
              "5.2k likes"),
        ]),
      ),
    );
  }

  // 🎬 VIDEO CLIP
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
          ClipRRect(
            borderRadius: BorderRadius.circular(38),
            child: Image.network(url, fit: BoxFit.cover),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(38),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.6, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.9)
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("LIVE",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10)),
                ),
                const SizedBox(height: 10),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
                Text(stats,
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🖼️ POST CARD
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
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(30)),
              child: Image.network(url,
                  fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  // 🔥 DRAWER
  Widget _buildDrawer() {

    Future<void> _logout() async {
      final prefs = await SharedPreferences.getInstance();

      // Remove token
      await prefs.remove("token");

      // Reset remember me to false (important)
      await prefs.setBool("remember_me", false);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const NewLoginPage()),
            (route) => false,
      );
    }
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      backgroundColor: const Color(0xFF111111),
      child: Column(
        children: [

          DrawerHeader(
            decoration: const BoxDecoration(

            ),
            child: SizedBox(width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:  [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: AppAvatar(url: avatarUrl),
                      ),
                    )
                  ),
                  SizedBox(height: 15),
                  Text(
                    name.isNotEmpty ? name : "User",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    role.isNotEmpty ? role : "Developer",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          _drawerItem(
            Icons.search,
            "Search",
            onTap: () {
              Navigator.pop(context); // Close Drawer
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserSearchScreen())
              );
            },
          ),
          _drawerItem(
            Icons.person,
            "Profile",
            onTap: () {
              Navigator.pop(context); // close drawer first
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  ProfilePage(),
                ),
              );
            },
          ),
          _drawerItem(Icons.add_box, "Projects Create",onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ProjectCreatePage()));// close drawer first
          },),
          _drawerItem(
            Icons.check_box_outline_blank_outlined,
            "My Projects",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>MyProjectsPage())); // close drawer first
            },
          ),
          _drawerItem(
            Icons.check_box_outline_blank_outlined,
            "My Enrolled Courses",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>MyCoursesListPage())); // close drawer first
            },
          ),
          _drawerItem(Icons.settings, "Settings"),

          const Spacer(),
          const Divider(color: Colors.white12),

          _drawerItem(
            Icons.logout,
            "Logout",
            isLogout: true,
            onTap: () {
              Navigator.pop(context); // close drawer first

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _drawerItem(
      IconData icon,
      String title, {
        bool isLogout = false,
        VoidCallback? onTap,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.redAccent : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.redAccent : Colors.white,
        ),
      ),
      onTap: onTap ??
              () {
            Navigator.pop(context);
          },
    );
  }

}



class UserSearchScreen extends ConsumerWidget {
  const UserSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(chatSearchProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(10),
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 1, color: Colors.white),
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ),

        title: _buildSearchBar(ref),
      ),
      body: searchResults.isEmpty
          ? const Center(child: Text("Search for creators", style: TextStyle(color: Colors.white54)))
          : _buildResultsList(searchResults),
    );
  }

  // 🔍 THE CHAT-STYLE SEARCH BAR
  Widget _buildSearchBar(WidgetRef ref) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Dark grey like Chat List
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        onChanged: (value) => ref.read(chatSearchProvider.notifier).searchUsers(value),
        decoration: const InputDecoration(
          hintText: "Search creators...",
          hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.white38, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  // 📝 RESULTS LIST
  Widget _buildResultsList(List<dynamic> results) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final user = results[index];

        // 1. Fix Localhost and handle URL formatting
        String avatarUrl = user['avatar'] ?? "";
        if (avatarUrl.contains("localhost")) {
          avatarUrl = avatarUrl;
        }
        // Ensure it has the full http prefix if it's just a path
        if (!avatarUrl.startsWith("http") && avatarUrl.isNotEmpty) {
          avatarUrl = baseUrlImage+avatarUrl;
        }

        return ListTile(
          onTap: () {
            // Ensure we extract the ID correctly from the search response
            final userId = results[index]['user_id'];

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtherPersonProfile(userId: int.parse(userId.toString())),
              ),
            );
          },
          leading: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF1A1A1A),
            ),
            child: ClipOval(
              child: avatarUrl.toLowerCase().endsWith(".svg")
                  ? SvgPicture.network(
               avatarUrl,
                fit: BoxFit.cover,
                placeholderBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
                  : Image.network(

                avatarUrl.isNotEmpty ? baseUrl+avatarUrl : "https://picsum.photos/200",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.person, color: Colors.white38),
              ),
            ),
          ),
          title: Text(
            user['name'] ?? "User",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "@${user['username'] ?? 'creator'}",
            style: const TextStyle(color: Color(0xFF8F94FB), fontSize: 12),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
        );
      },
    );
  }
}