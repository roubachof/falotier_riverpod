import 'package:falotier/domain/city_zones/city_zone.dart';
import 'package:falotier/domain/city_zones/interfaces.dart';
import 'package:falotier/domain/city_zones/street.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
Future<IList<CityZone>> availableZones(AvailableZonesRef ref) {
  final repository = ref.read(cityZoneRemoteRepositoryProvider);
  return repository.getAvailableZones();
}

@riverpod
Future<IList<Street>> streets(StreetsRef ref, {required CityZone zone}) {
  final repository = ref.read(cityZoneRemoteRepositoryProvider);
  return repository.getZoneStreets(zone);
}
