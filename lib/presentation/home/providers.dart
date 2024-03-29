import 'package:falotier/domain/city_zones/city_zone.dart';
import 'package:falotier/domain/city_zones/providers.dart';
import 'package:falotier/domain/domain_initializer.dart';
import 'package:falotier/domain/street_lamps/providers.dart';
import 'package:falotier/domain/street_lamps/street_lamp.dart';
import 'package:falotier/infrastructure/logger_factory.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
class SelectedZone extends _$SelectedZone {
  static final _log = LoggerFactory.logger('SelectedZoneProvider');

  @override
  Future<CityZone> build() async {
    _log.i(
        'build( isRefreshing: ${state.isRefreshing}, isReloading: ${state.isReloading}, hasValue: ${state.hasValue} )');

    // Domain need to be initialized
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

@Riverpod(keepAlive: true)
class LampList extends _$LampList {
  static final _log = LoggerFactory.logger('LampListProvider');

  CityZone? selectedZone;

  @override
  Future<IList<StreetLamp>> build() async {
    _log.i(
        'build( isRefreshing: ${state.isRefreshing}, isReloading: ${state.isReloading}, hasValue: ${state.hasValue} )');

    selectedZone = await ref.watch(selectedZoneProvider.future);
    final list =
        await ref.watch(zoneStreetLampsProvider(zone: selectedZone!).future);

    _log.listCount(list);
    return list;
  }

  Future<void> refresh() {
    _log.i('refresh()');
    return ref.refresh(zoneStreetLampsProvider(zone: selectedZone!).future);
  }

  void reload() {
    _log.i('reload()');
    if (selectedZone != null) {
      ref.invalidate(zoneStreetLampsProvider(zone: selectedZone!));
    }

    ref.invalidateSelf();
  }

  Future addOrUpdate(StreetLamp streetLamp) async {
    _log.i('addOrUpdate( $streetLamp )');
    return ref
        .read(zoneStreetLampsProvider(zone: selectedZone!).notifier)
        .addOrUpdate(streetLamp);
  }

  Future remove(StreetLamp streetLamp) async {
    _log.i('remove( $streetLamp )');
    return ref
        .read(zoneStreetLampsProvider(zone: selectedZone!).notifier)
        .remove(streetLamp);
  }
}
