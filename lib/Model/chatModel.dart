class ChatSummary {
  final int conversationId;
  final int userId;
  final String name;
  final String avatar;
  final String? lastMessage; // Already nullable, this is fine
  final String lastTime;

  ChatSummary({
    required this.conversationId,
    required this.userId,
    required this.name,
    required this.avatar,
    this.lastMessage,
    required this.lastTime,
  });

  factory ChatSummary.fromJson(Map<String, dynamic> json) {
    return ChatSummary(
      // Use ?? to provide default values for non-nullable Strings
      conversationId: json['conversation_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? 'Unknown User',
      avatar: json['avatar'] ?? '',
      lastMessage: json['last_message'], // This is String?, so null is okay
      lastTime: json['last_time'] ?? '', // This was likely the crasher
    );
  }
}