import 'package:falotier/domain/city_zones/providers.dart';
import 'package:falotier/domain/street_lamps/providers.dart';
import 'package:falotier/domain/street_lamps/street_lamp.dart';
import 'package:falotier/infrastructure/logger_factory.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
class LampList extends _$LampList {
  static final _log = LoggerFactory.logger('LampListProvider');

  @override
  Future<IList<StreetLamp>> build() async {
    _log.i('build()');

    final zone = await ref.watch(selectedZoneProvider.future);
    return ref.watch(zoneLampsProvider(zone: zone).future);
  }

  Future<void> refresh() {
    _log.i('refresh()');
    return ref.refresh(streetLampStoreProvider.future);
  }

  void reload() {
    _log.i('reload()');
    ref.invalidate(streetLampStoreProvider);
    ref.invalidateSelf();
  }
}
