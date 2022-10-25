import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'city_zone.dart';
import 'impl/remote_repository_mock.dart';
import 'street.dart';

final cityZoneRemoteRepositoryProvider = Provider<CityZoneRemoteRepository>(
    (ref) => ref.watch(cityZoneRemoteRepositoryMockProvider));

abstract class CityZoneRemoteRepository {
  Future<IList<CityZone>> getAvailableZones();
  Future<IList<Street>> getZoneStreets(CityZone zone);
}
