class Reel {
  final int reelid;
  final int userid;
  final String caption;
  final String reelurl;
  final String? thumbnailurl;
  final int duration;
  final int? views;
  final int likes;
  final DateTime createdat;
  final String name;

  Reel({
    required this.reelid,
    required this.userid,
    required this.caption,
    required this.reelurl,
    this.thumbnailurl,
    required this.duration,
    this.views,
    required this.likes,
    required this.createdat,
    required this.name,
  });

  factory Reel.fromJson(Map<String, dynamic> json) {
    return Reel(
      reelid: json['reelid'],
      userid: json['userid'],
      caption: json['caption'] ?? '',
      reelurl: json['reelurl'],
      thumbnailurl: json['thumbnailurl'],
      duration: json['duration'] ?? 0,
      views: json['views'],
      likes: json['likes'] ?? 0,
      createdat: DateTime.parse(json['createdat']),
      name: json['name'],
    );
  }
}