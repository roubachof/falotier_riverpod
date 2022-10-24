import 'city_zone.dart';
import 'street.dart';

abstract class CityZoneRemoteRepository {
  Future<List<CityZone>> getAvailableZones();
  Future<List<Street>> getZoneStreets(CityZone zone);
}
