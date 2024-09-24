// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availableZonesHash() => r'f668f26e203866029cc5e5e84a9f8631c4b1fb2c';

/// See also [availableZones].
@ProviderFor(availableZones)
final availableZonesProvider = FutureProvider<IList<CityZone>>.internal(
  availableZones,
  name: r'availableZonesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availableZonesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AvailableZonesRef = FutureProviderRef<IList<CityZone>>;
String _$streetsHash() => r'7c0ba00f9ce79466720c4af5be70fa9925219895';

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

/// See also [streets].
@ProviderFor(streets)
const streetsProvider = StreetsFamily();

/// See also [streets].
class StreetsFamily extends Family<AsyncValue<IList<Street>>> {
  /// See also [streets].
  const StreetsFamily();

  /// See also [streets].
  StreetsProvider call({
    required CityZone zone,
  }) {
    return StreetsProvider(
      zone: zone,
    );
  }

  @override
  StreetsProvider getProviderOverride(
    covariant StreetsProvider provider,
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
  String? get name => r'streetsProvider';
}

/// See also [streets].
class StreetsProvider extends FutureProvider<IList<Street>> {
  /// See also [streets].
  StreetsProvider({
    required CityZone zone,
  }) : this._internal(
          (ref) => streets(
            ref as StreetsRef,
            zone: zone,
          ),
          from: streetsProvider,
          name: r'streetsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$streetsHash,
          dependencies: StreetsFamily._dependencies,
          allTransitiveDependencies: StreetsFamily._allTransitiveDependencies,
          zone: zone,
        );

  StreetsProvider._internal(
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
    FutureOr<IList<Street>> Function(StreetsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StreetsProvider._internal(
        (ref) => create(ref as StreetsRef),
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
  FutureProviderElement<IList<Street>> createElement() {
    return _StreetsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StreetsProvider && other.zone == zone;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, zone.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StreetsRef on FutureProviderRef<IList<Street>> {
  /// The parameter `zone` of this provider.
  CityZone get zone;
}

class _StreetsProviderElement extends FutureProviderElement<IList<Street>>
    with StreetsRef {
  _StreetsProviderElement(super.provider);

  @override
  CityZone get zone => (origin as StreetsProvider).zone;
}

String _$availableStreetsHash() => r'c1e01fb7012f09718af917461020f7ad2bea8574';

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
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
