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

String $availableZonesHash() => r'f668f26e203866029cc5e5e84a9f8631c4b1fb2c';

/// See also [availableZones].
final availableZonesProvider = FutureProvider<IList<CityZone>>(
  availableZones,
  name: r'availableZonesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : $availableZonesHash,
);
typedef AvailableZonesRef = FutureProviderRef<IList<CityZone>>;
String $streetsHash() => r'7c0ba00f9ce79466720c4af5be70fa9925219895';

/// See also [streets].
class StreetsProvider extends FutureProvider<IList<Street>> {
  StreetsProvider({
    required this.zone,
  }) : super(
          (ref) => streets(
            ref,
            zone: zone,
          ),
          from: streetsProvider,
          name: r'streetsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : $streetsHash,
        );

  final CityZone zone;

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

typedef StreetsRef = FutureProviderRef<IList<Street>>;

/// See also [streets].
final streetsProvider = StreetsFamily();

class StreetsFamily extends Family<AsyncValue<IList<Street>>> {
  StreetsFamily();

  StreetsProvider call({
    required CityZone zone,
  }) {
    return StreetsProvider(
      zone: zone,
    );
  }

  @override
  FutureProvider<IList<Street>> getProviderOverride(
    covariant StreetsProvider provider,
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
  String? get name => r'streetsProvider';
}

String $availableStreetsHash() => r'0c7b3d57331cc6015dc5da3f300b5332895556cc';

/// See also [availableStreets].
class AvailableStreetsProvider extends FutureProvider<IList<Street>> {
  AvailableStreetsProvider({
    required this.zone,
  }) : super(
          (ref) => availableStreets(
            ref,
            zone: zone,
          ),
          from: availableStreetsProvider,
          name: r'availableStreetsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : $availableStreetsHash,
        );

  final CityZone zone;

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

typedef AvailableStreetsRef = FutureProviderRef<IList<Street>>;

/// See also [availableStreets].
final availableStreetsProvider = AvailableStreetsFamily();

class AvailableStreetsFamily extends Family<AsyncValue<IList<Street>>> {
  AvailableStreetsFamily();

  AvailableStreetsProvider call({
    required CityZone zone,
  }) {
    return AvailableStreetsProvider(
      zone: zone,
    );
  }

  @override
  FutureProvider<IList<Street>> getProviderOverride(
    covariant AvailableStreetsProvider provider,
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
  String? get name => r'availableStreetsProvider';
}
