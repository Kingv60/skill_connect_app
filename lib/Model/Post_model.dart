class Post {
  final int postId;
  final String caption;
  final String file;
  final String username;
  final String avatarUrl;
  final int user_id;
  String likes;
  String comments;
  bool isViewed;

  Post({
    required this.postId,
    required this.caption,
    required this.user_id,
    required this.file,
    required this.username,
    required this.avatarUrl,
    required this.likes,
    required this.comments,
    required this.isViewed,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      user_id: json['user_id'],
      postId: json['post_id'],
      caption: json['caption'] ?? "",
      file: json['file'] ?? "",
      username: json['username'] ?? "",
      avatarUrl: json['avatar_url'] ?? "",
      likes: json['likes'].toString(),
      comments: json['comments'].toString(),
      isViewed: json['is_viewed'] ?? false,
    );
  }
}