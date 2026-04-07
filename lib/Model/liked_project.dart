import 'dart:convert';

class LikedProject {
  final int projectId;
  final int ownerId;
  final String title;
  final String description;
  final List<String> techStack;
  final int membersCount;
  final DateTime createdAt;
  final int likesCount;
  final String username;
  final String avatarUrl;
  final bool isLiked;

  LikedProject({
    required this.projectId,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.techStack,
    required this.membersCount,
    required this.createdAt,
    required this.likesCount,
    required this.username,
    required this.avatarUrl,
    required this.isLiked,
  });

  // Factory method to create an instance from JSON
  factory LikedProject.fromJson(Map<String, dynamic> json) {
    return LikedProject(
      projectId: json['project_id'],
      ownerId: json['owner_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      // Handling List<dynamic> to List<String> conversion
      techStack: List<String>.from(json['tech_stack'] ?? []),
      membersCount: json['members_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      likesCount: json['likes_count'] ?? 0,
      username: json['username'] ?? 'Unknown',
      avatarUrl: json['avatar_url'] ?? '',
      isLiked: json['is_liked'] ?? false,
    );
  }

  // Method to convert instance back to JSON (useful for local storage)
  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'tech_stack': techStack,
      'members_count': membersCount,
      'created_at': createdAt.toIso8601String(),
      'likes_count': likesCount,
      'username': username,
      'avatar_url': avatarUrl,
      'is_liked': isLiked,
    };
  }
}

// Helper function to parse a list of projects
List<LikedProject> likedProjectFromJson(String str) =>
    List<LikedProject>.from(json.decode(str).map((x) => LikedProject.fromJson(x)));