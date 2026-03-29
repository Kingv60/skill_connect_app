import 'package:skillconnect/Constants/constants.dart';

class Reel {
  final int reelId;
  final int userId;
  final String caption; // Changed to String for easier UI use
  final String reelUrl;
  final String? thumbnailUrl;
  final int views;
  final int likes;
  final DateTime createdAt;
  final String name; // Added this to match your API response

  Reel({
    required this.reelId,
    required this.userId,
    required this.caption,
    required this.reelUrl,
    this.thumbnailUrl,
    required this.views,
    required this.likes,
    required this.createdAt,
    required this.name,
  });

  factory Reel.fromJson(Map<String, dynamic> json) {
    String rawUrl = json['reelurl'] ?? "";
    String fullUrl = rawUrl.startsWith('http') ? rawUrl : "$baseUrlImage$rawUrl";

    return Reel(
      reelId: json['reelid'] ?? 0,
      userId: json['userid'] ?? 0,
      caption: json['caption'] ?? "", // Default to empty string
      reelUrl: fullUrl,
      thumbnailUrl: json['thumbnailurl'],
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      name: json['name'] ?? "User", // Mapping the 'name' from JSON
      createdAt: json['createdat'] != null
          ? DateTime.parse(json['createdat'])
          : DateTime.now(),
    );
  }
}