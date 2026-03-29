import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:skillconnect/Services/api-service.dart';
import 'package:video_player/video_player.dart';
import '../Model/reel_model.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final ApiService _reelService = ApiService();
  late PageController _pageController;

  List<Reel> _reels = [];
  final Map<int, VideoPlayerController> _controllers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadReels();
  }

  Future<void> _loadReels() async {
    try {
      final fetchedReels = await _reelService.fetchReels();
      setState(() {
        _reels = fetchedReels;
        _isLoading = false;
      });
      if (_reels.isNotEmpty) {
        _initializeController(0);
      }
    } catch (e) {
      debugPrint("Error loading reels: $e");
      setState(() => _isLoading = false);
    }
  }

  void _initializeController(int index) {
    if (_controllers.containsKey(index)) return;

    final String fullUrl = _reels[index].reelUrl;
    final controller = VideoPlayerController.networkUrl(Uri.parse(fullUrl))
      ..initialize().then((_) {
        setState(() {});
      })
      ..setLooping(true);

    _controllers[index] = controller;
    if (index == 0) controller.play();
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2)),
      );
    }

    if (_reels.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text("No reels found", style: TextStyle(color: Colors.white38))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _reels.length,
        onPageChanged: (index) {
          if (index + 1 < _reels.length) _initializeController(index + 1);
          _controllers.forEach((i, controller) {
            if (i == index) {
              controller.play();
            } else {
              controller.pause();
              controller.seekTo(Duration.zero);
            }
          });
        },
        itemBuilder: (context, index) {
          final reel = _reels[index];
          final controller = _controllers[index];

          return Stack(
            fit: StackFit.expand,
            children: [
              /// 🎥 FULLSCREEN VIDEO
              controller != null && controller.value.isInitialized
                  ? GestureDetector(
                onTap: () {
                  controller.value.isPlaying ? controller.pause() : controller.play();
                  setState(() {});
                },
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              )
                  : const Center(child: CircularProgressIndicator(color: Colors.white24)),

              /// 🔲 MODERN SOFT GRADIENT
              IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.2, 0.7, 1.0],
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),

              /// 📌 RIGHT ACTION PILLS
              Positioned(
                right: 12,
                bottom: 100,
                child: Column(
                  children: [
                    _buildAvatarPill(reel.name),
                    const SizedBox(height: 25),
                    _actionIcon(Icons.favorite_rounded, "${reel.likes}", Colors.redAccent),
                    const SizedBox(height: 20),
                    _actionIcon(Icons.chat_bubble_rounded, "12", Colors.white),
                    const SizedBox(height: 20),
                    _actionIcon(Icons.ios_share_rounded, "Share", Colors.white),
                    const SizedBox(height: 20),
                    _actionIcon(Icons.more_horiz_rounded, "", Colors.white),
                  ],
                ),
              ),

              /// 📝 BOTTOM METADATA
              Positioned(
                left: 16,
                bottom: 40,
                right: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "@${reel.name.toLowerCase().replaceAll(' ', '_')}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.verified, color: Colors.blueAccent, size: 16),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reel.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Modern "Music/Audio" tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.music_note_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 5),
                          Text("Original Audio", style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatarPill(String name) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.white10,
        child: Text(name[0], style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _actionIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        // Subtle glow effect for icons
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(blurRadius: 4, color: Colors.black)],
            ),
          ),
        ]
      ],
    );
  }
}