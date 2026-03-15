import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerPage extends StatefulWidget {
  final String title;
  final String videoUrl;

  const VideoPlayerPage({
    super.key,
    required this.title,
    required this.videoUrl,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  late String _currentTitle;
  late String _currentUrl;

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.title;
    _currentUrl = widget.videoUrl;
    _initializePlayer(_currentUrl);
  }

  void _initializePlayer(String url) async {
    // Show loading while switching
    setState(() => _chewieController = null);

    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));

      await _videoController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoController.value.aspectRatio,
        allowFullScreen: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red, // Classic YouTube red
          handleColor: Colors.red,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white54,
        ),
      );

      setState(() {});
    } catch (e) {
      debugPrint("VIDEO ERROR: $e");
    }
  }

  void _changeVideo(String newUrl, String newTitle) async {
    if (_currentUrl == newUrl) return; // Don't reload if it's the same

    // Clean up current controllers
    await _videoController.pause();
    _videoController.dispose();
    _chewieController?.dispose();

    setState(() {
      _currentUrl = newUrl;
      _currentTitle = newTitle;
    });

    _initializePlayer(newUrl);
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f0f0f), // Deep black background
      body: SafeArea(
        child: Column(
          children: [
            /// 🎥 VIDEO SECTION
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _chewieController != null &&
                      _videoController.value.isInitialized
                      ? Chewie(
                    key: ValueKey(_currentUrl), // Fixes rendering issues
                    controller: _chewieController!,
                  )
                      : Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    ),
                  ),
                ),
                Positioned(
                  top: 5,
                  left: 5,
                  child: IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),

            /// 📜 CONTENT SECTION
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  Text(
                    _currentTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "1.2M views • 2 days ago",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),

                  const SizedBox(height: 20),

                  /// ACTION BUTTONS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: const [
                        _ActionIcon(Icons.thumb_up_alt_outlined, "125K"),
                        SizedBox(width: 25),
                        _ActionIcon(Icons.thumb_down_alt_outlined, "Dislike"),
                        SizedBox(width: 25),
                        _ActionIcon(Icons.share_outlined, "Share"),
                        SizedBox(width: 25),
                        _ActionIcon(Icons.download_outlined, "Download"),
                        SizedBox(width: 25),
                        _ActionIcon(Icons.playlist_add, "Save"),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white12, height: 35),

                  /// SUGGESTED LIST
                  const Text(
                    "Suggested",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 15),

                  ...List.generate(6, (index) {
                    final lessonTitle = "Advanced Flutter Course - Part ${index + 2}";
                    return InkWell(
                      onTap: () {
                        _changeVideo(
                          "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
                          lessonTitle,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 140,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.play_circle_outline, color: Colors.white24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lessonTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "SkillConnect • 45K views",
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionIcon(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}