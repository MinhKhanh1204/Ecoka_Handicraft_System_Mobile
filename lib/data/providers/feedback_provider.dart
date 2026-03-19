import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/debug/agent_debug_log.dart';
import '../../core/errors/exceptions.dart';
import '../models/feedback.dart';
import '../services/feedback_service.dart';

part 'feedback_provider.g.dart';

class FeedbackState {
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final List<Feedback> feedbacks;
  final double averageRating;

  const FeedbackState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.feedbacks = const [],
    this.averageRating = 0,
  });

  FeedbackState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    List<Feedback>? feedbacks,
    double? averageRating,
  }) {
    return FeedbackState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      feedbacks: feedbacks ?? this.feedbacks,
      averageRating: averageRating ?? this.averageRating,
    );
  }
}

@riverpod
FeedbackService feedbackService(FeedbackServiceRef ref) => FeedbackService();

@riverpod
class FeedbackController extends _$FeedbackController {
  @override
  FeedbackState build() => const FeedbackState();

  Future<void> loadFeedbacks(String productId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final feedbacks = await ref.read(feedbackServiceProvider).getFeedbacksByProduct(productId);
      final avg = feedbacks.isEmpty
          ? 0.0
          : feedbacks.fold<double>(0, (sum, f) => sum + f.rating) / feedbacks.length;
      state = state.copyWith(isLoading: false, feedbacks: feedbacks, averageRating: avg);
    } on ApiException catch (e) {
      // #region agent log
      agentDebugLog(
        'feedback_provider.dart:loadFeedbacks',
        'api_exception',
        {
          'statusCode': e.statusCode,
          'messageSnippet': e.message.length > 300
              ? e.message.substring(0, 300)
              : e.message,
          'productId': productId,
        },
        hypothesisId: 'H3',
      );
      // #endregion
      // 401: token hết hạn hoặc chưa đăng nhập — hiển thị thông báo ngắn, không logout
      final message = e.statusCode == 401
          ? 'Vui lòng đăng nhập để xem đánh giá.'
          : e.message;
      state = state.copyWith(isLoading: false, feedbacks: [], averageRating: 0, error: message);
    } catch (e) {
      // #region agent log
      agentDebugLog(
        'feedback_provider.dart:loadFeedbacks',
        'generic_exception',
        {
          'type': e.runtimeType.toString(),
          'toStringSnippet': e.toString().length > 300
              ? e.toString().substring(0, 300)
              : e.toString(),
          'productId': productId,
        },
        hypothesisId: 'H3',
      );
      // #endregion
      state = state.copyWith(
        isLoading: false,
        feedbacks: [],
        averageRating: 0,
        error: 'Không thể tải đánh giá. Thử lại sau.',
      );
    }
  }

  Future<String?> addFeedback({
    required String productId,
    required int rating,
    String? comment,
  }) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await ref.read(feedbackServiceProvider).createFeedback(
            productId: productId,
            rating: rating,
            comment: comment,
          );
      await loadFeedbacks(productId);
      state = state.copyWith(successMessage: 'Cảm ơn bạn đã đánh giá!');
      return null;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return e.message;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return e.toString();
    }
  }
}
