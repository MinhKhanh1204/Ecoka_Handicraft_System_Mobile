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
  final List<String> imageUrls;

  const Feedback({
    required this.feedbackId,
    this.customerId,
    this.productId,
    this.username,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
    this.status,
    this.imageUrls = const [],
  });

  static int _parseInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  static int _parseRating(dynamic value) {
    final n = _parseInt(value, 0);
    return n.clamp(1, 5);
  }

  Feedback copyWith({
    int? feedbackId,
    String? customerId,
    String? productId,
    String? username,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    List<String>? imageUrls,
  }) {
    return Feedback(
      feedbackId: feedbackId ?? this.feedbackId,
      customerId: customerId ?? this.customerId,
      productId: productId ?? this.productId,
      username: username ?? this.username,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  factory Feedback.fromJson(Map<String, dynamic> json) {
    List<String> urls = [];
    final imgData = json['imageUrls'];
    if (imgData is List) {
      urls = imgData.map((e) => e.toString()).toList();
    }

    return Feedback(
      feedbackId: _parseInt(json['feedbackId'] ?? json['feedbackID'], 0),
      customerId:
      json['customerId']?.toString() ?? json['customerID']?.toString(),
      productId:
      json['productId']?.toString() ?? json['productID']?.toString(),
      username: json['username']?.toString(),
      rating: _parseRating(json['rating']),
      comment: json['comment']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      status: json['status']?.toString(),
      imageUrls: urls,
    );
  }
}