class Post {
  final int postId;
  final String caption;
  final String file;
  final int userId;
  final String username;
  final String likes;
  final String comments;
  final DateTime createdDate;

  Post({
    required this.postId,
    required this.caption,
    required this.file,
    required this.userId,
    required this.username,
    required this.likes,
    required this.comments,
    required this.createdDate,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['post_id'],
      caption: json['caption'],
      file: json['file'],
      userId: json['user_id'],
      username: json['username'],
      likes: json['likes'],
      comments: json['comments'],
      createdDate: DateTime.parse(json['createddate']),
    );
  }
}