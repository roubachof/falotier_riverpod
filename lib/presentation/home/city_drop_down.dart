import 'package:falotier/domain/city_zones/city_zone.dart';
import 'package:falotier/domain/city_zones/providers.dart';
import 'package:falotier_design/falotier_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

class CityDropDown extends ConsumerWidget {
  const CityDropDown({super.key});

  @override
  Widget build(context, ref) {
    final theme = AppTheme.of(context);

    final zonesAsyncValue = ref.watch(availableZonesProvider);
    final selectedZone = ref.read(selectedZoneProvider);
    final selectedZoneNotifier = ref.read(selectedZoneProvider.notifier);

    return selectedZone.when(
      data: (data) {
        final zones = zonesAsyncValue.value!;
        return DropdownButton<CityZone>(
          value: data,
          items: zones.map<DropdownMenuItem<CityZone>>((zone) {
            return DropdownMenuItem<CityZone>(
              value: zone,
              child: AppText.paragraphLarge(zone.name),
            );
          }).toList(),
          onChanged: (zone) => selectedZoneNotifier.select(zone!),
        );
      },
      error: (_, __) {
        return const AppText.paragraphLarge('ERROR');
      },
      loading: () {
        return TweenAnimationBuilder<int>(
          duration: const Duration(seconds: 200),
          tween: IntTween(begin: 0, end: 200 * 1000),
          builder: (BuildContext context, value, Widget? child) {
            // Funny little easy animation
            String dots = '';

            final loadingDurationMilliseconds = value % 1000;
            if (loadingDurationMilliseconds > 750) {
              dots = '...';
            } else if (loadingDurationMilliseconds > 500) {
              dots = '..';
            } else if (loadingDurationMilliseconds > 250) {
              dots = '.';
            }

            return AppText.paragraphLarge('Loading$dots');
          },
        );
      },
    );
  }
}
