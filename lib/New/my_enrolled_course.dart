import 'package:flutter/material.dart';
import 'package:skillconnect/Services/api-service.dart';
import 'package:skillconnect/Constants/constants.dart';

import 'All_video_of_course.dart';
import 'enrolledcoursevideos.dart';
// Ensure correct path

class MyCoursesListPage extends StatelessWidget {
  const MyCoursesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f0f0f),
      appBar: AppBar(
        backgroundColor: const Color(0xff0f0f0f),
        title: const Text("My Enrolled Courses", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService().getMyJoinedCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          final courses = snapshot.data ?? [];

          if (courses.isEmpty) {
            return const Center(
              child: Text("You haven't joined any courses yet.", style: TextStyle(color: Colors.white54)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return _buildCourseItem(context, course);
            },
          );
        },
      ),
    );
  }

  Widget _buildCourseItem(BuildContext context, dynamic course) {
    // Construct the full thumbnail URL
    final String thumbUrl = "$baseUrlImage${course['thumbnail_url']}";

    // Format the enrollment date
    String enrollDate = "Joined recently";
    if (course['enrolled_at'] != null) {
      DateTime dt = DateTime.parse(course['enrolled_at']);
      enrollDate = "Enrolled: ${dt.day}/${dt.month}/${dt.year}";
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnrolledCourseLessonsPage(
              course_id: course['course_id'],
              courseTitle: course['title'] ?? "Course Details",
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                thumbUrl,
                width: 90,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 90, height: 60, color: Colors.grey[900]),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['title'] ?? "Untitled",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    enrollDate,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }
}