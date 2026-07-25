// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assign_client_person_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$assignExecutiveNamesHash() =>
    r'a01a38c893804234f86c182cf78c4799b5062e7c';

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

/// See also [assignExecutiveNames].
@ProviderFor(assignExecutiveNames)
const assignExecutiveNamesProvider = AssignExecutiveNamesFamily();

/// See also [assignExecutiveNames].
class AssignExecutiveNamesFamily extends Family<AsyncValue<List<RfiEngineerOption>>> {
  /// See also [assignExecutiveNames].
  const AssignExecutiveNamesFamily();

  /// See also [assignExecutiveNames].
  AssignExecutiveNamesProvider call(String contractId) {
    return AssignExecutiveNamesProvider(contractId);
  }

  @override
  AssignExecutiveNamesProvider getProviderOverride(
    covariant AssignExecutiveNamesProvider provider,
  ) {
    return call(provider.contractId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'assignExecutiveNamesProvider';
}

/// See also [assignExecutiveNames].
class AssignExecutiveNamesProvider
    extends AutoDisposeFutureProvider<List<RfiEngineerOption>> {
  /// See also [assignExecutiveNames].
  AssignExecutiveNamesProvider(String contractId)
    : this._internal(
        (ref) =>
            assignExecutiveNames(ref as AssignExecutiveNamesRef, contractId),
        from: assignExecutiveNamesProvider,
        name: r'assignExecutiveNamesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$assignExecutiveNamesHash,
        dependencies: AssignExecutiveNamesFamily._dependencies,
        allTransitiveDependencies:
            AssignExecutiveNamesFamily._allTransitiveDependencies,
        contractId: contractId,
      );

  AssignExecutiveNamesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contractId,
  }) : super.internal();

  final String contractId;

  @override
  Override overrideWith(
    FutureOr<List<RfiEngineerOption>> Function(AssignExecutiveNamesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AssignExecutiveNamesProvider._internal(
        (ref) => create(ref as AssignExecutiveNamesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contractId: contractId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RfiEngineerOption>> createElement() {
    return _AssignExecutiveNamesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AssignExecutiveNamesProvider &&
        other.contractId == contractId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contractId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AssignExecutiveNamesRef on AutoDisposeFutureProviderRef<List<RfiEngineerOption>> {
  /// The parameter `contractId` of this provider.
  String get contractId;
}

class _AssignExecutiveNamesProviderElement
    extends AutoDisposeFutureProviderElement<List<RfiEngineerOption>>
    with AssignExecutiveNamesRef {
  _AssignExecutiveNamesProviderElement(super.provider);

  @override
  String get contractId => (origin as AssignExecutiveNamesProvider).contractId;
}

String _$assignClientPersonControllerHash() =>
    r'e393799a4126fa89feb67289c3ef2f19ff7a4b98';

/// See also [AssignClientPersonController].
@ProviderFor(AssignClientPersonController)
final assignClientPersonControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      AssignClientPersonController,
      void
    >.internal(
      AssignClientPersonController.new,
      name: r'assignClientPersonControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$assignClientPersonControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AssignClientPersonController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
