import 'dart:ui';
import 'package:flutter/material.dart';
import '../Model/globalFeed_model.dart';
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

  Future<void> _fetchFeed() async {
    setState(() => isLoading = true);
    try {
      final data = await _apiService.fetchGlobalFeed();
      setState(() {
        projects = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _handleSwipe(String direction) {
    if (projects.isEmpty) return;

    setState(() {
      if (direction == "right") {
        _dragX = 600;
        if (_currentIndex < projects.length - 1) _currentIndex++;
        else _fetchFeed();
      } else if (direction == "left") {
        _dragX = -600;
        if (_currentIndex > 0) _currentIndex--;
      } else if (direction == "up") {
        _dragY = -800;
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            if (projects.isNotEmpty) {
              projects.removeAt(_currentIndex);
              if (_currentIndex >= projects.length && _currentIndex > 0) _currentIndex--;
            }
          });
        });
      }
      _rotation = _dragX / 300;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _dragX = 0;
          _dragY = 0;
          _rotation = 0;
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
    return Column(
      children: [
        Text(
          "DISCOVER PROJECTS",
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 2,
          width: 30,
          decoration: BoxDecoration(
            color: Colors.indigoAccent,
            borderRadius: BorderRadius.circular(10),
          ),
        )
      ],
    );
  }

  Widget _buildSwipeableCard() {
    return GestureDetector(
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
              color: _dragX > 0
                  ? Colors.greenAccent.withOpacity(0.1)
                  : _dragX < 0 ? Colors.redAccent.withOpacity(0.1) : Colors.black,
              blurRadius: 30,
              spreadRadius: -10,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) =>
                  progress == null ? child : Container(color: Colors.white.withOpacity(0.05)),
                ),
              ),
              // Content Overlay
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
              // Details
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
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ModernActionButton(
            icon: Icons.close_rounded,
            color: Colors.white.withOpacity(0.05),
            iconColor: Colors.white54,
            onTap: () => _handleSwipe("left"),
          ),
          _ModernActionButton(
            icon: Icons.rocket_launch_rounded,
            color: Colors.redAccent.withOpacity(0.2),
            iconColor: Colors.redAccent,
            size: 75,
            glow: true,
            onTap: () => _handleSwipe("up"),
          ),
          _ModernActionButton(
            icon: Icons.favorite_rounded,
            color: Colors.indigoAccent.withOpacity(0.2),
            iconColor: Colors.indigoAccent,
            onTap: () => _handleSwipe("right"),
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