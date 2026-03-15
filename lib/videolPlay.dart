  import 'package:flutter/material.dart';
import 'package:skillconnect/videoPlayer.dart';

  class DarkCreatorProfile extends StatelessWidget {
    const DarkCreatorProfile({super.key});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.black, // Pure black background
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          leading: const BackButton(color: Colors.white),
        ),
        body: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Profile Identity
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Alex Rivera",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const Text(
                          "Expert UI Designer • 12 Courses",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 20),

                        // JOIN BUTTON (High Contrast)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, // White button on black background
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "JOIN NOW",
                              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
                // Sticky TabBar with Dark Styling
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    const TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white38,
                      indicatorColor: Colors.white,
                      indicatorWeight: 2,
                      tabs: [
                        Tab(text: "COURSES"),
                        Tab(text: "VIDEOS"),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                _buildCourseGrid(),
                _buildVideoList(),
              ],
            ),
          ),
        ),
      );
    }

    Widget _buildCourseGrid() {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white10, // Dark grey card
                  image: const DecorationImage(
                    image: NetworkImage('https://via.placeholder.com/300x200'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Advanced UI Masterclass",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              maxLines: 2,
            ),
            const Text("15 Lessons", style: TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      );
    }

    Widget _buildVideoList() {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) => GestureDetector(onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VideoPlayerPage(title: "Course Lesson 1", videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',),
            ),
          );
        },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(width: 110, height: 65, color: Colors.white10),
            ),
            title: Text("Course Lesson $index", style: const TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: const Text("10:00 • Full HD", style: TextStyle(color: Colors.white38, fontSize: 12)),
            trailing: const Icon(Icons.play_arrow_rounded, color: Colors.white70),
          ),
        ),
      );
    }
  }

  class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
    _SliverAppBarDelegate(this._tabBar);
    final TabBar _tabBar;
    @override double get minExtent => _tabBar.preferredSize.height;
    @override double get maxExtent => _tabBar.preferredSize.height;
    @override
    Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
      return Container(color: Colors.black, child: _tabBar);
    }
    @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
  }