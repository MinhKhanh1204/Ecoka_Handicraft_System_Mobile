// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedbackServiceHash() => r'2e037d0b8df4da4c0c8546c5dfcb05ebd01192a4';

/// See also [feedbackService].
@ProviderFor(feedbackService)
final feedbackServiceProvider = AutoDisposeProvider<FeedbackService>.internal(
  feedbackService,
  name: r'feedbackServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$feedbackServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeedbackServiceRef = AutoDisposeProviderRef<FeedbackService>;
String _$feedbackControllerHash() =>
    r'8499da058079450387fd939789710aca7792228d';

/// See also [FeedbackController].
@ProviderFor(FeedbackController)
final feedbackControllerProvider =
    AutoDisposeNotifierProvider<FeedbackController, FeedbackState>.internal(
      FeedbackController.new,
      name: r'feedbackControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$feedbackControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FeedbackController = AutoDisposeNotifier<FeedbackState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
