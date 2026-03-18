import '../../core/constants/api_constants.dart';
import '../models/voucher.dart';
import 'api_client.dart';

class VoucherService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Voucher>> getAvailableVouchers() async {
    final response = await _apiClient.get(ApiConstants.vouchers);
    final data = response.data;

    if (data is List) {
      return data
          .map((json) => Voucher.fromJson((json as Map).cast<String, dynamic>()))
          .toList();
    }

    if (data is Map<String, dynamic> && data['data'] is List) {
      final List<dynamic> vouchersJson = (data['data'] as List?) ?? [];
      return vouchersJson
          .map((json) => Voucher.fromJson((json as Map).cast<String, dynamic>()))
          .toList();
    }

    return [];
  }

  Future<Voucher?> validateVoucher(String code, double orderAmount) async {
    final response = await _apiClient.post(
      '${ApiConstants.vouchers}/validate',
      data: {'code': code, 'orderAmount': orderAmount},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return Voucher.fromJson(data);
    }
    if (data is Map && data['data'] is Map) {
      return Voucher.fromJson((data['data'] as Map).cast<String, dynamic>());
    }
    return null;
  }
}
