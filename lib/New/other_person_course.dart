import 'package:flutter/material.dart';
import 'package:skillconnect/New/OtherUserVideosPage.dart';
import '../Constants/constants.dart';
import '../Services/AppColors.dart';
import '../Services/api-service.dart';

class UserCoursesScreen extends StatelessWidget {
  final int userId;
  final String name;
  final String username;
  final dynamic profile;

  const UserCoursesScreen({
    super.key,
    required this.name,
    required this.userId,
    required this.username,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text("@$username", style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService().getCoursesByUserId(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white70)));
          }

          final courses = snapshot.data ?? [];

          if (courses.isEmpty) {
            return const Center(
              child: Text("No courses posted yet.", style: TextStyle(color: Colors.white54)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              return OtherCourseListItem(
                course: courses[index],
                profile: profile,
              );
            },
          );
        },
      ),
    );
  }
}

class OtherCourseListItem extends StatelessWidget {
  final dynamic course;
  final dynamic profile;

  const OtherCourseListItem({super.key, required this.course, required this.profile});

  @override
  Widget build(BuildContext context) {
    final String thumbUrl = baseUrlImage + (course['thumbnail_url'] ?? "");

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        // Entire card is now the trigger for navigation
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtherUserVideosPage(
                otherUserProfile: profile, // Passing profile as requested
                userId: course['course_id'], // Ensure this matches the parameter name in your target page
              ),
            ),
          );
        },
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            thumbUrl,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 70,
              height: 70,
              color: Colors.white10,
              child: const Icon(Icons.play_lesson, color: Colors.white24),
            ),
          ),
        ),
        title: Text(
          course['title'] ?? "Untitled Course",
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              _miniChip(course['level'] ?? "Beginner", AppColors.primary),
              const SizedBox(width: 8),
              _miniChip(course['language'] ?? "EN", Colors.white24),
            ],
          ),
        ),
        trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white24,
            size: 14
        ),
      ),
    );
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
          label,
          style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)
      ),
    );
  }
}