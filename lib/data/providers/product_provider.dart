import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/product.dart';
import '../services/product_service.dart';

part 'product_provider.g.dart';

class ProductState {
  final bool isLoading;
  final String? error;
  final List<Product> products;
  final List<Category> categories;
  final Product? selectedProduct;

  const ProductState({
    this.isLoading = false,
    this.error,
    this.products = const [],
    this.categories = const [],
    this.selectedProduct,
  });

  ProductState copyWith({
    bool? isLoading,
    String? error,
    List<Product>? products,
    List<Category>? categories,
    Product? selectedProduct,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedProduct: selectedProduct ?? this.selectedProduct,
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await ref.read(productServiceProvider).getAllProducts();
      state = state.copyWith(isLoading: false, products: products);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadCategories() async {
    try {
      final categories =
          await ref.read(productServiceProvider).getAllCategories();
      state = state.copyWith(categories: categories);
    } catch (_) {
      // ignore categories errors for now
    }
  }

  Future<void> loadProductsByCategory(int categoryId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await ref
          .read(productServiceProvider)
          .getProductsByCategory(categoryId);
      state = state.copyWith(isLoading: false, products: products);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchProducts(String keyword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products =
          await ref.read(productServiceProvider).searchProducts(keyword);
      state = state.copyWith(isLoading: false, products: products);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadProductDetail(String productId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final product =
          await ref.read(productServiceProvider).getProductDetail(productId);
      state = state.copyWith(isLoading: false, selectedProduct: product);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

