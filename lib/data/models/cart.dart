import 'product.dart';

class CartItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? image;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.image,
  });

  factory CartItem.fromProduct(Product product, {required int quantity}) {
    return CartItem(
      productId: product.productId,
      productName: product.productName,
      price: product.displayPrice,
      quantity: quantity,
      image: product.fullMainImageUrl.isEmpty ? product.mainImage : product.fullMainImageUrl,
    );
  }

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      productName: productName,
      price: price,
      quantity: quantity ?? this.quantity,
      image: image,
    );
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

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: (json['productId'] ?? json['productID'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      price: _parseDouble(json['price']),
      quantity: (json['quantity'] ?? 0) as int,
      image: json['image']?.toString(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  double get total => price * quantity;
}

class Cart {
  final List<CartItem> items;

  const Cart({this.items = const []});

  int get itemCount => items.fold<int>(0, (sum, i) => sum + i.quantity);
  double get totalAmount => items.fold<double>(0, (sum, i) => sum + i.total);

  Cart copyWith({List<CartItem>? items}) => Cart(items: items ?? this.items);
}

