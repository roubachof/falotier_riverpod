import 'dart:core';

import 'package:falotier/domain/city_zones/city_zone.dart';

import 'street_lamp.dart';

abstract class StreetLampLocalRepository {
  Future<StreetLamp> get(int id);
  Future<List<StreetLamp>> getList(CityZone zone);
  Future addOrUpdate(StreetLamp streetLamp);
  Future remove(StreetLamp streetLamp);
}

abstract class StreetLampRemoteRepository {
  Future<StreetLamp> get(int id);
  Future<List<StreetLamp>> getList(CityZone zone);
  Future addOrUpdate(StreetLamp streetLamp);
  Future remove(StreetLamp streetLamp);
}
