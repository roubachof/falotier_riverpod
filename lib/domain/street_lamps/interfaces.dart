import 'dart:core';

import 'package:falotier/domain/city_zones/city_zone.dart';
import 'package:falotier/domain/city_zones/impl/remote_repository_mock.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'impl/remote_repository_mock.dart';
import 'street_lamp.dart';

final streetLampRemoteRepositoryProvider = Provider((ref) =>
    StreetLampRemoteRepositoryMock(
        ref.read(cityZoneRemoteRepositoryMockProvider)));

abstract class StreetLampRemoteRepository {
  Future<StreetLamp> get(String id);
  Future<IList<StreetLamp>> getList(CityZone zone);
  Future<StreetLamp> addOrUpdate(StreetLamp streetLamp);
  Future remove(StreetLamp streetLamp);
}
