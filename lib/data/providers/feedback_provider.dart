import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/feedback.dart';
import '../services/feedback_service.dart';

part 'feedback_provider.g.dart';

class FeedbackState {
  final bool isLoading;
  final String? error;
  final List<Feedback> feedbacks;
  final double averageRating;

  const FeedbackState({
    this.isLoading = false,
    this.error,
    this.feedbacks = const [],
    this.averageRating = 0,
  });

  FeedbackState copyWith({
    bool? isLoading,
    String? error,
    List<Feedback>? feedbacks,
    double? averageRating,
  }) {
    return FeedbackState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
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
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addFeedback({
    required String productId,
    required int rating,
    String? comment,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(feedbackServiceProvider).createFeedback(
            productId: productId,
            rating: rating,
            comment: comment,
          );
      await loadFeedbacks(productId);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
