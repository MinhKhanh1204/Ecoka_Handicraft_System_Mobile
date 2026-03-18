import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/shared_prefs.dart';
import '../models/cart.dart';
import '../models/product.dart';

part 'cart_provider.g.dart';

class CartState {
  final Cart cart;

  const CartState({this.cart = const Cart()});

  CartState copyWith({Cart? cart}) => CartState(cart: cart ?? this.cart);
}

@riverpod
class CartController extends _$CartController {
  @override
  CartState build() {
    final items = SharedPrefs.getCart().map(CartItem.fromJson).toList();
    return CartState(cart: Cart(items: items));
  }

  Future<void> _persist(Cart cart) async {
    await SharedPrefs.saveCart(cart.items.map((e) => e.toJson()).toList());
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    final current = state.cart;
    final idx = current.items.indexWhere((i) => i.productId == product.productId);

    final List<CartItem> nextItems = [...current.items];
    if (idx >= 0) {
      final existing = nextItems[idx];
      nextItems[idx] = existing.copyWith(quantity: existing.quantity + quantity);
    } else {
      nextItems.add(CartItem.fromProduct(product, quantity: quantity));
    }

    final nextCart = current.copyWith(items: nextItems);
    state = state.copyWith(cart: nextCart);
    await _persist(nextCart);
  }

  Future<void> removeFromCart(String productId) async {
    final current = state.cart;
    final nextItems = current.items.where((i) => i.productId != productId).toList();
    final nextCart = current.copyWith(items: nextItems);
    state = state.copyWith(cart: nextCart);
    await _persist(nextCart);
  }

  Future<void> clearCart() async {
    const nextCart = Cart(items: []);
    state = state.copyWith(cart: nextCart);
    await SharedPrefs.clearCart();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final current = state.cart;
    final nextItems = current.items.map((i) {
      if (i.productId != productId) return i;
      return i.copyWith(quantity: quantity);
    }).where((i) => i.quantity > 0).toList();

    final nextCart = current.copyWith(items: nextItems);
    state = state.copyWith(cart: nextCart);
    await _persist(nextCart);
  }

  List<Map<String, dynamic>> getOrderItems() {
    return state.cart.items
        .map(
          (i) => {
            'productId': i.productId,
            'quantity': i.quantity,
          },
        )
        .toList();
  }
}

