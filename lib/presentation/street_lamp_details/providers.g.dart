// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lampDetailsHash() => r'31feb6cbd224ed60b88a5e1af1ae4ed77925c4fc';

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

abstract class _$LampDetails
    extends BuildlessAutoDisposeAsyncNotifier<StreetLamp> {
  late final String lampId;

  FutureOr<StreetLamp> build({
    required String lampId,
  });
}

/// See also [LampDetails].
@ProviderFor(LampDetails)
const lampDetailsProvider = LampDetailsFamily();

/// See also [LampDetails].
class LampDetailsFamily extends Family<AsyncValue<StreetLamp>> {
  /// See also [LampDetails].
  const LampDetailsFamily();

  /// See also [LampDetails].
  LampDetailsProvider call({
    required String lampId,
  }) {
    return LampDetailsProvider(
      lampId: lampId,
    );
  }

  @override
  LampDetailsProvider getProviderOverride(
    covariant LampDetailsProvider provider,
  ) {
    return call(
      lampId: provider.lampId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'lampDetailsProvider';
}

/// See also [LampDetails].
class LampDetailsProvider
    extends AutoDisposeAsyncNotifierProviderImpl<LampDetails, StreetLamp> {
  /// See also [LampDetails].
  LampDetailsProvider({
    required String lampId,
  }) : this._internal(
          () => LampDetails()..lampId = lampId,
          from: lampDetailsProvider,
          name: r'lampDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$lampDetailsHash,
          dependencies: LampDetailsFamily._dependencies,
          allTransitiveDependencies:
              LampDetailsFamily._allTransitiveDependencies,
          lampId: lampId,
        );

  LampDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.lampId,
  }) : super.internal();

  final String lampId;

  @override
  FutureOr<StreetLamp> runNotifierBuild(
    covariant LampDetails notifier,
  ) {
    return notifier.build(
      lampId: lampId,
    );
  }

  @override
  Override overrideWith(LampDetails Function() create) {
    return ProviderOverride(
      origin: this,
      override: LampDetailsProvider._internal(
        () => create()..lampId = lampId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        lampId: lampId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<LampDetails, StreetLamp>
      createElement() {
    return _LampDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LampDetailsProvider && other.lampId == lampId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, lampId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin LampDetailsRef on AutoDisposeAsyncNotifierProviderRef<StreetLamp> {
  /// The parameter `lampId` of this provider.
  String get lampId;
}

class _LampDetailsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<LampDetails, StreetLamp>
    with LampDetailsRef {
  _LampDetailsProviderElement(super.provider);

  @override
  String get lampId => (origin as LampDetailsProvider).lampId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
