class MessageModel {
  final int messageId;
  final int conversationId;
  final int senderId;
  final String message;
  final String createdDate;
  final String? senderName;

  MessageModel({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.createdDate,
    this.senderName, // Now properly part of the named parameters
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['message_id'] ?? 0,
      // Fallback to 0 for missing conversation_id to prevent "Null is not a subtype of int"
      conversationId: json['conversation_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      message: json['message'] ?? '',
      createdDate: json['created_date'] ?? '',
      senderName: json['name'], // Maps the "name" field from your JSON
    );
  }
}