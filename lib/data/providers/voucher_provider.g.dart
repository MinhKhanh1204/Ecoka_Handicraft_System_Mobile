// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voucher_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$voucherServiceHash() => r'895ef21189008353974c38ae401b6069963c8c53';

/// See also [voucherService].
@ProviderFor(voucherService)
final voucherServiceProvider = AutoDisposeProvider<VoucherService>.internal(
  voucherService,
  name: r'voucherServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$voucherServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VoucherServiceRef = AutoDisposeProviderRef<VoucherService>;
String _$voucherControllerHash() => r'b75f6596bee1404914031416173ef5258d14c180';

/// See also [VoucherController].
@ProviderFor(VoucherController)
final voucherControllerProvider =
    AutoDisposeNotifierProvider<VoucherController, VoucherState>.internal(
      VoucherController.new,
      name: r'voucherControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$voucherControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VoucherController = AutoDisposeNotifier<VoucherState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
