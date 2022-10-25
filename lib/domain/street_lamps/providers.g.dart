// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// ignore_for_file: avoid_private_typedef_functions, non_constant_identifier_names, subtype_of_sealed_class, invalid_use_of_internal_member, unused_element, constant_identifier_names, unnecessary_raw_strings, library_private_types_in_public_api

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

String $ZoneStreetLampsHash() => r'6f9e41f41b2889d5c91e32522724431fd95762e3';

/// See also [ZoneStreetLamps].
class ZoneStreetLampsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ZoneStreetLamps, IList<StreetLamp>> {
  ZoneStreetLampsProvider({
    required this.zone,
  }) : super(
          () => ZoneStreetLamps()..zone = zone,
          from: zoneStreetLampsProvider,
          name: r'zoneStreetLampsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : $ZoneStreetLampsHash,
        );

  final CityZone zone;

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

  @override
  FutureOr<IList<StreetLamp>> runNotifierBuild(
    covariant _$ZoneStreetLamps notifier,
  ) {
    return notifier.build(
      zone: zone,
    );
  }
}

typedef ZoneStreetLampsRef
    = AutoDisposeAsyncNotifierProviderRef<IList<StreetLamp>>;

/// See also [ZoneStreetLamps].
final zoneStreetLampsProvider = ZoneStreetLampsFamily();

class ZoneStreetLampsFamily extends Family<AsyncValue<IList<StreetLamp>>> {
  ZoneStreetLampsFamily();

  ZoneStreetLampsProvider call({
    required CityZone zone,
  }) {
    return ZoneStreetLampsProvider(
      zone: zone,
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderImpl<ZoneStreetLamps, IList<StreetLamp>>
      getProviderOverride(
    covariant ZoneStreetLampsProvider provider,
  ) {
    return call(
      zone: provider.zone,
    );
  }

  @override
  List<ProviderOrFamily>? get allTransitiveDependencies => null;

  @override
  List<ProviderOrFamily>? get dependencies => null;

  @override
  String? get name => r'zoneStreetLampsProvider';
}

abstract class _$ZoneStreetLamps
    extends BuildlessAutoDisposeAsyncNotifier<IList<StreetLamp>> {
  late final CityZone zone;

  FutureOr<IList<StreetLamp>> build({
    required CityZone zone,
  });
}

String $StreetLampStateHash() => r'6314cd590e50885d22fa1d1ce8785ab566f9f862';

/// See also [StreetLampState].
class StreetLampStateProvider
    extends AutoDisposeAsyncNotifierProviderImpl<StreetLampState, StreetLamp> {
  StreetLampStateProvider({
    required this.id,
  }) : super(
          () => StreetLampState()..id = id,
          from: streetLampStateProvider,
          name: r'streetLampStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : $StreetLampStateHash,
        );

  final String id;

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

  @override
  FutureOr<StreetLamp> runNotifierBuild(
    covariant _$StreetLampState notifier,
  ) {
    return notifier.build(
      id: id,
    );
  }
}

typedef StreetLampStateRef = AutoDisposeAsyncNotifierProviderRef<StreetLamp>;

/// See also [StreetLampState].
final streetLampStateProvider = StreetLampStateFamily();

class StreetLampStateFamily extends Family<AsyncValue<StreetLamp>> {
  StreetLampStateFamily();

  StreetLampStateProvider call({
    required String id,
  }) {
    return StreetLampStateProvider(
      id: id,
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderImpl<StreetLampState, StreetLamp>
      getProviderOverride(
    covariant StreetLampStateProvider provider,
  ) {
    return call(
      id: provider.id,
    );
  }

  @override
  List<ProviderOrFamily>? get allTransitiveDependencies => null;

  @override
  List<ProviderOrFamily>? get dependencies => null;

  @override
  String? get name => r'streetLampStateProvider';
}

abstract class _$StreetLampState
    extends BuildlessAutoDisposeAsyncNotifier<StreetLamp> {
  late final String id;

  FutureOr<StreetLamp> build({
    required String id,
  });
}
