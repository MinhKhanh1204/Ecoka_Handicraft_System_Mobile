import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/order.dart';
import '../services/order_service.dart';

part 'order_provider.g.dart';

class OrderState {
  final bool isLoading;
  final String? error;
  final List<Order> orders;
  final Order? selectedOrder;

  const OrderState({
    this.isLoading = false,
    this.error,
    this.orders = const [],
    this.selectedOrder,
  });

  OrderState copyWith({
    bool? isLoading,
    String? error,
    List<Order>? orders,
    Order? selectedOrder,
  }) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
    );
  }
}

@riverpod
OrderService orderService(OrderServiceRef ref) => OrderService();

@riverpod
class OrderController extends _$OrderController {
  @override
  OrderState build() => const OrderState();

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final orders = await ref.read(orderServiceProvider).getMyOrders();
      state = state.copyWith(isLoading: false, orders: orders);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadOrderDetail(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final order = await ref.read(orderServiceProvider).getOrderDetail(orderId);
      state = state.copyWith(isLoading: false, selectedOrder: order);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createOrder({
    required String shippingAddress,
    required String paymentMethod,
    required List<Map<String, dynamic>> orderItems,
    String? note,
    int? voucherId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(orderServiceProvider).createOrder(
            shippingAddress: shippingAddress,
            paymentMethod: paymentMethod,
            orderItems: orderItems,
            note: note,
            voucherId: voucherId,
          );
      state = state.copyWith(isLoading: false);
      await loadOrders();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    try {
      await ref.read(orderServiceProvider).cancelOrder(orderId, reason: reason);
      await loadOrders();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

