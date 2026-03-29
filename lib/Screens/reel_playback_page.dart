import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../Model/reel_model.dart';

class ReelPlaybackPage extends StatefulWidget {
  final List<Reel> reels;
  final int initialIndex;

  const ReelPlaybackPage({
    super.key,
    required this.reels,
    required this.initialIndex
  });

  @override
  State<ReelPlaybackPage> createState() => _ReelPlaybackPageState();
}

class _ReelPlaybackPageState extends State<ReelPlaybackPage> {
  late PageController _pageController;
  late int _focusedIndex;

  @override
  void initState() {
    super.initState();
    _focusedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Extends the video behind the status bar for a "Full Screen" look
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: PageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemCount: widget.reels.length,
          onPageChanged: (index) {
            setState(() {
              _focusedIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return FullScreenVideoPlayer(
              reel: widget.reels[index],
              isFocused: _focusedIndex == index,
            );
          },
        ),
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final Reel reel;
  final bool isFocused;

  const FullScreenVideoPlayer({
    super.key,
    required this.reel,
    required this.isFocused
  });

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.isFocused) {
      _initialize();
    }
  }

  @override
  void didUpdateWidget(FullScreenVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If this reel just came into focus, start the player
    if (widget.isFocused && _controller == null) {
      _initialize();
    }
    // If it lost focus, kill it immediately to free hardware codecs
    else if (!widget.isFocused && _controller != null) {
      _cleanup();
    }
  }

  Future<void> _initialize() async {
    // Standardizing the URL and creating the controller
    final String encodedUrl = Uri.encodeFull(widget.reel.reelUrl);
    _controller = VideoPlayerController.networkUrl(Uri.parse(encodedUrl));

    try {
      await _controller!.initialize();

      // Safety check: ensure the user hasn't scrolled away while loading
      if (mounted && widget.isFocused) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
        _controller!.setLooping(true);
        _controller!.play();
      } else {
        _cleanup();
      }
    } catch (e) {
      debugPrint("Video initialization failed: $e");
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  void _cleanup() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    if (mounted) {
      setState(() {
        _isInitialized = false;
      });
    }
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_controller != null && _controller!.value.isInitialized) {
          _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
          setState(() {}); // Update UI to show/hide play icon
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. The Video Layer
          if (_isInitialized && _controller != null)
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            )
          else if (_hasError)
            const Center(child: Icon(Icons.error, color: Colors.white, size: 40))
          else
            const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),

          // 2. Play Icon Overlay (Shows when paused)
          if (_isInitialized && _controller != null && !_controller!.value.isPlaying)
            const Center(child: Icon(Icons.play_arrow, color: Colors.white54, size: 80)),

          // 3. Info Overlay
          _buildUI(),
        ],
      ),
    );
  }

  Widget _buildUI() {
    return Positioned(
      bottom: 50,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "@User_${widget.reel.reelId}",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "Reel Description or views: ${widget.reel.views}",
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}