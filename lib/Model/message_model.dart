class MessageModel {
  final int messageId;
  final int conversationId;
  final int senderId;
  final String? message;       // Now nullable (might just be an image)
  final String? fileUrl;       // Path to the file on the server
  final String? fileName;      // Original name (e.g., "document.pdf")
  final String messageType;    // 'text', 'image', 'video', 'file', 'link'
  final String createdDate;
  final String? senderName;
  final List<ReactionModel> reactions;

  MessageModel({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    this.message,
    this.fileUrl,
    this.fileName,
    required this.messageType,
    required this.createdDate,
    this.senderName,
    required this.reactions,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['message_id'] ?? 0,
      conversationId: json['conversation_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      message: json['message'],
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      messageType: json['message_type'] ?? 'text', // Default to text
      createdDate: json['created_date'] ?? '',
      senderName: json['name'],
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