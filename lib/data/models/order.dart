class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? image;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: (json['productId'] ?? json['productID'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      price: _parseDouble(json['price']),
      quantity: (json['quantity'] ?? 0) as int,
      image: (json['image'] ?? json['mainImage'])?.toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }

  double get total => price * quantity;
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
  final List<OrderItem>? orderItems;

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
    this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: (json['orderID'] ?? json['orderId'] ?? '').toString(),
      customerId: json['customerId']?.toString(),
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
              .map((e) => OrderItem.fromJson((e as Map).cast<String, dynamic>()))
              .toList()
          : null,
    );
  }

  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String get displayStatus {
    switch (shippingStatus?.toLowerCase()) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'shipping':
        return 'Đang giao hàng';
      case 'delivered':
        return 'Đã giao hàng';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return shippingStatus ?? 'Chờ xử lý';
    }
  }

  String get displayPaymentStatus {
    switch (paymentStatus?.toLowerCase()) {
      case 'paid':
        return 'Đã thanh toán';
      case 'unpaid':
        return 'Chưa thanh toán';
      case 'failed':
        return 'Thanh toán thất bại';
      default:
        return paymentStatus ?? 'Chờ thanh toán';
    }
  }
}

