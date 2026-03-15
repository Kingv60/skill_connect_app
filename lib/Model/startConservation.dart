class StartConversationResponse {
  final int? conversationId;
  final String? message;

  StartConversationResponse({this.conversationId, this.message});

  factory StartConversationResponse.fromJson(Map<String, dynamic> json) {
    return StartConversationResponse(
      conversationId: json['conversation_id'],
      message: json['message'],
    );
  }
}