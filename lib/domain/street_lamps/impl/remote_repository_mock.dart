import 'package:falotier/domain/city_zones/city_zone.dart';
import 'package:falotier/domain/city_zones/impl/remote_repository_mock.dart';
import 'package:falotier/domain/city_zones/street.dart';
import 'package:falotier/infrastructure/exceptions.dart';
import 'package:falotier/infrastructure/logger_factory.dart';
import 'package:falotier/infrastructure/remote_call_emulator.dart';

import '../interfaces.dart';
import '../street_lamp.dart';

class StreetLampRemoteRepositoryMock implements StreetLampRemoteRepository {
  static final _log = LoggerFactory.logger('StreetLampRemoteRepositoryMock');

  static int _nextId = 2001;

  final CityZoneRemoteRepositoryMock _cityZoneRemoteRepositoryMock;
  final RemoteCallEmulator _emulator = RemoteCallEmulator();

  Map<CityZone, Map<String, StreetLamp>>? _zoneLamps;

  StreetLampRemoteRepositoryMock(this._cityZoneRemoteRepositoryMock);

  @override
  Future addOrUpdate(StreetLamp streetLamp) async {
    _log.i('addOrUpdate( $streetLamp )');

    await _emulator.makeRemoteCall();
    await _createLampsIfNeeded();

    _zoneLamps![streetLamp.street.zone]![streetLamp.id] = streetLamp;
  }

  @override
  Future<StreetLamp> get(int id) async {
    _log.i('get( $id )');

    await _emulator.makeRemoteCall();
    await _createLampsIfNeeded();

    for (var streets in _zoneLamps!.values) {
      if (streets.containsKey(id)) {
        return streets[id]!;
      }
    }

    throw ItemNotFoundException(id.toString());
  }

  @override
  Future<List<StreetLamp>> getList(CityZone zone) async {
    _log.i('getList( $zone )');

    await _emulator.makeRemoteCall();
    await _createLampsIfNeeded();

    return _zoneLamps![zone]!.values.toList();
  }

  @override
  Future remove(StreetLamp streetLamp) async {
    _log.i('remove( $streetLamp )');

    await _emulator.makeRemoteCall();
    await _createLampsIfNeeded();

    _zoneLamps![streetLamp.street.zone]!.remove(streetLamp.id);
  }

  Future _createLampsIfNeeded() async {
    if (_zoneLamps != null) {
      return;
    }

    final zoneLamps = Map<CityZone, Map<String, StreetLamp>>.identity();
    for (final zone
        in await _cityZoneRemoteRepositoryMock.getAvailableZones()) {
      final streets = await _cityZoneRemoteRepositoryMock.getZoneStreets(zone);
      zoneLamps[zone] = Map<String, StreetLamp>.fromEntries(streets.map((s) {
        final streetLamp =
            _create(s, isLit: DateTime.now().millisecond % 2 == 0);
        return MapEntry(streetLamp.id, streetLamp);
      }));
    }

    _zoneLamps = zoneLamps;
  }

  StreetLamp _create(
    Street street, {
    bool isLit = false,
  }) {
    return StreetLamp(id: '${_nextId++}', street: street, isLit: isLit);
  }
}
