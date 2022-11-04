import 'package:falotier/domain/city_zones/city_zone.dart';
import 'package:falotier/domain/city_zones/interfaces.dart';
import 'package:falotier/domain/city_zones/street.dart';
import 'package:falotier/domain/street_lamps/providers.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
Future<IList<CityZone>> availableZones(AvailableZonesRef ref) {
  final repository = ref.watch(cityZoneRemoteRepositoryProvider);
  return repository.getAvailableZones();
}

@Riverpod(keepAlive: true)
Future<IList<Street>> streets(StreetsRef ref, {required CityZone zone}) {
  final repository = ref.watch(cityZoneRemoteRepositoryProvider);
  return repository.getZoneStreets(zone);
}

@Riverpod(keepAlive: true)
Future<IList<Street>> availableStreets(
  AvailableStreetsRef ref, {
  required CityZone zone,
}) async {
  final streetsWithLamp =
      await ref.watch(zoneStreetLampsProvider(zone: zone).future);
  final allStreets = await ref.watch(streetsProvider(zone: zone).future);

  return allStreets
      .asSet()
      .difference(streetsWithLamp.map((l) => l.street).asSet())
      .toIList()
      .sort(streetComparator);
}
