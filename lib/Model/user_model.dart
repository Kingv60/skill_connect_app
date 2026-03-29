class UserModel {
  final String name;
  final String username;
  final String avatarUrl;
  final String role;

  UserModel({
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.role,
  });

  // This converts the JSON Map from your API into a proper Dart Object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? 'Guest',
      username: map['username'] ?? 'user',
      // Check if your API uses 'avatar' or 'avatarUrl' as the key!
      avatarUrl: map['avatar'] ?? 'https://picsum.photos/200',
      role: map['role'] ?? 'Member',
    );
  }
}