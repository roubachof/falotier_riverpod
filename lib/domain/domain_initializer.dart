import 'package:falotier/domain/city_zones/impl/remote_repository_mock.dart';
import 'package:falotier/domain/city_zones/providers.dart';
import 'package:falotier/domain/street_lamps/impl/remote_repository_mock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'domain_initializer.g.dart';

// create a provider
@Riverpod(keepAlive: true)
Future<bool> domainInitializer(DomainInitializerRef ref) async {
  final mockStreetLampsRepository =
      ref.watch(streetLampRemoteRepositoryMockProvider);
  final mockCityRepository = ref.watch(cityZoneRemoteRepositoryMockProvider);

  mockCityRepository.initializeMock();
  await mockStreetLampsRepository.initializeMock();

  // caching the available zones
  await ref.watch(availableZonesProvider.future);
  return true;
}
