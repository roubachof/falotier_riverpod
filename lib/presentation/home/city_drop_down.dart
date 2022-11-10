import 'package:falotier/domain/city_zones/city_zone.dart';
import 'package:falotier/domain/city_zones/providers.dart';
import 'package:falotier/domain/domain_initializer.dart';
import 'package:falotier_design/falotier_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

class CityDropDown extends ConsumerWidget {
  const CityDropDown({super.key});

  @override
  Widget build(context, ref) {
    final domainInitializerAsyncValue = ref.watch(domainInitializerProvider);
    return domainInitializerAsyncValue.when(
      error: (_, __) => const AppText.subtitleMedium('INIT ERROR'),
      loading: () => const AppLoadingText(),
      data: (_) {
        final zonesAsyncValue = ref.watch(availableZonesProvider);
        final selectedZone = ref.watch(selectedZoneProvider);
        final selectedZoneNotifier = ref.watch(selectedZoneProvider.notifier);

        return selectedZone.when(
          error: (_, __) => const AppText.subtitleMedium('ERROR'),
          loading: () => const AppLoadingText(),
          data: (data) {
            final zones = zonesAsyncValue.value!;
            return DropdownButton<CityZone>(
              value: data,
              items: zones.map<DropdownMenuItem<CityZone>>((zone) {
                return DropdownMenuItem<CityZone>(
                  value: zone,
                  child: AppText.subtitleMedium(zone.name),
                );
              }).toList(),
              onChanged: (zone) => selectedZoneNotifier.select(zone!),
            );
          },
        );
      },
    );
  }
}
