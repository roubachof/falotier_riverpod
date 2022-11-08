import 'dart:async';

import 'package:falotier/domain/street_lamps/providers.dart';
import 'package:falotier/domain/street_lamps/street_lamp.dart';
import 'package:falotier/infrastructure/logger_factory.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
class LampDetails extends _$LampDetails {
  static final _log = LoggerFactory.logger('LampDetailsProvider');

  @override
  Future<StreetLamp> build({required String lampId}) {
    _log.i('build()');

    return ref.watch(streetLampStateProvider(id: lampId).future);
  }

  Future toggle() async {
    _log.i('toggle()');

    bool isLit = false;
    await update((previous) {
      final next = previous.copyWith(isLit: !previous.isLit);
      isLit = next.isLit;
      return next;
    });

    final domainNotifier =
        ref.read(streetLampStateProvider(id: lampId).notifier);
    await domainNotifier.updateLight(isLit);
  }
}
