import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';
import '../Model/other_person_reel_model.dart'; // ✅ Correct Model Import
import '../Constants/constants.dart'; // Base URL ke liye

class ReelPlaybackPageOther extends StatefulWidget {
  final List<OtherPersonReel> reels;
  final String username;
  final String url;// ✅ Updated Model Name
  final int initialIndex;

  const ReelPlaybackPageOther({
    super.key,
    required this.reels,
    required this.username,
    required this.url,
    required this.initialIndex
  });

  @override
  State<ReelPlaybackPageOther> createState() => _ReelPlaybackPageOtherState();
}

class _ReelPlaybackPageOtherState extends State<ReelPlaybackPageOther> {
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
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
            isFocused: _focusedIndex == index, username: widget.username, url: widget.url,
          );
        },
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String username;
  final String url;// ✅ Updated Model Name
  final OtherPersonReel reel; // ✅ Updated Model Name
  final bool isFocused;

  const FullScreenVideoPlayer({
    super.key,
    required this.reel,
    required this.isFocused, required this.username, required this.url
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
    if (widget.isFocused && _controller == null) {
      _initialize();
    } else if (!widget.isFocused && _controller != null) {
      _stopAndReset();
    }
  }

  Future<void> _initialize() async {
    // ✅ URL Formatting: Base URL + reelUrl path
    final String fullUrl = "$baseUrlImage${widget.reel.reelUrl}";

    // Check if URL is valid
    _controller = VideoPlayerController.networkUrl(Uri.parse(fullUrl));

    try {
      await _controller!.initialize();
      if (mounted && widget.isFocused) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
        _controller!.setLooping(true);
        _controller!.play();
      }
    } catch (e) {
      debugPrint("Video initialization failed: $e");
      if (mounted) setState(() => _hasError = true);
    }
  }
  void _stopAndReset() {
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
    // ✅ Direct dispose without calling setState to fix the lifecycle error
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_controller != null && _controller!.value.isInitialized) {
          _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
          setState(() {});
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
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

          if (_isInitialized && _controller != null && !_controller!.value.isPlaying)
            const Center(child: Icon(Icons.play_arrow, color: Colors.white54, size: 80)),

          _buildUI(),
        ],
      ),
    );
  }

  Widget _buildUI() {
    final bool isSvg = widget.url.toLowerCase().endsWith('.svg');
    final String fullImageUrl = "$baseUrlImage${widget.url}";
    return Positioned(
      bottom: 50,
      left: 20,
      right: 70, // Padding for side buttons if needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[800],
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: ClipOval(
                  child: widget.url.isEmpty
                      ? const Icon(Icons.person, color: Colors.white, size: 20)
                      : isSvg
                      ? SvgPicture.network(
                    fullImageUrl,
                    fit: BoxFit.cover,
                    placeholderBuilder: (context) => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                      : Image.network(
                    fullImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.username,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.reel.caption,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.play_arrow, color: Colors.white, size: 16),
              Text(
                "${widget.reel.views} views",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}