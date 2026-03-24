class JoinRequest {
  final int interactionId;
  final String message;
  final String status;
  final String applicantName;
  final String? avatarUrl;

  JoinRequest({
    required this.interactionId,
    required this.message,
    required this.status,
    required this.applicantName,
    this.avatarUrl,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    return JoinRequest(
      interactionId: json['interaction_id'],
      message: json['message'] ?? '',
      status: json['status'],
      applicantName: json['applicant_name'],
      avatarUrl: json['avatar_url'],
    );
  }
}