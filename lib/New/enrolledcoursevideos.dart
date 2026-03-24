import 'package:flutter/material.dart';
import 'package:skillconnect/Constants/constants.dart';
import 'package:skillconnect/Services/api-service.dart';
import 'VideoPlayfor_course.dart';

class EnrolledCourseLessonsPage extends StatelessWidget {
  final int course_id;
  final String courseTitle;

  const EnrolledCourseLessonsPage({
    super.key,
    required this.course_id,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f0f0f),
      appBar: AppBar(
        backgroundColor: const Color(0xff0f0f0f),
        elevation: 0,
        title: Text(
          courseTitle,
          style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService().getVideosByCourse(course_id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          final List<dynamic> videos = snapshot.data ?? [];

          if (videos.isEmpty) {
            return const Center(
              child: Text("No lessons uploaded yet.", style: TextStyle(color: Colors.white54)),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "${videos.length} Lessons Available",
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                ),
              ),

              const Divider(color: Colors.white12),

              Expanded(
                child: ListView.builder(
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    return _buildLessonTile(context, video, index + 1);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLessonTile(BuildContext context, dynamic video, int displayIndex) {
    final String thumbUrl = "$baseUrlImage${video['thumbnail_url']}";
    final String videoUrl = "$baseUrlImage${video['video_url']}";
    final String title = video['title'] ?? "Lesson $displayIndex";

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => YouTubePlayerPage(
              videoUrl: videoUrl,
              title: title,
            ),
          ),
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              thumbUrl,
              width: 100,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, e, s) => Container(
                width: 100, height: 60, color: Colors.grey[900],
                child: const Icon(Icons.play_circle_fill, color: Colors.white24),
              ),
            ),
          ),
          const Icon(Icons.play_circle_fill, color: Colors.white70, size: 30),
        ],
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        "Lesson $displayIndex",
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
      trailing: const Icon(Icons.more_vert, color: Colors.white24),
    );
  }
}