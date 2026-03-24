class GlobalFeed {
  final int projectId;
  final int ownerId;
  final String title;
  final String description;
  final List<String> techStack;
  final int membersCount;
  final String createdAt;
  final String username;
  final String? avatarUrl;

  GlobalFeed({
    required this.projectId,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.techStack,
    required this.membersCount,
    required this.createdAt,
    required this.username,
    this.avatarUrl,
  });

  factory GlobalFeed.fromJson(Map<String, dynamic> json) {
    return GlobalFeed(
      projectId: json['project_id'] ?? 0,
      ownerId: json['owner_id'] ?? 0,
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      // Safely convert dynamic list from PostgreSQL to List<String>
      techStack: json['tech_stack'] != null
          ? List<String>.from(json['tech_stack'])
          : [],
      membersCount: json['members_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
      username: json['username'] ?? 'Unknown User',
      avatarUrl: json['avatar_url'],
    );
  }
}