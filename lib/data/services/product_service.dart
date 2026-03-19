import '../../core/constants/api_constants.dart';
import '../models/product.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Product>> getAllProducts() async {
    final response = await _apiClient.get(ApiConstants.products);
    final data = response.data;

    if (data is Map<String, dynamic> &&
        ((data['success'] ?? data['succeeded']) == true)) {
      final List<dynamic> productsJson = (data['data'] as List?) ?? [];
      return productsJson
          .map((json) => Product.fromJson((json as Map).cast<String, dynamic>()))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      throw Exception(data['message'] ?? 'Không thể tải danh sách sản phẩm');
    }

    throw Exception('Không thể tải danh sách sản phẩm');
  }

  Future<Product> getProductDetail(String productId) async {
    final response = await _apiClient.get('${ApiConstants.products}/$productId');
    final data = response.data;

    if (data is Map<String, dynamic> &&
        ((data['success'] ?? data['succeeded']) == true)) {
      return Product.fromJson((data['data'] as Map).cast<String, dynamic>());
    }

    if (data is Map<String, dynamic>) {
      throw Exception(data['message'] ?? 'Không thể tải chi tiết sản phẩm');
    }

    throw Exception('Không thể tải chi tiết sản phẩm');
  }

  Future<List<Category>> getAllCategories() async {
    final response = await _apiClient.get(ApiConstants.categories);
    final data = response.data;

    if (data is Map<String, dynamic> &&
        ((data['success'] ?? data['succeeded']) == true)) {
      final List<dynamic> categoriesJson = (data['data'] as List?) ?? [];
      return categoriesJson
          .map((json) => Category.fromJson((json as Map).cast<String, dynamic>()))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      throw Exception(data['message'] ?? 'Không thể tải danh mục');
    }

    throw Exception('Không thể tải danh mục');
  }

  Future<List<Product>> searchProducts(String keyword) async {
    final response = await _apiClient.get(
      ApiConstants.products,
      queryParameters: {'search': keyword},
    );
    final data = response.data;

    if (data is Map<String, dynamic> &&
        ((data['success'] ?? data['succeeded']) == true)) {
      final List<dynamic> productsJson = (data['data'] as List?) ?? [];
      return productsJson
          .map((json) => Product.fromJson((json as Map).cast<String, dynamic>()))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      throw Exception(data['message'] ?? 'Không thể tìm kiếm sản phẩm');
    }

    throw Exception('Không thể tìm kiếm sản phẩm');
  }
}