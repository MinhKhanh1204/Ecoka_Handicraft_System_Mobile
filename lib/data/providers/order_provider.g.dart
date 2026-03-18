// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderServiceHash() => r'8c4cac95abd6f29c91ef03dd7df5a64f3bfad57f';

/// See also [orderService].
@ProviderFor(orderService)
final orderServiceProvider = AutoDisposeProvider<OrderService>.internal(
  orderService,
  name: r'orderServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$orderServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrderServiceRef = AutoDisposeProviderRef<OrderService>;
String _$orderControllerHash() => r'c2f2cbd2013ac086fe4a82546822e8f6982a2f7c';

/// See also [OrderController].
@ProviderFor(OrderController)
final orderControllerProvider =
    AutoDisposeNotifierProvider<OrderController, OrderState>.internal(
      OrderController.new,
      name: r'orderControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$orderControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OrderController = AutoDisposeNotifier<OrderState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
