import '../../core/constants/api_constants.dart';
import '../models/order.dart';
import 'api_client.dart';

class OrderService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Order>> getMyOrders() async {
    final response = await _apiClient.get(ApiConstants.orders);
    final data = response.data;

    if (data is List) {
      return data
          .map((json) => Order.fromJson((json as Map).cast<String, dynamic>()))
          .toList();
    }

    if (data is Map<String, dynamic> && data['data'] is List) {
      final List<dynamic> ordersJson = (data['data'] as List?) ?? [];
      return ordersJson
          .map((json) => Order.fromJson((json as Map).cast<String, dynamic>()))
          .toList();
    }

    return [];
  }

  Future<Order> getOrderDetail(String orderId) async {
    final response = await _apiClient.get('${ApiConstants.orders}/$orderId');
    final data = response.data;

    if (data is Map<String, dynamic>) return Order.fromJson(data);
    if (data is Map && data['data'] is Map) {
      return Order.fromJson((data['data'] as Map).cast<String, dynamic>());
    }
    throw Exception('Không thể tải chi tiết đơn hàng');
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
        'customerID': 'dummy', // Bổ sung để qua mặt validation tạm thời
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) return Order.fromJson(data);
    if (data is Map && data['data'] is Map) {
      return Order.fromJson((data['data'] as Map).cast<String, dynamic>());
    }
    throw Exception('Không thể tạo đơn hàng');
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

