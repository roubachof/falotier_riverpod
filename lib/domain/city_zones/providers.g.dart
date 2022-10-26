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

String $availableZonesHash() => r'5215770bfa2eaa29b2cfcc5eaeb15ef220fc6358';

/// See also [availableZones].
final availableZonesProvider = AutoDisposeFutureProvider<IList<CityZone>>(
  availableZones,
  name: r'availableZonesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : $availableZonesHash,
);
typedef AvailableZonesRef = AutoDisposeFutureProviderRef<IList<CityZone>>;
String $streetsHash() => r'bf6667eb0a6c8b0185cde7f061ddc771a8ab9f3e';

/// See also [streets].
class StreetsProvider extends AutoDisposeFutureProvider<IList<Street>> {
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

typedef StreetsRef = AutoDisposeFutureProviderRef<IList<Street>>;

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
  AutoDisposeFutureProvider<IList<Street>> getProviderOverride(
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
