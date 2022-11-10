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

String $SelectedZoneHash() => r'80fc7edfd163522528aa0da831ac4fbff13f3fac';

/// See also [SelectedZone].
final selectedZoneProvider = AsyncNotifierProvider<SelectedZone, CityZone>(
  SelectedZone.new,
  name: r'selectedZoneProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : $SelectedZoneHash,
);
typedef SelectedZoneRef = AsyncNotifierProviderRef<CityZone>;

abstract class _$SelectedZone extends AsyncNotifier<CityZone> {
  @override
  FutureOr<CityZone> build();
}

String $LampListHash() => r'a6b3e57d211cf3b67906f6157cc2ad6a1813e888';

/// See also [LampList].
final lampListProvider = AsyncNotifierProvider<LampList, IList<StreetLamp>>(
  LampList.new,
  name: r'lampListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : $LampListHash,
);
typedef LampListRef = AsyncNotifierProviderRef<IList<StreetLamp>>;

abstract class _$LampList extends AsyncNotifier<IList<StreetLamp>> {
  @override
  FutureOr<IList<StreetLamp>> build();
}
