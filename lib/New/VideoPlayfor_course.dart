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
    // Show a small loader while switching videos
    setState(() => _chewieController = null);

    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      allowFullScreen: true,
      // YouTube-style red progress bar
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.red,
        handleColor: Colors.red,
        backgroundColor: Colors.white24,
        bufferedColor: Colors.white54,
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xff0f0f0f), // YouTube Dark Mode black
      body: SafeArea(
        child: Column(
          children: [
            /// 1. FIXED VIDEO PLAYER (Always at top)
            _buildVideoHeader(),

            /// 2. SCROLLABLE DETAILS AND SUGGESTIONS
            Expanded(
              child: ListView(
                children: [
                  _buildVideoInfo(),
                  const Divider(color: Colors.white10),
                  _buildActionButtons(),
                  const Divider(color: Colors.white10),
                  _buildSuggestedVideos(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoHeader() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: _chewieController != null && _videoController.value.isInitialized
          ? Chewie(key: ValueKey(_currentUrl), controller: _chewieController!)
          : const Center(child: CircularProgressIndicator(color: Colors.red)),
    );
  }

  Widget _buildVideoInfo() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("1.5M views • 3 hours ago", style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionButton(Icons.thumb_up_alt_outlined, "240K"),
          _ActionButton(Icons.thumb_down_alt_outlined, "Dislike"),
          _ActionButton(Icons.share, "Share"),
          _ActionButton(Icons.download, "Download"),
        ],
      ),
    );
  }

  Widget _buildSuggestedVideos() {
    return ListView.builder(
      shrinkWrap: true, // Needed inside another ListView
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () => _onVideoSelected("https://your-api-link.mp4"),
          leading: Container(
            width: 120, height: 70,
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.play_arrow, color: Colors.white24),
          ),
          title: Text("Suggested Lesson #$index", style: const TextStyle(color: Colors.white, fontSize: 14)),
          subtitle: const Text("Creator Name • 500K views", style: TextStyle(color: Colors.white38, fontSize: 12)),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionButton(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}