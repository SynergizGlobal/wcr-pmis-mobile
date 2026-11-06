// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rfi_report_details_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rfiReportDetailsHash() => r'a951d53eb9d0daf805080baa15a63c6c603b0e2c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [rfiReportDetails].
@ProviderFor(rfiReportDetails)
const rfiReportDetailsProvider = RfiReportDetailsFamily();

/// See also [rfiReportDetails].
class RfiReportDetailsFamily extends Family<AsyncValue<RfiReportDetailsData>> {
  /// See also [rfiReportDetails].
  const RfiReportDetailsFamily();

  /// See also [rfiReportDetails].
  RfiReportDetailsProvider call(String id) {
    return RfiReportDetailsProvider(id);
  }

  @override
  RfiReportDetailsProvider getProviderOverride(
    covariant RfiReportDetailsProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'rfiReportDetailsProvider';
}

/// See also [rfiReportDetails].
class RfiReportDetailsProvider
    extends AutoDisposeFutureProvider<RfiReportDetailsData> {
  /// See also [rfiReportDetails].
  RfiReportDetailsProvider(String id)
    : this._internal(
        (ref) => rfiReportDetails(ref as RfiReportDetailsRef, id),
        from: rfiReportDetailsProvider,
        name: r'rfiReportDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$rfiReportDetailsHash,
        dependencies: RfiReportDetailsFamily._dependencies,
        allTransitiveDependencies:
            RfiReportDetailsFamily._allTransitiveDependencies,
        id: id,
      );

  RfiReportDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<RfiReportDetailsData> Function(RfiReportDetailsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RfiReportDetailsProvider._internal(
        (ref) => create(ref as RfiReportDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<RfiReportDetailsData> createElement() {
    return _RfiReportDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RfiReportDetailsProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RfiReportDetailsRef
    on AutoDisposeFutureProviderRef<RfiReportDetailsData> {
  /// The parameter `id` of this provider.
  String get id;
}

class _RfiReportDetailsProviderElement
    extends AutoDisposeFutureProviderElement<RfiReportDetailsData>
    with RfiReportDetailsRef {
  _RfiReportDetailsProviderElement(super.provider);

  @override
  String get id => (origin as RfiReportDetailsProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
