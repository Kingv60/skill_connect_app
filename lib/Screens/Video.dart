import 'package:flutter/material.dart';
import 'package:skillconnect/New/other_person_profile.dart';
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
  int _currentIndex = 0;

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
      if (_reels.isNotEmpty) _initializeController(0);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _initializeController(int index) {
    if (_controllers.containsKey(index)) return;
    final controller = VideoPlayerController.networkUrl(Uri.parse(_reels[index].reelUrl))
      ..initialize().then((_) => setState(() {}))
      ..setLooping(true);
    _controllers[index] = controller;
    if (index == 0) controller.play();
  }

  void _handleLike(int index) async {
    final reel = _reels[index];
    try {
      final response = await _reelService.toggleLikeReel(reel.reelId);
      setState(() {
        reel.isLiked = response['liked'];
        reel.likesCount = response['liked'] ? reel.likesCount + 1 : reel.likesCount - 1;
      });
    } catch (e) {
      debugPrint("Like error: $e");
    }
  }

  void _showComments(int reelId, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentSection(
        reelId: reelId,
        apiService: _reelService,
        onCommentAdded: () => setState(() => _reels[index].commentsCount++),
      ),
    );
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    if (_reels.isEmpty) return const Scaffold(backgroundColor: Colors.black, body: Center(child: Text("No reels found", style: TextStyle(color: Colors.white))));

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _reels.length,
        onPageChanged: (index) {
          // --- VIEW TRACKING LOGIC ---
          if (_reels.isNotEmpty && _controllers.containsKey(_currentIndex)) {
            final lastReel = _reels[_currentIndex];
            final controller = _controllers[_currentIndex];

            if (controller != null) {
              int watchedSeconds = controller.value.position.inSeconds;
              if (watchedSeconds > 0) {
                _reelService.updateReelView(lastReel.reelId, watchedSeconds);
              }
            }
          }

          _currentIndex = index;
          if (index + 1 < _reels.length) _initializeController(index + 1);
          _controllers.forEach((i, c) {
            if (i == index) c.play();
            else { c.pause(); c.seekTo(Duration.zero); }
          });
        },
        itemBuilder: (context, index) {
          final reel = _reels[index];
          final controller = _controllers[index];

          return Stack(
            fit: StackFit.expand,
            children: [
              controller != null && controller.value.isInitialized
                  ? GestureDetector(
                onTap: () => setState(() => controller.value.isPlaying ? controller.pause() : controller.play()),
                child: FittedBox(fit: BoxFit.cover, child: SizedBox(width: controller.value.size.width, height: controller.value.size.height, child: VideoPlayer(controller))),
              )
                  : const Center(child: CircularProgressIndicator()),

              IgnorePointer(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black54, Colors.transparent, Colors.transparent, Colors.black87])))),

              // Action Sidebar
              Positioned(
                right: 15, bottom: 100,
                child: Column(
                  children: [
                    // View Count Display (Eye Icon)
                    _actionIcon(Icons.remove_red_eye_outlined, "${reel.views}", Colors.white),
                    const SizedBox(height: 20),


                    // Like Button
                    GestureDetector(onTap: () => _handleLike(index), child: _actionIcon(reel.isLiked ? Icons.favorite : Icons.favorite_border, "${reel.likesCount}", reel.isLiked ? Colors.red : Colors.white)),
                    const SizedBox(height: 20),

                    // Comment Button
                    GestureDetector(onTap: () => _showComments(reel.reelId, index), child: _actionIcon(Icons.comment, "${reel.commentsCount}", Colors.white)),
                    const SizedBox(height: 20),

                    // Share Button
                    _actionIcon(Icons.share, "Share", Colors.white),
                  ],
                ),
              ),

              // Metadata Info
              Positioned(
                left: 16, bottom: 20, right: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Tap Navigation
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OtherPersonProfile(userId: reel.userId))),
                      child: Row(
                        children: [
                          GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OtherPersonProfile(userId: reel.userId))),
                              child: _buildAvatarPill(reel.name)
                          ),
                          SizedBox(width: 10,),
                          Text(
                              "@${reel.name.toLowerCase().replaceAll(' ', '_')}",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(reel.caption, style: const TextStyle(color: Colors.white, fontSize: 14)),
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
    return Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)), child: CircleAvatar(radius: 15, backgroundColor: Colors.blueAccent, child: Text(name[0], style: const TextStyle(color: Colors.white))));
  }

  Widget _actionIcon(IconData icon, String label, Color color) {
    return Column(children: [Icon(icon, color: color, size: 30), const SizedBox(height: 4), Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))]);
  }
}

class _CommentSection extends StatefulWidget {
  final int reelId;
  final ApiService apiService;
  final VoidCallback onCommentAdded;
  const _CommentSection({required this.reelId, required this.apiService, required this.onCommentAdded});

  @override
  State<_CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<_CommentSection> {
  final TextEditingController _ctrl = TextEditingController();
  List<dynamic> _comments = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  void _load() async {
    try {
      final d = await widget.apiService.getReelComments(widget.reelId);
      if (mounted) setState(() { _comments = d; _loading = false; });
    } catch (e) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          const SizedBox(height: 15),
          const Text("Comments", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white10),
          Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : ListView.builder(itemCount: _comments.length, itemBuilder: (c, i) => ListTile(
              leading: const CircleAvatar(radius: 15, backgroundColor: Colors.white10, child: Icon(Icons.person, size: 18, color: Colors.white70)),
              title: Text(_comments[i]['name'] ?? "User", style: const TextStyle(color: Colors.white70, fontSize: 12)),
              subtitle: Text(_comments[i]['comment_text'] ?? "", style: const TextStyle(color: Colors.white))
          ))),
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 10, right: 10, top: 10),
            child: Row(children: [
              Expanded(child: TextField(controller: _ctrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Add comment...", hintStyle: const TextStyle(color: Colors.white38), filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none)))),
              IconButton(onPressed: () async {
                if (_ctrl.text.isEmpty) return;
                await widget.apiService.addComment(widget.reelId, _ctrl.text);
                _ctrl.clear(); _load(); widget.onCommentAdded();
              }, icon: const Icon(Icons.send, color: Colors.blue))
            ]),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}