import 'package:falotier/domain/city_zones/city_zone.dart';
import 'package:falotier/domain/city_zones/interfaces.dart';
import 'package:falotier/domain/city_zones/street.dart';
import 'package:falotier/domain/domain_initializer.dart';
import 'package:falotier/infrastructure/logger_factory.dart';
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
class SelectedZone extends _$SelectedZone {
  static final _log = LoggerFactory.logger('SelectedZoneProvider');

  @override
  Future<CityZone> build() async {
    _log.i(
        'build( isRefreshing: ${state.isRefreshing}, isReloading: ${state.isReloading}, hasValue: ${state.hasValue} )');

    await ref.watch(domainInitializerProvider.future);

    final zones = await ref.watch(availableZonesProvider.future);
    _log.listCount(zones);
    return zones[0];
  }

  @override
  bool updateShouldNotify(
    AsyncValue<CityZone> previous,
    AsyncValue<CityZone> next,
  ) {
    if (previous.hasValue && next.hasValue) {
      bool shouldUpdate = previous.value!.id != next.value!.id;
      _log.i('shouldUpdate: $shouldUpdate');
      return shouldUpdate;
    }

    return super.updateShouldNotify(previous, next);
  }

  void reload() {
    _log.i('reload()');

    ref.invalidate(availableZonesProvider);
  }

  select(CityZone zone) {
    _log.i('select( $zone )');
    update((previousZone) => zone);
  }
}
