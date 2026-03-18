class Voucher {
  final int voucherId;
  final String code;
  final String? description;
  final double discountPercent;
  final double? maxDiscount;
  final double? minOrderAmount;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  Voucher({
    required this.voucherId,
    required this.code,
    this.description,
    required this.discountPercent,
    this.maxDiscount,
    this.minOrderAmount,
    this.startDate,
    this.endDate,
    required this.isActive,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      voucherId: (json['voucherId'] ?? json['voucherID'] ?? 0) as int,
      code: (json['code'] ?? '').toString(),
      description: json['description']?.toString(),
      discountPercent: _parseDouble(json['discountPercent'] ?? json['discount_percent']),
      maxDiscount: _parseDoubleNullable(json['maxDiscount'] ?? json['max_discount']),
      minOrderAmount: _parseDoubleNullable(json['minOrderAmount'] ?? json['min_order_amount']),
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      isActive: json['isActive'] == true || json['is_active'] == true,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  bool get isValid {
    final now = DateTime.now();
    if (!isActive) return false;
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  double calculateDiscount(double orderAmount) {
    if (!isValid) return 0;
    if (minOrderAmount != null && orderAmount < minOrderAmount!) return 0;
    final discount = orderAmount * discountPercent / 100;
    if (maxDiscount != null && discount > maxDiscount!) return maxDiscount!;
    return discount;
  }
}
