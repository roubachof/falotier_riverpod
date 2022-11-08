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

String $LampDetailsHash() => r'fdaa98e6e0ebd05a0885b26958c26f9a7af1a686';

/// See also [LampDetails].
class LampDetailsProvider
    extends AutoDisposeAsyncNotifierProviderImpl<LampDetails, StreetLamp> {
  LampDetailsProvider({
    required this.lampId,
  }) : super(
          () => LampDetails()..lampId = lampId,
          from: lampDetailsProvider,
          name: r'lampDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : $LampDetailsHash,
        );

  final String lampId;

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

  @override
  FutureOr<StreetLamp> runNotifierBuild(
    covariant _$LampDetails notifier,
  ) {
    return notifier.build(
      lampId: lampId,
    );
  }
}

typedef LampDetailsRef = AutoDisposeAsyncNotifierProviderRef<StreetLamp>;

/// See also [LampDetails].
final lampDetailsProvider = LampDetailsFamily();

class LampDetailsFamily extends Family<AsyncValue<StreetLamp>> {
  LampDetailsFamily();

  LampDetailsProvider call({
    required String lampId,
  }) {
    return LampDetailsProvider(
      lampId: lampId,
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderImpl<LampDetails, StreetLamp>
      getProviderOverride(
    covariant LampDetailsProvider provider,
  ) {
    return call(
      lampId: provider.lampId,
    );
  }

  @override
  List<ProviderOrFamily>? get allTransitiveDependencies => null;

  @override
  List<ProviderOrFamily>? get dependencies => null;

  @override
  String? get name => r'lampDetailsProvider';
}

abstract class _$LampDetails
    extends BuildlessAutoDisposeAsyncNotifier<StreetLamp> {
  late final String lampId;

  FutureOr<StreetLamp> build({
    required String lampId,
  });
}
