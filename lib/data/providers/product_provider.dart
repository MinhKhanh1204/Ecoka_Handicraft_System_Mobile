import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/product.dart';
import '../services/product_service.dart';

part 'product_provider.g.dart';

class ProductState {
  final bool isLoading;
  final String? error;
  final List<Product> products;
  final List<Product> allProducts;
  final List<Category> categories;
  final Product? selectedProduct;
  final int? selectedCategoryId;

  const ProductState({
    this.isLoading = false,
    this.error,
    this.products = const [],
    this.allProducts = const [],
    this.categories = const [],
    this.selectedProduct,
    this.selectedCategoryId,
  });

  ProductState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<Product>? products,
    List<Product>? allProducts,
    List<Category>? categories,
    Product? selectedProduct,
    bool clearSelectedProduct = false,
    int? selectedCategoryId,
    bool clearSelectedCategory = false,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      products: products ?? this.products,
      allProducts: allProducts ?? this.allProducts,
      categories: categories ?? this.categories,
      selectedProduct: clearSelectedProduct
          ? null
          : (selectedProduct ?? this.selectedProduct),
      selectedCategoryId: clearSelectedCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
    );
  }
}

@riverpod
ProductService productService(ProductServiceRef ref) => ProductService();

@riverpod
class ProductController extends _$ProductController {
  @override
  ProductState build() => const ProductState();

  Future<void> loadProducts() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSelectedCategory: true,
    );

    try {
      final products = await ref.read(productServiceProvider).getAllProducts();

      for (final p in products) {
        debugPrint(
          'Loaded product: ${p.productName} - categoryId: ${p.categoryId} - categoryName: ${p.categoryName}',
        );
      }

      state = state.copyWith(
        isLoading: false,
        products: products,
        allProducts: products,
        clearSelectedCategory: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadCategories() async {
    try {
      final categories = await ref.read(productServiceProvider).getAllCategories();
      state = state.copyWith(categories: categories);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void filterByCategory(int? categoryId) {
    debugPrint('Selected categoryId: $categoryId');
    debugPrint('All products count: ${state.allProducts.length}');

    if (categoryId == null) {
      state = state.copyWith(
        products: state.allProducts,
        clearSelectedCategory: true,
      );
      return;
    }

    final filtered = state.allProducts.where((product) {
      debugPrint(
        'Compare ${product.productName}: ${product.categoryId} == $categoryId',
      );
      return product.categoryId == categoryId;
    }).toList();

    debugPrint('Filtered count: ${filtered.length}');

    state = state.copyWith(
      products: filtered,
      selectedCategoryId: categoryId,
      clearError: true,
    );
  }

  void searchProductsLocal(String keyword) {
    final text = keyword.trim().toLowerCase();

    final source = state.selectedCategoryId == null
        ? state.allProducts
        : state.allProducts
        .where((p) => p.categoryId == state.selectedCategoryId)
        .toList();

    if (text.isEmpty) {
      state = state.copyWith(
        products: source,
        clearError: true,
      );
      return;
    }

    final filtered = source.where((product) {
      final productName = normalizeVietnamese(product.productName);
      return productName.contains(text);
    }).toList();


    state = state.copyWith(
      products: filtered,
      clearError: true,
    );
  }

  Future<void> loadProductDetail(String productId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final product =
      await ref.read(productServiceProvider).getProductDetail(productId);
      state = state.copyWith(
        isLoading: false,
        selectedProduct: product,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearSelectedProduct() {
    state = state.copyWith(clearSelectedProduct: true);
  }

  String normalizeVietnamese(String text) {
    const vietnamese = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩ'
        'òóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ'
        'ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨ'
        'ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';

    const nonVietnamese = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiii'
        'ooooooooooooooooouuuuuuuuuuuyyyyyd'
        'AAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIII'
        'OOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';

    var result = text;
    for (int i = 0; i < vietnamese.length; i++) {
      result = result.replaceAll(vietnamese[i], nonVietnamese[i]);
    }
    return result.toLowerCase().trim();
  }
}