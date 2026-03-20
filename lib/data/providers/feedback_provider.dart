import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/debug/agent_debug_log.dart';
import '../../core/errors/exceptions.dart';
import '../models/feedback.dart';
import '../services/auth_service.dart';
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
    bool clearError = false,
    bool clearSuccessMessage = false,
  }) {
    return FeedbackState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
      feedbacks: feedbacks ?? this.feedbacks,
      averageRating: averageRating ?? this.averageRating,
    );
  }
}

@riverpod
FeedbackService feedbackService(FeedbackServiceRef ref) => FeedbackService();

@riverpod
AuthService authService(AuthServiceRef ref) => AuthService();

@riverpod
class FeedbackController extends _$FeedbackController {
  @override
  FeedbackState build() => const FeedbackState();

  Future<void> loadFeedbacks(String productId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccessMessage: true,
    );

    try {
      final feedbacks =
      await ref.read(feedbackServiceProvider).getFeedbacksByProduct(productId);

      final visibleFeedbacks = feedbacks.where((f) {
        final status = f.status?.trim().toLowerCase();
        return status != 'deleted';
      }).toList();

      visibleFeedbacks.sort((a, b) {
        final aTime = a.updatedAt ?? a.createdAt;
        final bTime = b.updatedAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });

      final enriched = await _enrichUsernames(visibleFeedbacks);

      final avg = enriched.isEmpty
          ? 0.0
          : enriched.fold<double>(0, (sum, f) => sum + f.rating) / enriched.length;

      state = state.copyWith(
        isLoading: false,
        feedbacks: enriched,
        averageRating: avg,
      );
    } on ApiException catch (e) {
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

      final message = e.statusCode == 401
          ? 'Vui lòng đăng nhập để xem đánh giá.'
          : e.message;

      state = state.copyWith(
        isLoading: false,
        feedbacks: const [],
        averageRating: 0,
        error: message,
      );
    } catch (e) {
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

      state = state.copyWith(
        isLoading: false,
        feedbacks: const [],
        averageRating: 0,
        error: 'Không thể tải đánh giá. Thử lại sau.',
      );
    }
  }

  Future<List<Feedback>> _enrichUsernames(List<Feedback> feedbacks) async {
    final authSvc = ref.read(authServiceProvider);
    final Map<String, String> cache = {};
    final List<Feedback> result = [];

    for (final feedback in feedbacks) {
      String? resolvedName = feedback.username;

      if ((resolvedName == null || resolvedName.trim().isEmpty) &&
          feedback.customerId != null &&
          feedback.customerId!.trim().isNotEmpty) {
        final customerId = feedback.customerId!.trim();

        if (cache.containsKey(customerId)) {
          resolvedName = cache[customerId];
        } else {
          try {
            final user = await authSvc.getUserByCustomerId(customerId);

            resolvedName =
            (user?.fullName != null && user!.fullName!.trim().isNotEmpty)
                ? user.fullName!
                : (user!.username != null && user!.username!.trim().isNotEmpty)
                ? user.username!
                : (user.email != null && user.email!.trim().isNotEmpty)
                ? user.email!
                : customerId;

            cache[customerId] = resolvedName;
          } catch (_) {
            resolvedName = customerId;
            cache[customerId] = customerId;
          }
        }
      }

      result.add(
        feedback.copyWith(
          username: (resolvedName != null && resolvedName.trim().isNotEmpty)
              ? resolvedName
              : (feedback.customerId ?? 'Người dùng'),
        ),
      );
    }

    return result;
  }

  Future<String?> addFeedback({
    required String productId,
    required int rating,
    String? comment,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccessMessage: true,
    );

    try {
      await ref.read(feedbackServiceProvider).createFeedback(
        productId: productId,
        rating: rating,
        comment: comment,
      );

      await loadFeedbacks(productId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Cảm ơn bạn đã đánh giá!',
      );
      return null;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return e.message;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể gửi đánh giá.',
      );
      return 'Không thể gửi đánh giá.';
    }
  }

  Future<String?> updateFeedback({
    required int feedbackId,
    required String productId,
    required int rating,
    String? comment,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccessMessage: true,
    );

    try {
      await ref.read(feedbackServiceProvider).updateFeedback(
        feedbackId: feedbackId,
        rating: rating,
        comment: comment,
      );

      await loadFeedbacks(productId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Cập nhật đánh giá thành công!',
      );
      return null;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return e.message;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể cập nhật đánh giá.',
      );
      return 'Không thể cập nhật đánh giá.';
    }
  }

  Future<String?> deleteFeedback({
    required int feedbackId,
    required String productId,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccessMessage: true,
    );

    try {
      await ref.read(feedbackServiceProvider).deleteFeedback(feedbackId);
      await loadFeedbacks(productId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Xóa đánh giá thành công!',
      );
      return null;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return e.message;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể xóa đánh giá.',
      );
      return 'Không thể xóa đánh giá.';
    }
  }
}