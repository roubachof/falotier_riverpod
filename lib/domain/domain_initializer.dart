import 'package:falotier/domain/city_zones/impl/remote_repository_mock.dart';
import 'package:falotier/domain/city_zones/providers.dart';
import 'package:falotier/domain/street_lamps/impl/remote_repository_mock.dart';
import 'package:falotier/infrastructure/logger_factory.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'domain_initializer.g.dart';

@Riverpod(keepAlive: true)
class DomainInitializer extends _$DomainInitializer {
  static final _log = LoggerFactory.logger('DomainInitializerProvider');

  @override
  Future<bool> build() async {
    _log.i('build()');

    final mockStreetLampsRepository =
        ref.watch(streetLampRemoteRepositoryMockProvider);
    final mockCityRepository = ref.watch(cityZoneRemoteRepositoryMockProvider);

    mockCityRepository.initializeMock();
    await mockStreetLampsRepository.initializeMock();

    // caching the available zones
    await ref.watch(availableZonesProvider.future);
    return true;
  }

  reload() {
    _log.i('reload()');

    ref.invalidate(availableZonesProvider);
    ref.invalidateSelf();
  }
}
