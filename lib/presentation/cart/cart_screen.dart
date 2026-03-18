import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/voucher.dart';
import '../../data/providers/cart_provider.dart';
import '../../data/providers/order_provider.dart';
import '../../data/providers/voucher_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _addressController = TextEditingController();
  String _selectedPaymentMethod = 'Cash';
  bool _isProcessing = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final cartNotifier = ref.read(cartControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        actions: [
          if (cartState.cart.items.isNotEmpty)
            TextButton(
              onPressed: _showClearCartDialog,
              child: const Text('Xóa tất cả', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (cartState.cart.items.isEmpty) {
            return _buildEmptyCart();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartState.cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cartState.cart.items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: item.image != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(item.image!, fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.image_not_supported, color: Colors.grey)),
                                    )
                                  : const Icon(Icons.image, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.productName,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text('${item.price.toStringAsFixed(0)} ₫',
                                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                if (item.quantity > 1) {
                                                  cartNotifier.updateQuantity(item.productId, item.quantity - 1);
                                                } else {
                                                  _showRemoveDialog(item.productId, item.productName);
                                                }
                                              },
                                              child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.remove, size: 18)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                              child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            InkWell(
                                              onTap: () => cartNotifier.updateQuantity(item.productId, item.quantity + 1),
                                              child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.add, size: 18)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      Text('${item.total.toStringAsFixed(0)} ₫',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _showRemoveDialog(item.productId, item.productName),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildCheckoutSection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('Giỏ hàng trống', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Hãy thêm sản phẩm vào giỏ hàng', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Tiếp tục mua sắm')),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection() {
    final cartState = ref.watch(cartControllerProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng cộng:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                Text('${cartState.cart.totalAmount.toStringAsFixed(0)} ₫',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _showCheckoutDialog,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isProcessing
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                    : const Text('Đặt hàng ngay', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveDialog(String productId, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: Text('Bạn có muốn xóa "$productName" khỏi giỏ hàng?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              ref.read(cartControllerProvider.notifier).removeFromCart(productId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa Giỏ hàng'),
        content: const Text('Bạn có muốn xóa tất cả sản phẩm trong giỏ hàng?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              ref.read(cartControllerProvider.notifier).clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog() {
    ref.read(voucherControllerProvider.notifier).loadVouchers();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final voucherState = ref.watch(voucherControllerProvider);
          final cartTotal = ref.read(cartControllerProvider).cart.totalAmount;
          final discount = ref.read(voucherControllerProvider.notifier).calculateDiscount(cartTotal);
          final finalTotal = cartTotal - discount;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thông tin đặt hàng', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Địa chỉ giao hàng *', prefixIcon: Icon(Icons.location_on_outlined)),
                      maxLines: 2),
                  const SizedBox(height: 16),
                  const Text('Phương thức thanh toán', style: TextStyle(fontWeight: FontWeight.w600)),
                  RadioListTile<String>(title: const Text('Tiền mặt (COD)'), value: 'Cash', groupValue: _selectedPaymentMethod,
                      onChanged: (v) => setModalState(() => _selectedPaymentMethod = v!)),
                  RadioListTile<String>(title: const Text('Chuyển khoản'), value: 'BankTransfer', groupValue: _selectedPaymentMethod,
                      onChanged: (v) => setModalState(() => _selectedPaymentMethod = v!)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mã Giảm Giá', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextButton.icon(
                        onPressed: () => _showVoucherSheet(voucherState.vouchers, cartTotal),
                        icon: const Icon(Icons.local_offer_outlined, size: 18),
                        label: Text(voucherState.appliedVoucher != null ? voucherState.appliedVoucher!.code : 'Chọn voucher'),
                      ),
                    ],
                  ),
                  if (discount > 0) ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Giảm giá:', style: TextStyle(color: Colors.green)),
                        Text('-${discount.toStringAsFixed(0)} ₫', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng tiền:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text('${finalTotal.toStringAsFixed(0)} ₫',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : () => _processOrder(voucherState.appliedVoucher?.voucherId),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _isProcessing
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                          : const Text('Xác nhận đặt hàng', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showVoucherSheet(List<Voucher> vouchers, double orderAmount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            const Padding(padding: EdgeInsets.all(16), child: Text('Chọn voucher', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: vouchers.length,
                itemBuilder: (ctx, index) {
                  final voucher = vouchers[index];
                  final canUse = voucher.isValid && (voucher.minOrderAmount == null || orderAmount >= voucher.minOrderAmount!);
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: canUse ? AppTheme.primaryColor : Colors.grey,
                        child: Text('${voucher.discountPercent.toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      title: Text(voucher.code),
                      subtitle: Text(voucher.description ?? 'Giảm ${voucher.discountPercent.toStringAsFixed(0)}%'),
                      trailing: canUse
                          ? TextButton(
                              onPressed: () {
                                ref.read(voucherControllerProvider.notifier).applyVoucher(voucher.code, orderAmount);
                                Navigator.pop(ctx);
                              },
                              child: const Text('Áp dụng'),
                            )
                          : const Text('Không áp dụng', style: TextStyle(color: Colors.grey)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processOrder(int? voucherId) async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ giao hàng'), backgroundColor: AppTheme.errorColor),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final cartNotifier = ref.read(cartControllerProvider.notifier);
    final orderNotifier = ref.read(orderControllerProvider.notifier);

    final success = await orderNotifier.createOrder(
      shippingAddress: _addressController.text.trim(),
      paymentMethod: _selectedPaymentMethod,
      orderItems: cartNotifier.getOrderItems(),
      voucherId: voucherId,
    );

    setState(() => _isProcessing = false);

    if (success && mounted) {
      await cartNotifier.clearCart();
      ref.read(voucherControllerProvider.notifier).removeAppliedVoucher();
      if (mounted) Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(children: [Icon(Icons.check_circle, color: AppTheme.successColor), SizedBox(width: 8), Text('Đặt hàng thành công')]),
          content: const Text('Cảm ơn bạn đã đặt hàng! Đơn hàng của bạn đang được xử lý.'),
          actions: [ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
    } else if (mounted) {
      final err = ref.read(orderControllerProvider).error ?? 'Đặt hàng thất bại';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: AppTheme.errorColor));
    }
  }
}
