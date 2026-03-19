class OrderItem {
  final int? orderItemId;
  final String productId;
  final String? productName;
  final double price;
  final int quantity;
  final double discount;
  final String? image;

  OrderItem({
    this.orderItemId,
    required this.productId,
    this.productName,
    required this.price,
    required this.quantity,
    this.discount = 0,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderItemId: _parseIntNullable(json['orderItemID'] ?? json['orderItemId']),
      productId: (json['productId'] ?? json['productID'] ?? '').toString(),
      productName: json['productName']?.toString(),
      price: _parseDouble(json['price'] ?? json['unitPrice']),
      quantity: _parseInt(json['quantity']),
      discount: _parseDouble(json['discount']),
      image: (json['image'] ?? json['mainImage'])?.toString(),
    );
  }

  OrderItem copyWith({
    int? orderItemId,
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    double? discount,
    String? image,
  }) {
    return OrderItem(
      orderItemId: orderItemId ?? this.orderItemId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
      image: image ?? this.image,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _parseIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double get total => (price - discount) * quantity;
}

class Order {
  final String orderId;
  final String? customerId;
  final DateTime? orderDate;
  final double? totalAmount;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? shippingStatus;
  final String? shippingAddress;
  final String? note;
  final DateTime? updatedAt;
  final List<OrderItem> orderItems;

  Order({
    required this.orderId,
    this.customerId,
    this.orderDate,
    this.totalAmount,
    this.paymentMethod,
    this.paymentStatus,
    this.shippingStatus,
    this.shippingAddress,
    this.note,
    this.updatedAt,
    this.orderItems = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: (json['orderID'] ?? json['orderId'] ?? '').toString(),
      customerId: (json['customerID'] ?? json['customerId'])?.toString(),
      orderDate: json['orderDate'] != null
          ? DateTime.tryParse(json['orderDate'].toString())
          : null,
      totalAmount: _parseDoubleNullable(json['totalAmount']),
      paymentMethod: json['paymentMethod']?.toString(),
      paymentStatus: json['paymentStatus']?.toString(),
      shippingStatus: json['shippingStatus']?.toString(),
      shippingAddress: json['shippingAddress']?.toString(),
      note: json['note']?.toString(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      orderItems: json['orderItems'] is List
          ? (json['orderItems'] as List)
          .map((e) => OrderItem.fromJson(
        Map<String, dynamic>.from(e as Map),
      ))
          .toList()
          : [],
    );
  }

  Order copyWith({
    String? orderId,
    String? customerId,
    DateTime? orderDate,
    double? totalAmount,
    String? paymentMethod,
    String? paymentStatus,
    String? shippingStatus,
    String? shippingAddress,
    String? note,
    DateTime? updatedAt,
    List<OrderItem>? orderItems,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      orderDate: orderDate ?? this.orderDate,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      shippingStatus: shippingStatus ?? this.shippingStatus,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
      orderItems: orderItems ?? this.orderItems,
    );
  }

  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String get displayStatus {
    switch ((shippingStatus ?? '').toLowerCase()) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'shipping':
        return 'Đang giao hàng';
      case 'delivered':
        return 'Đã giao hàng';
      case 'cancelled':
      case 'canceled':
        return 'Đã hủy';
      default:
        return shippingStatus ?? 'Chờ xử lý';
    }
  }

  String get displayPaymentStatus {
    switch ((paymentStatus ?? '').toLowerCase()) {
      case 'paid':
        return 'Đã thanh toán';
      case 'pending':
        return 'Chờ thanh toán';
      case 'unpaid':
        return 'Chưa thanh toán';
      case 'failed':
        return 'Thanh toán thất bại';
      default:
        return paymentStatus ?? 'Chờ thanh toán';
    }
  }
}