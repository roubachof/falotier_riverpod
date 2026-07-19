// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$zoneLampsHash() => r'45ae7976769f95a71d7712fbff76b0fd49c14213';

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

/// See also [zoneLamps].
@ProviderFor(zoneLamps)
const zoneLampsProvider = ZoneLampsFamily();

/// See also [zoneLamps].
class ZoneLampsFamily extends Family<AsyncValue<IList<StreetLamp>>> {
  /// See also [zoneLamps].
  const ZoneLampsFamily();

  /// See also [zoneLamps].
  ZoneLampsProvider call({
    required CityZone zone,
  }) {
    return ZoneLampsProvider(
      zone: zone,
    );
  }

  @override
  ZoneLampsProvider getProviderOverride(
    covariant ZoneLampsProvider provider,
  ) {
    return call(
      zone: provider.zone,
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
  String? get name => r'zoneLampsProvider';
}

/// See also [zoneLamps].
class ZoneLampsProvider extends AutoDisposeFutureProvider<IList<StreetLamp>> {
  /// See also [zoneLamps].
  ZoneLampsProvider({
    required CityZone zone,
  }) : this._internal(
          (ref) => zoneLamps(
            ref as ZoneLampsRef,
            zone: zone,
          ),
          from: zoneLampsProvider,
          name: r'zoneLampsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$zoneLampsHash,
          dependencies: ZoneLampsFamily._dependencies,
          allTransitiveDependencies: ZoneLampsFamily._allTransitiveDependencies,
          zone: zone,
        );

  ZoneLampsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.zone,
  }) : super.internal();

  final CityZone zone;

  @override
  Override overrideWith(
    FutureOr<IList<StreetLamp>> Function(ZoneLampsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ZoneLampsProvider._internal(
        (ref) => create(ref as ZoneLampsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        zone: zone,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<IList<StreetLamp>> createElement() {
    return _ZoneLampsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ZoneLampsProvider && other.zone == zone;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, zone.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ZoneLampsRef on AutoDisposeFutureProviderRef<IList<StreetLamp>> {
  /// The parameter `zone` of this provider.
  CityZone get zone;
}

class _ZoneLampsProviderElement
    extends AutoDisposeFutureProviderElement<IList<StreetLamp>>
    with ZoneLampsRef {
  _ZoneLampsProviderElement(super.provider);

  @override
  CityZone get zone => (origin as ZoneLampsProvider).zone;
}

String _$streetLampHash() => r'5a1cb4de3bf0baf8d723d88a877b684603bd138a';

/// See also [streetLamp].
@ProviderFor(streetLamp)
const streetLampProvider = StreetLampFamily();

/// See also [streetLamp].
class StreetLampFamily extends Family<AsyncValue<StreetLamp>> {
  /// See also [streetLamp].
  const StreetLampFamily();

  /// See also [streetLamp].
  StreetLampProvider call({
    required String id,
  }) {
    return StreetLampProvider(
      id: id,
    );
  }

  @override
  StreetLampProvider getProviderOverride(
    covariant StreetLampProvider provider,
  ) {
    return call(
      id: provider.id,
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
  String? get name => r'streetLampProvider';
}

/// See also [streetLamp].
class StreetLampProvider extends AutoDisposeFutureProvider<StreetLamp> {
  /// See also [streetLamp].
  StreetLampProvider({
    required String id,
  }) : this._internal(
          (ref) => streetLamp(
            ref as StreetLampRef,
            id: id,
          ),
          from: streetLampProvider,
          name: r'streetLampProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$streetLampHash,
          dependencies: StreetLampFamily._dependencies,
          allTransitiveDependencies:
              StreetLampFamily._allTransitiveDependencies,
          id: id,
        );

  StreetLampProvider._internal(
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
    FutureOr<StreetLamp> Function(StreetLampRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StreetLampProvider._internal(
        (ref) => create(ref as StreetLampRef),
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
  AutoDisposeFutureProviderElement<StreetLamp> createElement() {
    return _StreetLampProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StreetLampProvider && other.id == id;
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
mixin StreetLampRef on AutoDisposeFutureProviderRef<StreetLamp> {
  /// The parameter `id` of this provider.
  String get id;
}

class _StreetLampProviderElement
    extends AutoDisposeFutureProviderElement<StreetLamp> with StreetLampRef {
  _StreetLampProviderElement(super.provider);

  @override
  String get id => (origin as StreetLampProvider).id;
}

String _$streetLampStoreHash() => r'3558f0a20854e49e449302dd3a2cfd79fe958a7e';

/// See also [StreetLampStore].
@ProviderFor(StreetLampStore)
final streetLampStoreProvider =
    AsyncNotifierProvider<StreetLampStore, Map<String, StreetLamp>>.internal(
  StreetLampStore.new,
  name: r'streetLampStoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$streetLampStoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StreetLampStore = AsyncNotifier<Map<String, StreetLamp>>;
String _$availableStreetsHash() => r'f61e9828e13d7355d3682be284e58ee53058ac5b';

abstract class _$AvailableStreets
    extends BuildlessAsyncNotifier<IList<Street>> {
  late final CityZone zone;

  FutureOr<IList<Street>> build({
    required CityZone zone,
  });
}

/// See also [AvailableStreets].
@ProviderFor(AvailableStreets)
const availableStreetsProvider = AvailableStreetsFamily();

/// See also [AvailableStreets].
class AvailableStreetsFamily extends Family<AsyncValue<IList<Street>>> {
  /// See also [AvailableStreets].
  const AvailableStreetsFamily();

  /// See also [AvailableStreets].
  AvailableStreetsProvider call({
    required CityZone zone,
  }) {
    return AvailableStreetsProvider(
      zone: zone,
    );
  }

  @override
  AvailableStreetsProvider getProviderOverride(
    covariant AvailableStreetsProvider provider,
  ) {
    return call(
      zone: provider.zone,
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
  String? get name => r'availableStreetsProvider';
}

/// See also [AvailableStreets].
class AvailableStreetsProvider
    extends AsyncNotifierProviderImpl<AvailableStreets, IList<Street>> {
  /// See also [AvailableStreets].
  AvailableStreetsProvider({
    required CityZone zone,
  }) : this._internal(
          () => AvailableStreets()..zone = zone,
          from: availableStreetsProvider,
          name: r'availableStreetsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$availableStreetsHash,
          dependencies: AvailableStreetsFamily._dependencies,
          allTransitiveDependencies:
              AvailableStreetsFamily._allTransitiveDependencies,
          zone: zone,
        );

  AvailableStreetsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.zone,
  }) : super.internal();

  final CityZone zone;

  @override
  FutureOr<IList<Street>> runNotifierBuild(
    covariant AvailableStreets notifier,
  ) {
    return notifier.build(
      zone: zone,
    );
  }

  @override
  Override overrideWith(AvailableStreets Function() create) {
    return ProviderOverride(
      origin: this,
      override: AvailableStreetsProvider._internal(
        () => create()..zone = zone,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        zone: zone,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<AvailableStreets, IList<Street>>
      createElement() {
    return _AvailableStreetsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvailableStreetsProvider && other.zone == zone;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, zone.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AvailableStreetsRef on AsyncNotifierProviderRef<IList<Street>> {
  /// The parameter `zone` of this provider.
  CityZone get zone;
}

class _AvailableStreetsProviderElement
    extends AsyncNotifierProviderElement<AvailableStreets, IList<Street>>
    with AvailableStreetsRef {
  _AvailableStreetsProviderElement(super.provider);

  @override
  CityZone get zone => (origin as AvailableStreetsProvider).zone;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
