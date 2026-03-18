class Feedback {
  final int feedbackId;
  final String? customerId;
  final String? productId;
  final String? username;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? status;

  Feedback({
    required this.feedbackId,
    this.customerId,
    this.productId,
    this.username,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
    this.status,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      feedbackId: (json['feedbackId'] ?? json['feedbackID'] ?? 0) as int,
      customerId: json['customerId']?.toString(),
      productId: json['productId']?.toString(),
      username: json['username']?.toString(),
      rating: (json['rating'] ?? 0) as int,
      comment: json['comment']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      status: json['status']?.toString(),
    );
  }
}
