import 'package:flutter/material.dart';
import '../Model/reel_model.dart';
import '../Screens/reel_playback_page.dart';
import '../Services/api-service.dart';

class MyReelsPage extends StatefulWidget {
  const MyReelsPage({super.key});

  @override
  State<MyReelsPage> createState() => _MyReelsPageState();
}

class _MyReelsPageState extends State<MyReelsPage> {
  late Future<List<Reel>> _reelsFuture;

  @override
  void initState() {
    super.initState();
    _reelsFuture = ApiService().fetchMyReels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("My Reels",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: false,
      ),
      body: FutureBuilder<List<Reel>>(
        future: _reelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return _buildLoadingGrid();
          if (snapshot.hasError) return _buildErrorState();
          if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState();

          final reels = snapshot.data!;

          return RefreshIndicator(
            color: Colors.white,
            backgroundColor: Colors.grey[900],
            onRefresh: () async {
              setState(() {
                _reelsFuture = ApiService().fetchMyReels();
              });
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(2),
              itemCount: reels.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 9 / 16,
              ),
              itemBuilder: (context, index) {
                return _ReelGridItem(
                  reel: reels[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReelPlaybackPage(
                          reels: reels,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid() => GridView.builder(
    padding: const EdgeInsets.all(2),
    itemCount: 12,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2, childAspectRatio: 9 / 16),
    itemBuilder: (context, index) => Container(color: Colors.white10),
  );

  Widget _buildEmptyState() => const Center(
      child: Text("No reels yet", style: TextStyle(color: Colors.white54)));

  Widget _buildErrorState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.white24, size: 50),
        const SizedBox(height: 10),
        const Text("Failed to load reels", style: TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: () => setState(() => _reelsFuture = ApiService().fetchMyReels()),
          child: const Text("Retry", style: TextStyle(color: Colors.blue)),
        ),
      ],
    ),
  );
}

/// -------------------------------
/// INDIVIDUAL GRID ITEM
/// -------------------------------
class _ReelGridItem extends StatelessWidget {
  final Reel reel;
  final VoidCallback onTap;

  const _ReelGridItem({required this.reel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // OPTIMIZATION: Removed VideoPlayer from grid.
          // Using a colored container with an icon is 100% stable.
          // In a real app, use: Image.network(reel.thumbnailUrl, fit: BoxFit.cover)
          Container(
            color: Colors.grey[900],
            child: const Center(
              child: Icon(Icons.play_arrow_rounded, color: Colors.white10, size: 40),
            ),
          ),

          // 2. Gradient Overlay for readability
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
                stops: [0.6, 1.0],
              ),
            ),
          ),

          // 3. View Count
          Positioned(
            bottom: 8, left: 8,
            child: Row(
              children: [
                const Icon(Icons.play_arrow_outlined, color: Colors.white, size: 14),
                const SizedBox(width: 2),
                Text(
                  _formatCount(reel.views),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}