import 'dart:async';

import 'package:falotier/domain/city_zones/city_zone.dart';
import 'package:falotier/domain/city_zones/providers.dart';
import 'package:falotier/domain/city_zones/street.dart';
import 'package:falotier/domain/street_lamps/interfaces.dart';
import 'package:falotier/infrastructure/logger_factory.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'street_lamp.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
class StreetLampStore extends _$StreetLampStore {
  static final _log = LoggerFactory.logger('StreetLampStore');

  StreetLampRemoteRepository get _repo =>
      ref.read(streetLampRemoteRepositoryProvider);

  @override
  Future<Map<String, StreetLamp>> build() async {
    _log.i('build()');

    final zone = await ref.watch(selectedZoneProvider.future);
    final lamps = await _repo.getList(zone);
    return {for (final l in lamps) l.id: l};
  }

  Future toggle(String id) async {
    _log.i('toggle( $id )');
    final previous = state.value!;
    final lamp = previous[id]!;
    final updated = lamp.copyWith(isLit: !lamp.isLit);

    await _repo.addOrUpdate(updated);
    state = AsyncData({...previous, id: updated});
  }

  Future addOrUpdate(StreetLamp lamp) async {
    _log.i('addOrUpdate( $lamp )');
    final saved = await _repo.addOrUpdate(lamp);
    state = AsyncData({...state.value!, saved.id: saved});
  }

  Future remove(String id) async {
    _log.i('remove( $id )');
    final lamp = state.value![id]!;
    await _repo.remove(lamp);
    state = AsyncData({...state.value!}..remove(id));
  }
}

@riverpod
Future<IList<StreetLamp>> zoneLamps(
  ZoneLampsRef ref, {
  required CityZone zone,
}) async {
  final store = await ref.watch(streetLampStoreProvider.future);
  return store.values
      .where((l) => l.street.zone == zone)
      .toIList()
      .sort(streetLampComparator);
}

@riverpod
Future<StreetLamp> streetLamp(
  StreetLampRef ref, {
  required String id,
}) async {
  final store = await ref.watch(streetLampStoreProvider.future);
  return store[id]!;
}

@Riverpod(keepAlive: true)
class AvailableStreets extends _$AvailableStreets {
  static final _log = LoggerFactory.logger('AvailableStreetsProvider');

  @override
  Future<IList<Street>> build({required CityZone zone}) async {
    _log.i('build()');

    final lampStore = await ref.watch(streetLampStoreProvider.future);
    final allStreets = await ref.watch(streetsProvider(zone: zone).future);

    final streetsWithLamp = lampStore.values
        .where((l) => l.street.zone == zone)
        .map((l) => l.street)
        .toSet();

    return allStreets
        .asSet()
        .difference(streetsWithLamp)
        .toIList()
        .sort(streetComparator);
  }

  reload() {
    _log.i('reload()');

    ref.invalidate(streetLampStoreProvider);
    ref.invalidate(streetsProvider(zone: zone));
  }
}
