import 'dart:async';

import 'package:falotier/domain/city_zones/city_zone.dart';
import 'package:falotier/domain/street_lamps/interfaces.dart';
import 'package:falotier/infrastructure/logger_factory.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'street_lamp.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
class ZoneStreetLamps extends _$ZoneStreetLamps {
  static final _log = LoggerFactory.logger('ZoneStreetLampsProvider');

  late StreetLampRemoteRepository _repository;

  @override
  Future<IList<StreetLamp>> build({required CityZone zone}) async {
    _log.i(
        'build( isRefreshing: ${state.isRefreshing}, isReloading: ${state.isReloading}, hasValue: ${state.hasValue} )');

    _repository = ref.read(streetLampRemoteRepositoryProvider);
    final lamps = await _repository.getList(zone);
    return lamps.sort(streetLampComparator);
  }

  Future addOrUpdate(StreetLamp streetLamp) async {
    _log.i('addOrUpdate( $streetLamp )');

    final updatedLamp = await _repository.addOrUpdate(streetLamp);

    await update((currentList) {
      final updatedList =
          currentList.updateById([updatedLamp], (item) => item.id);
      return currentList.length != updatedList.length
          ? updatedList.sort(streetLampComparator)
          : updatedList;
    });
  }

  Future remove(StreetLamp streetLamp) async {
    _log.i('remove( $streetLamp )');
    await _repository.remove(streetLamp);

    await update((currentList) {
      return currentList.removeWhere((element) => element.id == streetLamp.id);
    });
  }
}

@Riverpod(keepAlive: true)
class StreetLampState extends _$StreetLampState {
  static final _log = LoggerFactory.logger('StreetLampStateProvider');

  @override
  Future<StreetLamp> build({required String id}) {
    _log.i('build( $id )');
    return ref.read(streetLampRemoteRepositoryProvider).get(id);
  }

  Future updateLight(bool isLit) async {
    _log.i('updateLight( $id, isLit: $isLit )');

    if (!state.hasValue || state.value!.isLit == isLit) {
      return;
    }

    final streetLamp = state.value!;
    final updatedStreetLamp = streetLamp.copyWith(isLit: isLit);
    final zoneStreetLamps = ref
        .watch(zoneStreetLampsProvider(zone: streetLamp.street.zone).notifier);

    await zoneStreetLamps.addOrUpdate(updatedStreetLamp);
    state = AsyncData(updatedStreetLamp);
  }
}
