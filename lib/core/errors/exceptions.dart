import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;

  static ApiException fromDioError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      String message = 'Đã có lỗi xảy ra';
      if (data is Map<String, dynamic>) {
        message = (data['message'] ?? data['error'] ?? message).toString();
      } else if (data is String && data.isNotEmpty) {
        message = data;
      } else if (error.message?.isNotEmpty == true) {
        message = error.message!;
      }

      return ApiException(message, statusCode: statusCode);
    }

    return ApiException(error.toString());
  }
}

