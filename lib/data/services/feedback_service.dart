import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/debug/agent_debug_log.dart';
import '../../core/utils/shared_prefs.dart';
import '../models/feedback.dart';
import 'api_client.dart';

class FeedbackService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Feedback>> getFeedbacksByProduct(String productId) async {
    agentDebugLog(
      'feedback_service.dart:getFeedbacksByProduct',
      'before_get',
      {
        'baseUrl': ApiConstants.baseUrl,
        'path': '${ApiConstants.feedbacks}/filter',
        'productId': productId,
      },
      hypothesisId: 'H2',
    );

    final response = await _apiClient.get(
      '${ApiConstants.feedbacks}/filter',
      queryParameters: {'productId': productId},
      requireAuth: false,
    );

    final data = response.data;

    agentDebugLog(
      'feedback_service.dart:getFeedbacksByProduct',
      'after_get',
      {
        'statusCode': response.statusCode,
        'dataRuntimeType': data.runtimeType.toString(),
        'listLength': data is List ? data.length : -1,
      },
      hypothesisId: 'H4',
    );

    if (data is List) {
      return data
          .map((json) => Feedback.fromJson((json as Map).cast<String, dynamic>()))
          .toList();
    }

    if (data is Map<String, dynamic> && data['data'] is List) {
      final List<dynamic> feedbacksJson = (data['data'] as List?) ?? [];
      return feedbacksJson
          .map((json) => Feedback.fromJson((json as Map).cast<String, dynamic>()))
          .toList();
    }

    return [];
  }

  Future<Feedback> createFeedback({
    required String productId,
    required int rating,
    String? comment,
  }) async {
    final customerId = SharedPrefs.getUserId();

    if (customerId == null || customerId.trim().isEmpty) {
      throw Exception('Không tìm thấy CustomerID. Vui lòng đăng nhập lại.');
    }

    final formData = FormData.fromMap({
      'ProductID': productId,
      'CustomerID': customerId,
      'Rating': rating,
      if (comment != null && comment.trim().isNotEmpty)
        'Comment': comment.trim(),
    });

    final response = await _apiClient.post(
      '${ApiConstants.feedbacks}',
      data: formData,
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) {
        return Feedback.fromJson((data['data'] as Map).cast<String, dynamic>());
      }
      return Feedback.fromJson(data);
    }

    throw Exception('Phản hồi không hợp lệ từ server.');
  }

  Future<Feedback> updateFeedback({
    required int feedbackId,
    required int rating,
    String? comment,
  }) async {
    final customerId = SharedPrefs.getUserId();

    if (customerId == null || customerId.trim().isEmpty) {
      throw Exception('Không tìm thấy CustomerID. Vui lòng đăng nhập lại.');
    }

    final formData = FormData.fromMap({
      'CustomerID': customerId,
      'Rating': rating,
      if (comment != null && comment.trim().isNotEmpty)
        'Comment': comment.trim(),
    });

    final response = await _apiClient.put(
      '${ApiConstants.feedbacks}/$feedbackId',
      data: formData,
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) {
        return Feedback.fromJson((data['data'] as Map).cast<String, dynamic>());
      }
      return Feedback.fromJson(data);
    }

    throw Exception('Phản hồi không hợp lệ từ server.');
  }

  Future<void> deleteFeedback(int feedbackId) async {
    final customerId = SharedPrefs.getUserId();

    if (customerId == null || customerId.trim().isEmpty) {
      throw Exception('Không tìm thấy CustomerID. Vui lòng đăng nhập lại.');
    }

    final formData = FormData.fromMap({
      'CustomerID': customerId,
      'Status': 'Deleted',
    });

    await _apiClient.put(
      '${ApiConstants.feedbacks}/$feedbackId',
      data: formData,
    );
  }
}