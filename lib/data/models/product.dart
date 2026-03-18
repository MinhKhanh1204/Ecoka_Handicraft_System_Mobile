import '../../core/constants/api_constants.dart';

class Product {
  final String productId;
  final String productName;
  final int? categoryId;
  final String? categoryName;
  final double originalPrice;
  final double finalPrice;
  final String? mainImage;
  final String? description;
  final String? material;
  final double? discount;
  final int? stockQuantity;
  final String? status;
  final List<String>? images;
  final Category? category;

  Product({
    required this.productId,
    required this.productName,
    this.categoryId,
    this.categoryName,
    required this.originalPrice,
    required this.finalPrice,
    this.mainImage,
    this.description,
    this.material,
    this.discount,
    this.stockQuantity,
    this.status,
    this.images,
    this.category,
  });

  String get fullMainImageUrl {
    final img = mainImage;
    if (img == null || img.isEmpty) return '';
    if (img.startsWith('http://') || img.startsWith('https://')) return img;
    return '${ApiConstants.baseUrl}$img';
  }

  List<String>? get fullImageUrls {
    final imgs = images;
    if (imgs == null || imgs.isEmpty) return null;
    return imgs.map((img) {
      if (img.isEmpty) return '';
      if (img.startsWith('http://') || img.startsWith('https://')) return img;
      return '${ApiConstants.baseUrl}$img';
    }).toList();
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: (json['productID'] ?? json['productId'] ?? '').toString(),
      productName: (json['productName'] ?? '').toString(),
      categoryId: json['categoryId'] == null
          ? null
          : int.tryParse(json['categoryId'].toString()),
      categoryName: json['categoryName']?.toString(),
      originalPrice: _parseDouble(json['originalPrice'] ?? json['price']),
      finalPrice: _parseDouble(json['finalPrice'] ?? json['price']),
      mainImage: (json['mainImage'] ?? json['MainImage'])?.toString(),
      description: json['description']?.toString(),
      material: json['material']?.toString(),
      discount: _parseDoubleNullable(json['discount']),
      stockQuantity: json['stockQuantity'] is int
          ? json['stockQuantity'] as int
          : int.tryParse('${json['stockQuantity']}'),
      status: json['status']?.toString(),
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      category: json['category'] != null
          ? Category.fromJson((json['category'] as Map).cast<String, dynamic>())
          : null,
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

  bool get hasDiscount => finalPrice < originalPrice;
  double get displayPrice => finalPrice;
  double get displayOriginalPrice => originalPrice;
}

class Category {
  final int categoryId;
  final String categoryName;

  Category({
    required this.categoryId,
    required this.categoryName,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: int.tryParse(
        (json['categoryId'] ??
            json['categoryID'] ??
            json['id'] ??
            json['Id'] ??
            0)
            .toString(),
      ) ??
          0,
      categoryName: (json['categoryName'] ??
          json['name'] ??
          json['category_title'] ??
          '')
          .toString(),
    );
  }
}