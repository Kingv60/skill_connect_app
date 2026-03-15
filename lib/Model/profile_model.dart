class ProfileModel {
  final String name;
  final String username;
  final String role;
  final String bio;
  final String avatarUrl;
  final List<String> skills;

  ProfileModel({
    required this.name,
    required this.username,
    required this.role,
    required this.bio,
    required this.avatarUrl,
    required this.skills,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json["name"] ?? "",
      username: json["username"] ?? "",
      role: json["role"] ?? "",
      bio: json["bio"] ?? "",
      avatarUrl: json["avatar_url"] ?? "",
      skills: json["skills"] != null
          ? (json["skills"] as String).split(",")
          : [],
    );
  }
}