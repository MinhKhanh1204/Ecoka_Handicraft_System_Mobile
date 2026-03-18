import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/voucher.dart';
import '../services/voucher_service.dart';

part 'voucher_provider.g.dart';

class VoucherState {
  final bool isLoading;
  final String? error;
  final List<Voucher> vouchers;
  final Voucher? appliedVoucher;

  const VoucherState({
    this.isLoading = false,
    this.error,
    this.vouchers = const [],
    this.appliedVoucher,
  });

  VoucherState copyWith({
    bool? isLoading,
    String? error,
    List<Voucher>? vouchers,
    Voucher? appliedVoucher,
    bool clearAppliedVoucher = false,
  }) {
    return VoucherState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      vouchers: vouchers ?? this.vouchers,
      appliedVoucher: clearAppliedVoucher ? null : (appliedVoucher ?? this.appliedVoucher),
    );
  }
}

@riverpod
VoucherService voucherService(VoucherServiceRef ref) => VoucherService();

@riverpod
class VoucherController extends _$VoucherController {
  @override
  VoucherState build() => const VoucherState();

  Future<void> loadVouchers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final vouchers = await ref.read(voucherServiceProvider).getAvailableVouchers();
      state = state.copyWith(isLoading: false, vouchers: vouchers);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> applyVoucher(String code, double orderAmount) async {
    state = state.copyWith(isLoading: true, error: null, clearAppliedVoucher: true);
    try {
      final voucher = await ref.read(voucherServiceProvider).validateVoucher(code, orderAmount);
      if (voucher != null && voucher.isValid) {
        state = state.copyWith(isLoading: false, appliedVoucher: voucher);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Mã giảm giá không hợp lệ hoặc đã hết hạn');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void removeAppliedVoucher() {
    state = state.copyWith(clearAppliedVoucher: true);
  }

  double calculateDiscount(double orderAmount) {
    final voucher = state.appliedVoucher;
    if (voucher == null) return 0;
    return voucher.calculateDiscount(orderAmount);
  }
}
