import '../../core/constants/api_constants.dart';
import '../models/feedback.dart';
import 'api_client.dart';

class FeedbackService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Feedback>> getFeedbacksByProduct(String productId) async {
    final response = await _apiClient.get(
      '${ApiConstants.feedbacks}/filter',
      queryParameters: {'productId': productId},
    );

    final data = response.data;
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
    final response = await _apiClient.post(
      ApiConstants.feedbacks,
      data: {
        'productId': productId,
        'rating': rating,
        'comment': comment,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return Feedback.fromJson(data);
    }
    if (data is Map && data['data'] is Map) {
      return Feedback.fromJson((data['data'] as Map).cast<String, dynamic>());
    }
    throw Exception('Không thể tạo đánh giá');
  }

  Future<void> deleteFeedback(int feedbackId) async {
    await _apiClient.delete('${ApiConstants.feedbacks}/$feedbackId');
  }
}
