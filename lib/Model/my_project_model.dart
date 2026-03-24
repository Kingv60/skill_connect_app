class MyProject {
  final int projectId;
  final int ownerId;
  final String title;
  final String description;
  final List<String> techStack;
  final int membersCount;
  final DateTime createdAt;

  MyProject({
    required this.projectId,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.techStack,
    required this.membersCount,
    required this.createdAt,
  });

  factory MyProject.fromJson(Map<String, dynamic> json) {
    return MyProject(
      projectId: json['project_id'],
      ownerId: json['owner_id'],
      title: json['title'],
      description: json['description'],
      techStack: List<String>.from(json['tech_stack'] ?? []),
      membersCount: json['members_count'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "project_id": projectId,
      "owner_id": ownerId,
      "title": title,
      "description": description,
      "tech_stack": techStack,
      "members_count": membersCount,
      "created_at": createdAt.toIso8601String(),
    };
  }
}