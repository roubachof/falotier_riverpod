// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$zoneStreetLampsHash() => r'9a90efa366c661d6738ef575e466af39033bc6c0';

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

abstract class _$ZoneStreetLamps
    extends BuildlessAsyncNotifier<IList<StreetLamp>> {
  late final CityZone zone;

  FutureOr<IList<StreetLamp>> build({
    required CityZone zone,
  });
}

/// See also [ZoneStreetLamps].
@ProviderFor(ZoneStreetLamps)
const zoneStreetLampsProvider = ZoneStreetLampsFamily();

/// See also [ZoneStreetLamps].
class ZoneStreetLampsFamily extends Family<AsyncValue<IList<StreetLamp>>> {
  /// See also [ZoneStreetLamps].
  const ZoneStreetLampsFamily();

  /// See also [ZoneStreetLamps].
  ZoneStreetLampsProvider call({
    required CityZone zone,
  }) {
    return ZoneStreetLampsProvider(
      zone: zone,
    );
  }

  @override
  ZoneStreetLampsProvider getProviderOverride(
    covariant ZoneStreetLampsProvider provider,
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
  String? get name => r'zoneStreetLampsProvider';
}

/// See also [ZoneStreetLamps].
class ZoneStreetLampsProvider
    extends AsyncNotifierProviderImpl<ZoneStreetLamps, IList<StreetLamp>> {
  /// See also [ZoneStreetLamps].
  ZoneStreetLampsProvider({
    required CityZone zone,
  }) : this._internal(
          () => ZoneStreetLamps()..zone = zone,
          from: zoneStreetLampsProvider,
          name: r'zoneStreetLampsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$zoneStreetLampsHash,
          dependencies: ZoneStreetLampsFamily._dependencies,
          allTransitiveDependencies:
              ZoneStreetLampsFamily._allTransitiveDependencies,
          zone: zone,
        );

  ZoneStreetLampsProvider._internal(
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
  FutureOr<IList<StreetLamp>> runNotifierBuild(
    covariant ZoneStreetLamps notifier,
  ) {
    return notifier.build(
      zone: zone,
    );
  }

  @override
  Override overrideWith(ZoneStreetLamps Function() create) {
    return ProviderOverride(
      origin: this,
      override: ZoneStreetLampsProvider._internal(
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
  AsyncNotifierProviderElement<ZoneStreetLamps, IList<StreetLamp>>
      createElement() {
    return _ZoneStreetLampsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ZoneStreetLampsProvider && other.zone == zone;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, zone.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ZoneStreetLampsRef on AsyncNotifierProviderRef<IList<StreetLamp>> {
  /// The parameter `zone` of this provider.
  CityZone get zone;
}

class _ZoneStreetLampsProviderElement
    extends AsyncNotifierProviderElement<ZoneStreetLamps, IList<StreetLamp>>
    with ZoneStreetLampsRef {
  _ZoneStreetLampsProviderElement(super.provider);

  @override
  CityZone get zone => (origin as ZoneStreetLampsProvider).zone;
}

String _$streetLampStateHash() => r'e7df0d733272827f99280b81ac9fcd000a38f183';

abstract class _$StreetLampState extends BuildlessAsyncNotifier<StreetLamp> {
  late final String id;

  FutureOr<StreetLamp> build({
    required String id,
  });
}

/// See also [StreetLampState].
@ProviderFor(StreetLampState)
const streetLampStateProvider = StreetLampStateFamily();

/// See also [StreetLampState].
class StreetLampStateFamily extends Family<AsyncValue<StreetLamp>> {
  /// See also [StreetLampState].
  const StreetLampStateFamily();

  /// See also [StreetLampState].
  StreetLampStateProvider call({
    required String id,
  }) {
    return StreetLampStateProvider(
      id: id,
    );
  }

  @override
  StreetLampStateProvider getProviderOverride(
    covariant StreetLampStateProvider provider,
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
  String? get name => r'streetLampStateProvider';
}

/// See also [StreetLampState].
class StreetLampStateProvider
    extends AsyncNotifierProviderImpl<StreetLampState, StreetLamp> {
  /// See also [StreetLampState].
  StreetLampStateProvider({
    required String id,
  }) : this._internal(
          () => StreetLampState()..id = id,
          from: streetLampStateProvider,
          name: r'streetLampStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$streetLampStateHash,
          dependencies: StreetLampStateFamily._dependencies,
          allTransitiveDependencies:
              StreetLampStateFamily._allTransitiveDependencies,
          id: id,
        );

  StreetLampStateProvider._internal(
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
  FutureOr<StreetLamp> runNotifierBuild(
    covariant StreetLampState notifier,
  ) {
    return notifier.build(
      id: id,
    );
  }

  @override
  Override overrideWith(StreetLampState Function() create) {
    return ProviderOverride(
      origin: this,
      override: StreetLampStateProvider._internal(
        () => create()..id = id,
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
  AsyncNotifierProviderElement<StreetLampState, StreetLamp> createElement() {
    return _StreetLampStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StreetLampStateProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin StreetLampStateRef on AsyncNotifierProviderRef<StreetLamp> {
  /// The parameter `id` of this provider.
  String get id;
}

class _StreetLampStateProviderElement
    extends AsyncNotifierProviderElement<StreetLampState, StreetLamp>
    with StreetLampStateRef {
  _StreetLampStateProviderElement(super.provider);

  @override
  String get id => (origin as StreetLampStateProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
