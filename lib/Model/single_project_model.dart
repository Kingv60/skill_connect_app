class SingleProjectGet {
  final int projectId;
  final int ownerId;
  final String title;
  final String description;
  final List<String> techStack;
  final int membersCount;
  final DateTime createdAt;
  final String username;
  final String avatarUrl;

  SingleProjectGet({
    required this.projectId,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.techStack,
    required this.membersCount,
    required this.createdAt,
    required this.username,
    required this.avatarUrl,
  });

  factory SingleProjectGet.fromJson(Map<String, dynamic> json) {
    return SingleProjectGet(
      projectId: json['project_id'],
      ownerId: json['owner_id'],
      title: json['title'],
      description: json['description'],
      techStack: List<String>.from(json['tech_stack']),
      membersCount: json['members_count'],
      createdAt: DateTime.parse(json['created_at']),
      username: json['username'],
      avatarUrl: json['avatar_url'],
    );
  }
}