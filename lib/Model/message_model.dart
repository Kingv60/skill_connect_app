class MessageModel {
  final int messageId;
  final int conversationId;
  final int senderId;
  final String message;
  final String createdDate;
  final String? senderName;
  final List<ReactionModel> reactions; // New field

  MessageModel({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.createdDate,
    this.senderName,
    required this.reactions, // Required in constructor
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['message_id'] ?? 0,
      conversationId: json['conversation_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      message: json['message'] ?? '',
      createdDate: json['created_date'] ?? '',
      senderName: json['name'],
      // Map the reactions array from JSON
      reactions: json['reactions'] != null
          ? (json['reactions'] as List)
          .map((r) => ReactionModel.fromJson(r))
          .toList()
          : [],
    );
  }
}

class ReactionModel {
  final int userId;
  final String emoji;
  final String? username;

  ReactionModel({
    required this.userId,
    required this.emoji,
    this.username,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      userId: json['user_id'] ?? 0,
      emoji: json['emoji'] ?? '',
      username: json['username'],
    );
  }
}