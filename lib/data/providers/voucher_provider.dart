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
      print('--- [VoucherController] Bắt đầu gọi API lấy danh sách voucher ---');
      final vouchers = await ref.read(voucherServiceProvider).getAvailableVouchers();
      print('--- [VoucherController] Lấy thành công ${vouchers.length} voucher ---');
      for (var v in vouchers) {
        print('--- [Voucher] id=${v.voucherId}, code="${v.code}", desc="${v.description}", isActive=${v.isActive}, minAmount=${v.minOrderAmount}, Exp=${v.endDate} ---');
      }
      state = state.copyWith(isLoading: false, vouchers: vouchers);
    } catch (e) {
      print('--- [VoucherController] LỖI khi lấy danh sách voucher: $e ---');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> applyVoucher(String code, double orderAmount) async {
    state = state.copyWith(isLoading: true, error: null, clearAppliedVoucher: true);
    try {
      final codeUpper = code.trim().toUpperCase();
      final match = state.vouchers.where((v) => v.code.toUpperCase() == codeUpper).toList();
      final voucher = match.isNotEmpty ? match.first : null;

      if (voucher != null) {
        if (!voucher.isValid) {
          state = state.copyWith(isLoading: false, error: 'Mã giảm giá không hợp lệ hoặc đã hết hạn (isValid = false)');
          return false;
        }
        if (voucher.minOrderAmount != null && orderAmount < voucher.minOrderAmount!) {
          state = state.copyWith(isLoading: false, error: 'Đơn hàng chưa đạt giá trị tối thiểu (${voucher.minOrderAmount!.toStringAsFixed(0)} ₫)');
          return false;
        }
        
        state = state.copyWith(isLoading: false, appliedVoucher: voucher);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Mã giảm giá không tồn tại');
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
