import 'dart:ui';
import 'package:flutter/material.dart';
import '../Model/globalFeed_model.dart';
import '../New/liked+projects.dart';
import '../Services/api-service.dart';
import '../New/project-info.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final ApiService _apiService = ApiService();
  List<GlobalFeed> projects = [];
  bool isLoading = true;
  int _currentIndex = 0;

  double _dragX = 0;
  double _dragY = 0;
  double _rotation = 0;

  @override
  void initState() {
    super.initState();
    _fetchFeed();
  }

  bool _isFilterOn = false;

  Future<void> _fetchFeed() async {
    setState(() => isLoading = true);
    try {
      // Pass the state to your API service
      final data = await _apiService.fetchGlobalFeed(filterBySkill: _isFilterOn);
      setState(() {
        projects = data;
        _currentIndex = 0; // Reset index when filter changes
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _handleSwipe(String direction) async {
    if (projects.isEmpty) return;

    final currentProject = projects[_currentIndex];

    setState(() {
      if (direction == "up") {
        _dragY = -800; // Visual swipe up
        _dragX = 0;
      } else if (direction == "left") {
        _dragX = -800; // Visual swipe left
        _dragY = 0;
      }
      _rotation = _dragX / 300;
    });

    // --- API Logic ---
    try {
      if (direction == "up") {
        // LIKE API
        await _apiService.toggleLikeProject(currentProject.projectId);
      } else if (direction == "left") {
        // DISCARD API (Now calling the service)
        await _apiService.discardProject(currentProject.projectId);
      }
    } catch (e) {
      debugPrint("API Error during swipe: $e");
    }

    // Animation Delay & Card Removal
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          projects.removeAt(_currentIndex);
          _dragX = 0;
          _dragY = 0;
          _rotation = 0;

          // Auto-refill if list is empty
          if (projects.isEmpty) {
            _fetchFeed();
          } else if (_currentIndex >= projects.length) {
            _currentIndex = projects.length - 1;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Colors.indigoAccent.withOpacity(0.05),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 15),
              _buildHeader(),
              const SizedBox(height: 15),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.indigoAccent, strokeWidth: 2))
                    : projects.isEmpty
                    ? _buildEmptyState()
                    : _buildSwipeableCard(),
              ),
              const SizedBox(height: 20),
              if (projects.isNotEmpty) _buildFooterActions(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "DISCOVER",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 4,
                ),
              )
            ],
          ),

          // Modern 3-Dot Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
            color: const Color(0xFF1A1A1A), // Dark background for the menu
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (value) {
              if (value == 'filter') {
                setState(() => _isFilterOn = !_isFilterOn);
                _fetchFeed();
              } else if (value == 'liked') {
                // NAVIGATE TO LIKED PROJECTS PAGE
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LikedProjectsPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    Icon(
                      _isFilterOn ? Icons.filter_alt : Icons.filter_alt_off,
                      color: _isFilterOn ? Colors.indigoAccent : Colors.white60,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isFilterOn ? "Skill Filter: ON" : "Skill Filter: OFF",
                      style: TextStyle(
                        color: _isFilterOn ? Colors.indigoAccent : Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              PopupMenuItem(
                value: 'liked',
                child: Row(
                  children: const [
                    Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 20),
                    SizedBox(width: 12),
                    Text(
                      "Liked Projects",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeableCard() {
    final project = projects[_currentIndex]; // Current project data

    return GestureDetector(
      // CARD PAR TAP KARNE PAR INFO PAGE KHULEGA
      onDoubleTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectInfoPage(projectId: project.projectId,),
          ),
        );
      },
      onPanUpdate: (details) {
        setState(() {
          _dragX += details.delta.dx;
          _dragY += details.delta.dy;
          _rotation = _dragX / 350;
        });
      },
      onPanEnd: (details) {
        if (_dragY < -150) _handleSwipe("up");
        else if (_dragX > 150) _handleSwipe("right");
        else if (_dragX < -150) _handleSwipe("left");
        else {
          setState(() {
            _dragX = 0;
            _dragY = 0;
            _rotation = 0;
          });
        }
      },
      child: AnimatedRotation(
        turns: _rotation / (2 * 3.14159),
        duration: Duration.zero,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..translate(_dragX, _dragY),
          child: _buildCardContent(),
        ),
      ),
    );
  }


  Widget _buildFilterToggle() {
    return GestureDetector(
      onTap: () {
        setState(() => _isFilterOn = !_isFilterOn);
        _fetchFeed(); // Refresh feed immediately on toggle
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 50,
            height: 20,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _isFilterOn ? Colors.indigoAccent : Colors.white.withOpacity(0.1),
              border: Border.all(
                color: _isFilterOn ? Colors.indigoAccent : Colors.white24,
              ),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: _isFilterOn ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "SKILL FILTER",
            style: TextStyle(
              color: _isFilterOn ? Colors.indigoAccent : Colors.white38,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCardContent() {
    final project = projects[_currentIndex];
    String imageUrl = "https://picsum.photos/seed/${project.projectId}/600/800";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              // Change shadow based on direction: Up = Green (Like), Left = Red (Pass)
              color: _dragY < -50
                  ? Colors.greenAccent.withOpacity(0.2)
                  : _dragX < -50
                  ? Colors.redAccent.withOpacity(0.2)
                  : Colors.black54,
              blurRadius: 30,
              spreadRadius: -5,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: Stack(
            children: [
              // 1. Background Image
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) =>
                  progress == null ? child : Container(color: Colors.white10),
                ),
              ),

              // 2. Content Overlay Gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Swipe Up "LIKE" Indicator (Visible during drag)
              if (_dragY < -100)
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: (_dragY.abs() / 400).clamp(0, 0.8),
                    duration: Duration.zero,
                    child: Container(
                      color: Colors.greenAccent.withOpacity(0.4),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite, color: Colors.white, size: 80),
                            const SizedBox(height: 10),
                            Text(
                              "LIKE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // 4. Swipe Left "PASS" Indicator
              if (_dragX < -100)
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: (_dragX.abs() / 400).clamp(0, 0.8),
                    duration: Duration.zero,
                    child: Container(
                      color: Colors.redAccent.withOpacity(0.4),
                      child: Center(
                        child: Icon(Icons.close_rounded, color: Colors.white, size: 80),
                      ),
                    ),
                  ),
                ),

              // 5. Project Details (Glass Footer)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildGlassFooter(project),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassFooter(GlobalFeed project) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(project.title,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                ),
                Icon(Icons.verified_rounded, color: Colors.indigoAccent, size: 20),
              ],
            ),
            Text("by @${project.username}",
                style: TextStyle(color: Colors.indigoAccent.withOpacity(0.9), fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            Text(project.description,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.4)),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              children: project.techStack.take(3).map((tech) => _buildModernChip(tech)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.indigoAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigoAccent.withOpacity(0.3)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFooterActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. DISCARD BUTTON (Left) - Permanent Pass
          _ModernActionButton(
            icon: Icons.close_rounded,
            color: Colors.white.withOpacity(0.05),
            iconColor: Colors.white54,
            onTap: () => _handleSwipe("left"),
          ),

          // 2. LIKE BUTTON (Center) - Swipe Up Animation
          _ModernActionButton(
            icon: Icons.favorite,
            color: Colors.redAccent.withOpacity(0.2),
            iconColor: Colors.redAccent,
            size: 80,
            glow: true,
            onTap: () => _handleSwipe("up"),
          ),

          // 3. NEXT BUTTON (Right) - Simply Move to Next Card
          _ModernActionButton(
            icon: Icons.arrow_forward_ios_rounded, // Modern arrow icon
            color: Colors.indigoAccent.withOpacity(0.1),
            iconColor: Colors.indigoAccent,
            onTap: () {
              setState(() {
                if (_currentIndex < projects.length - 1) {
                  _currentIndex++; // Move to next
                } else {
                  _fetchFeed(); // Refresh if at the end
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 60, color: Colors.indigoAccent.withOpacity(0.3)),
          const SizedBox(height: 20),
          const Text("ALL CAUGHT UP", style: TextStyle(color: Colors.white38, letterSpacing: 2, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: _fetchFeed,
            child: const Text("Refill Feed", style: TextStyle(color: Colors.indigoAccent)),
          ),
        ],
      ),
    );
  }
}

class _ModernActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final double size;
  final bool glow;
  final VoidCallback onTap;

  const _ModernActionButton({required this.icon, required this.color, required this.iconColor, this.size = 60, this.glow = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: iconColor.withOpacity(0.2), width: 1.5),
          boxShadow: [
            if (glow) BoxShadow(color: iconColor.withOpacity(0.2), blurRadius: 20, spreadRadius: 2)
          ],
        ),
        child: Icon(icon, color: iconColor, size: size * 0.45),
      ),
    );
  }
}