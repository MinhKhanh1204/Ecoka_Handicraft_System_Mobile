// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedbackServiceHash() => r'ffefe9778ff0521b096c7ef3bfeec389dadb262b';

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
String _$authServiceHash() => r'0dfa6cd7b3d2c42d27d44dbdbba6d3799e31f428';

/// See also [authService].
@ProviderFor(authService)
final authServiceProvider = AutoDisposeProvider<AuthService>.internal(
  authService,
  name: r'authServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthServiceRef = AutoDisposeProviderRef<AuthService>;
String _$feedbackControllerHash() =>
    r'3f5f15b1b094b755a5ad9090e5ab6c0df902067f';

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
