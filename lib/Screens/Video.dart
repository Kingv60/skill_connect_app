import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final List<String> videoUrls = [
    "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
    "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
    "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
  ];

  late PageController _pageController;
  final List<VideoPlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    for (var url in videoUrls) {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          setState(() {});
        })
        ..setLooping(true)
        ..play();

      _controllers.add(controller);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: videoUrls.length,
        onPageChanged: (index) {
          for (int i = 0; i < _controllers.length; i++) {
            if (i == index) {
              _controllers[i].play();
            } else {
              _controllers[i].pause();
            }
          }
        },
        itemBuilder: (context, index) {
          return Stack(
            children: [
              /// 🎥 VIDEO
              _controllers[index].value.isInitialized
                  ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controllers[index].value.size.width,
                    height: _controllers[index].value.size.height,
                    child: VideoPlayer(_controllers[index]),
                  ),
                ),
              )
                  : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

              /// 🔲 GRADIENT OVERLAY
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              /// 📌 RIGHT ACTIONS
              Positioned(
                right: 15,
                bottom: 100,
                child: Column(
                  children: [
                    _iconButton(Icons.favorite, "12.3K"),
                    const SizedBox(height: 20),
                    _iconButton(Icons.comment, "421"),
                    const SizedBox(height: 20),
                    _iconButton(Icons.share, "Share"),
                  ],
                ),
              ),

              /// 📝 CAPTION
              Positioned(
                left: 15,
                bottom: 40,
                right: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:  [
                    GestureDetector(onTap: (){
                    },
                      child: Text(
                        "@Eagle_007",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Flutter reels UI 🔥 #flutter #reels #mobiledev",
                      style: TextStyle(color: Colors.white),
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

  Widget _iconButton(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
