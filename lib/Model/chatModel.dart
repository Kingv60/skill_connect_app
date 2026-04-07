class ChatSummary {
  final int conversationId;
  final int userId;
  final String name;
  final String avatar;
  final String? lastMessage;
  final String? lastTime;
  final bool isProjectChat; // <--- ADD THIS

  ChatSummary({
    required this.conversationId,
    required this.userId,
    required this.name,
    required this.avatar,
    this.lastMessage,
    this.lastTime,
    required this.isProjectChat, // <--- ADD THIS
  });

  factory ChatSummary.fromJson(Map<String, dynamic> json) {
    return ChatSummary(
      conversationId: json['conversation_id'] ?? 0,
      // Your JSON uses 'other_user_id'
      userId: json['other_user_id'] ?? 0,
      name: json['name'] ?? 'Unknown User',
      avatar: json['avatar'] ?? '',
      lastMessage: json['last_message'],
      // Your JSON uses 'last_time'
      lastTime: json['last_time'],
      // Map the project flag from JSON
      isProjectChat: json['is_project_chat'] ?? false,
    );
  }
}