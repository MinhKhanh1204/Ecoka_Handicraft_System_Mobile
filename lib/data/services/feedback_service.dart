import '../../core/constants/api_constants.dart';
import '../../core/debug/agent_debug_log.dart';
import '../models/feedback.dart';
import 'api_client.dart';

class FeedbackService {
  final ApiClient _apiClient = ApiClient();

  /// Lấy danh sách đánh giá theo sản phẩm (endpoint công khai, không cần đăng nhập).
  Future<List<Feedback>> getFeedbacksByProduct(String productId) async {
    // #region agent log
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
    // #endregion
    final response = await _apiClient.get(
      '${ApiConstants.feedbacks}/filter',
      queryParameters: {'productId': productId},
      requireAuth: false,
    );

    final data = response.data;
    // #region agent log
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
    // #endregion
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
    // Gọi endpoint /feedbacks/create (JWT cung cấp CustomerID tự động)
    final response = await _apiClient.post(
      '${ApiConstants.feedbacks}/create',
      data: {
        'productId': productId,
        'rating': rating,
        'comment': comment,
      },
    );

    // Backend trả về đối tượng feedback trực tiếp (CreatedAtAction result)
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return Feedback.fromJson(data);
    }
    throw Exception('Phản hồi không hợp lệ từ server.');
  }

  Future<void> deleteFeedback(int feedbackId) async {
    await _apiClient.delete('${ApiConstants.feedbacks}/$feedbackId');
  }
}
