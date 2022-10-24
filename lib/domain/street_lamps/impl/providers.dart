import 'package:falotier/domain/city_zones/impl/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'remote_repository_mock.dart';

final streetLampRemoteRepositoryProvider = Provider((ref) =>
    StreetLampRemoteRepositoryMock(
        ref.read(cityZoneRemoteRepositoryMockProvider)));
