class MyPost {
  final int postId;
  final String caption;
  final String file;
  final int userId;
  final String username;
  final String avatarUrl;
  final String likes;
  final String comment;
  final DateTime createdDate;
  final int createdBy;

  MyPost({
    required this.postId,
    required this.caption,
    required this.file,
    required this.userId,
    required this.username,
    required this.avatarUrl,
    required this.likes,
    required this.comment,
    required this.createdDate,
    required this.createdBy,
  });

  factory MyPost.fromJson(Map<String, dynamic> json) {
    return MyPost(
      postId: json['post_id'] ?? 0,
      caption: json['caption'] ?? "",
      file: json['file'] ?? "",
      userId: json['User id'] ?? 0, // Matches your JSON key exactly
      username: json['username'] ?? "User",
      avatarUrl: json['avatar_url'] ?? "",
      likes: json['likes'].toString(),
      comment: json['comment'].toString(),
      createdDate: DateTime.parse(json['createddate'] ?? DateTime.now().toIso8601String()),
      createdBy: json['created_by'] ?? 0,
    );
  }
}