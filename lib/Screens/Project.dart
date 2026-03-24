import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../Constants/constants.dart';
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

  // Animation values
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
      debugPrint("Error fetching feed: $e");
    }
  }

  void _handleSwipe(String direction) {
    if (projects.isEmpty) return;

    setState(() {
      if (direction == "right") {
        _dragX = 600;
        if (_currentIndex < projects.length - 1) {
          _currentIndex++;
        } else {
          _fetchFeed();
        }
      } else if (direction == "left") {
        _dragX = -600;
        if (_currentIndex > 0) {
          _currentIndex--;
        }
      } else if (direction == "up") {
        _dragY = -800;
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            if (projects.isNotEmpty) {
              projects.removeAt(_currentIndex);
              if (_currentIndex >= projects.length && _currentIndex > 0) {
                _currentIndex--;
              }
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "DISCOVER PROJECTS",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 20),

            // The Card Area - Now uses Expanded to fill middle space
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.indigoAccent))
                  : projects.isEmpty
                  ? _buildEmptyState()
                  : _buildSwipeableCard(),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            if (projects.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                        icon: Icons.close,
                        color: Colors.white10,
                        onTap: () => _handleSwipe("left")),
                    _ActionButton(
                        icon: Icons.keyboard_double_arrow_up,
                        color: Colors.redAccent.withOpacity(0.8),
                        size: 75,
                        onTap: () => _handleSwipe("up")),
                    _ActionButton(
                        icon: Icons.favorite,
                        color: Colors.indigoAccent,
                        onTap: () => _handleSwipe("right")),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeableCard() {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _dragX += details.delta.dx;
          _dragY += details.delta.dy;
          _rotation = _dragX / 300;
        });
      },
      onPanEnd: (details) {
        if (_dragY < -150) {
          _handleSwipe("up");
        } else if (_dragX > 150) {
          _handleSwipe("right");
        } else if (_dragX < -150) {
          _handleSwipe("left");
        } else {
          setState(() {
            _dragX = 0;
            _dragY = 0;
            _rotation = 0;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(_dragX, _dragY)
          ..rotateZ(_rotation),
        child: _buildCardContent(),
      ),
    );
  }

  Widget _buildCardContent() {
    final project = projects[_currentIndex];

    // --- UPDATED LOGIC: RANDOM IMAGE ---
    // We use the project ID as a seed so each project gets a unique but consistent random image.
    // Width 600, Height 800 for a nice vertical card aspect ratio.
    String imageUrl = "https://picsum.photos/seed/${project.projectId}/600/800";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: GestureDetector(
            onDoubleTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectInfoPage(projectId: project.projectId)),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image takes the majority of the card space
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        // Loading state for the random image
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.white24),
                          );
                        },
                        errorBuilder: (ctx, err, stack) => _buildPlaceholderIcon(),
                      ),
                    ),
                  ),
                  // Content details section
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.title,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text("by ${project.username}",
                            style: const TextStyle(color: Colors.indigoAccent, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Text(project.description,
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 15),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: project.techStack.take(3).map((tech) => _buildMiniChip(tech)).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.white10,
      width: double.infinity,
      child: const Icon(Icons.code, color: Colors.white24, size: 50),
    );
  }

  Widget _buildMiniChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome_motion, size: 80, color: Colors.white24),
          const SizedBox(height: 20),
          const Text("No more projects found", style: TextStyle(color: Colors.white54, fontSize: 18)),
          TextButton(
            onPressed: _fetchFeed,
            child: const Text("Refresh Feed", style: TextStyle(color: Colors.indigoAccent)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.color, this.size = 60, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}