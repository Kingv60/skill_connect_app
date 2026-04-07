import 'package:skillconnect/Constants/constants.dart';

class Reel {
  final int reelId;
  final int userId;
  final String caption;
  final String reelUrl;
  final String name;
  int likesCount;
  int commentsCount;
  int views; // This stores the number displayed next to the eye icon
  bool isLiked;

  Reel({
    required this.reelId,
    required this.userId,
    required this.caption,
    required this.reelUrl,
    required this.name,
    required this.likesCount,
    required this.commentsCount,
    required this.views,
    required this.isLiked,
  });

  factory Reel.fromJson(Map<String, dynamic> json) {
    String rawUrl = json['reelurl'] ?? "";
    String fullUrl = rawUrl.startsWith('http') ? rawUrl : "$baseUrlImage$rawUrl";

    return Reel(
      reelId: json['reelid'] ?? 0,
      userId: json['userid'] ?? 0,
      caption: json['caption'] ?? "",
      reelUrl: fullUrl,
      name: json['name'] ?? "User",
      likesCount: int.tryParse(json['likes_count']?.toString() ?? '0') ?? 0,
      commentsCount: int.tryParse(json['comments_count']?.toString() ?? '0') ?? 0,

      // UNIVERSAL CHECK: This looks for total_views OR views_count OR views
      views: int.tryParse((json['total_views'] ?? json['views_count'] ?? json['views'] ?? '0').toString()) ?? 0,

      isLiked: json['is_liked'] ?? false,
    );
  }
}