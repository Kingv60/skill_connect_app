import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class YouTubePlayerPage extends StatefulWidget {
  final String videoUrl;
  final String title;

  const YouTubePlayerPage({super.key, required this.videoUrl, required this.title});

  @override
  State<YouTubePlayerPage> createState() => _YouTubePlayerPageState();
}

class _YouTubePlayerPageState extends State<YouTubePlayerPage> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  late String _currentUrl;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.videoUrl;
    _initializePlayer(_currentUrl);
  }

  void _initializePlayer(String url) async {
    setState(() => _chewieController = null);

    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      allowFullScreen: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.redAccent,
        handleColor: Colors.redAccent,
        backgroundColor: Colors.white10,
        bufferedColor: Colors.white30,
      ),
    );
    setState(() {});
  }

  void _onVideoSelected(String newUrl) {
    _videoController.dispose();
    _chewieController?.dispose();
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
      backgroundColor: const Color(0xff0f0f0f),
      body: Column(
        children: [
          /// 1. VIDEO PLAYER AREA
          _buildVideoHeader(),

          /// 2. CONTENT AREA
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildVideoInfo(),
                _buildActionButtons(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Up Next",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildSuggestedVideos(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoHeader() {
    return Stack(
      children: [
        // 1. THE PLAYER
        Container(
          width: double.infinity,
          color: Colors.black,
          child: SafeArea(
            bottom: false,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _chewieController != null && _videoController.value.isInitialized
                  ? Chewie(key: ValueKey(_currentUrl), controller: _chewieController!)
                  : const Center(child: CircularProgressIndicator(color: Colors.redAccent, strokeWidth: 2)),
            ),
          ),
        ),

        // 2. THE COMPACT BACK BUTTON
        Positioned(
          top: MediaQuery.of(context).padding.top + 8, // Adjusts for status bar
          left: 12,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(50),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Glass effect
                child: Container(
                  height: 36, // Fixed small size
                  width: 36,  // Fixed small size
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05), // Semi-transparent
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded, // Better "Minimize/Back" feel
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text("1.2M views", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.white38, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              const Text("Oct 2024", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _ModernPillButton(Icons.thumb_up_outlined, "12K", () {}),
          _ModernPillButton(Icons.thumb_down_outlined, "Dislike", () {}),
          _ModernPillButton(Icons.ios_share_rounded, "Share", () {}),
          _ModernPillButton(Icons.file_download_outlined, "Download", () {}),
          _ModernPillButton(Icons.playlist_add_rounded, "Save", () {}),
        ],
      ),
    );
  }

  Widget _buildSuggestedVideos() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => _onVideoSelected("https://your-api-link.mp4"),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                Stack(
                  children: [
                    Container(
                      width: 150,
                      height: 85,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white24, size: 30)),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                        child: const Text("12:45", style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 12),
                // Text Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mastering Course Logic Part ${index + 1}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Course Creator • 45K views",
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: Colors.white38, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModernPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ModernPillButton(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}