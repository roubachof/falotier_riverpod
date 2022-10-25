import 'package:falotier/domain/city_zones/interfaces.dart';
import 'package:falotier/infrastructure/logger_factory.dart';
import 'package:falotier/infrastructure/remote_call_emulator.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../city_zone.dart';
import '../street.dart';

final cityZoneRemoteRepositoryMockProvider =
    Provider((ref) => CityZoneRemoteRepositoryMock());

class CityZoneRemoteRepositoryMock implements CityZoneRemoteRepository {
  static final _log = LoggerFactory.logger('CityZoneRepository');
  static const defaultZone = CityZone('1', 'Batignolles');

  static int _nextId = 1001;

  final _emulator = RemoteCallEmulator();

  final IList<CityZone> _zones = IList<CityZone>(const [defaultZone]);

  late final Map<CityZone, IList<Street>> _streetByZone = _createStreets();

  @override
  Future<IList<CityZone>> getAvailableZones() async {
    _log.i('getAvailableZones');
    await _emulator.makeRemoteCall();
    _log.listCount(_zones);
    return _zones;
  }

  @override
  Future<IList<Street>> getZoneStreets(CityZone zone) async {
    _log.i('getZoneStreets( $zone )');
    await _emulator.makeRemoteCall();
    final streets = _streetByZone[zone]!;
    _log.listCount(streets);
    return streets;
  }

  Map<CityZone, IList<Street>> _createStreets() {
    return {
      defaultZone: IList<Street>([
        _createStreet('Rue Nollet'),
        _createStreet('Rue des Batignolles'),
        _createStreet('Rue Legendre'),
        _createStreet('Rue Cardinet'),
        _createStreet('Rue des Moines'),
        _createStreet('Rue Brochant'),
        _createStreet('Rue des Dames'),
        _createStreet('Rue Boursault'),
        _createStreet('Rue Lemercier'),
        _createStreet('Rue Boursault'),
      ])
    };
  }

  Street _createStreet(
    String name, {
    CityZone cityZone = CityZoneRemoteRepositoryMock.defaultZone,
  }) {
    return Street('${_nextId++}', name, cityZone);
  }
}
