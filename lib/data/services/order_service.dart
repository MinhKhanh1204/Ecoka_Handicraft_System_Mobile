import '../../core/constants/api_constants.dart';
import '../../core/utils/shared_prefs.dart';
import '../models/order.dart';
import '../models/product.dart';
import 'api_client.dart';
import 'product_service.dart';

class OrderService {
  final ApiClient _apiClient = ApiClient();
  final ProductService _productService = ProductService();

  Future<List<Order>> getMyOrders() async {
    final response = await _apiClient.get(ApiConstants.orders);
    final data = response.data;

    List<Order> orders = [];

    if (data is List) {
      orders = data
          .map((json) => Order.fromJson((json as Map).cast<String, dynamic>()))
          .toList();
    } else if (data is Map<String, dynamic> && data['data'] is List) {
      final List<dynamic> ordersJson = (data['data'] as List?) ?? [];
      orders = ordersJson
          .map((json) => Order.fromJson((json as Map).cast<String, dynamic>()))
          .toList();
    } else {
      return [];
    }

    final enrichedOrders = await Future.wait(
      orders.map(_enrichOrderItemsWithProductInfo),
    );

    return enrichedOrders;
  }

  Future<Order> getOrderDetail(String orderId) async {
    final response = await _apiClient.get('${ApiConstants.orders}/$orderId');
    final data = response.data;

    Order order;

    if (data is Map<String, dynamic> && data['data'] is Map) {
      order = Order.fromJson((data['data'] as Map).cast<String, dynamic>());
    } else if (data is Map<String, dynamic>) {
      order = Order.fromJson(data);
    } else {
      throw Exception('Không thể tải chi tiết đơn hàng');
    }

    return await _enrichOrderItemsWithProductInfo(order);
  }

  Future<Order> _enrichOrderItemsWithProductInfo(Order order) async {
    if (order.orderItems.isEmpty) return order;

    final enrichedItems = await Future.wait(
      order.orderItems.map((item) async {
        try {
          final Product product =
          await _productService.getProductDetail(item.productId);

          return item.copyWith(
            productName: product.productName,
            image: product.images!.first.toString(),
          );
        } catch (_) {
          return item;
        }
      }),
    );

    return order.copyWith(orderItems: enrichedItems);
  }

  Future<Order> createOrder({
    required String shippingAddress,
    required String paymentMethod,
    required List<Map<String, dynamic>> orderItems,
    String? note,
    int? voucherId,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.orders,
      data: {
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        'orderItems': orderItems,
        'note': note ?? '',
        'voucherId': voucherId,
        'customerID': SharedPrefs.getUserId() ?? '',
      },
    );

    final data = response.data;

    Order order;
    if (data is Map<String, dynamic> && data['data'] is Map) {
      order = Order.fromJson((data['data'] as Map).cast<String, dynamic>());
    } else if (data is Map<String, dynamic>) {
      order = Order.fromJson(data);
    } else {
      throw Exception('Không thể tạo đơn hàng');
    }

    return await _enrichOrderItemsWithProductInfo(order);
  }

  Future<void> cancelOrder(String orderId, {String? reason}) async {
    final response = await _apiClient.put(
      '${ApiConstants.orders}/$orderId/cancel',
      data: reason,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Không thể hủy đơn hàng');
    }
  }
}