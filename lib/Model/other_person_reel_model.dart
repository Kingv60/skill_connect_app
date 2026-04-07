class OtherPersonReel {
  final int reelId;
  final int userId;
  final String caption;
  final String reelUrl;
  final String? thumbnailUrl;
  final int duration;
  final String views;
  final int likes;
  final DateTime createdAt;

  OtherPersonReel({
    required this.reelId,
    required this.userId,
    required this.caption,
    required this.reelUrl,
    this.thumbnailUrl,
    required this.duration,
    required this.views,
    required this.likes,
    required this.createdAt,
  });

  // JSON se model banane ke liye
  factory OtherPersonReel.fromJson(Map<String, dynamic> json) {
    return OtherPersonReel(
      reelId: json['reelid'] ?? 0,
      userId: json['userid'] ?? 0,
      caption: json['caption'] ?? "",
      reelUrl: json['reelurl'] ?? "",
      thumbnailUrl: json['thumbnailurl'],
      duration: json['duration'] ?? 0,
      views: json['views']?.toString() ?? "0",
      likes: json['likes'] ?? 0,
      createdAt: json['createdat'] != null
          ? DateTime.parse(json['createdat'].toString())
          : DateTime.now(),
    );
  }
}