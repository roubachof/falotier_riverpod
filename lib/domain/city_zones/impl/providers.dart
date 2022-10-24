import 'package:falotier/domain/city_zones/impl/remote_repository_mock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cityZoneRemoteRepositoryMockProvider =
    Provider((ref) => CityZoneRemoteRepositoryMock());
