import 'package:falotier/domain/city_zones/providers.dart';
import 'package:falotier/domain/city_zones/street.dart';
import 'package:falotier/domain/street_lamps/street_lamp.dart';
import 'package:falotier/presentation/common/loading_states_widgets.dart';
import 'package:falotier/presentation/home/providers.dart';
import 'package:falotier_design/falotier_design.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loader_overlay/loader_overlay.dart';

class StreetList extends ConsumerWidget {
  const StreetList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);
    final selectedZone = ref.watch(selectedZoneProvider);
    final streetListAsyncValue =
        ref.watch(availableStreetsProvider(zone: selectedZone.value!));

    return LoaderOverlay(
      overlayColor: Colors.black.withOpacity(0.8),
      overlayWidgetBuilder: (_) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLoadingWidget(),
            AppGap.regular(),
            AppText.paragraphMedium('Street is being added'),
          ],
        ),
      ),
      child: AsyncValueWidget<IList<Street>>(
        streetListAsyncValue,
        onErrorButtonTap: () => ref
            .read(availableStreetsProvider(zone: selectedZone.value!).notifier)
            .reload(),
        childBuilder: (data) => ListView.separated(
          separatorBuilder: (_, __) => Divider(
            color: theme.colors.foregroundAtNight,
            indent: 50,
            endIndent: 50,
          ),
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            final street = data[index];
            final name = street.name;
            final districtName = street.districtDisplay;
            return InkWell(
              key: Key(street.id),
              onTap: () => _addStreet(context, street, ref),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppText.subtitleMedium(name),
                  AppText.paragraphLarge(districtName),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  _addStreet(
    BuildContext context,
    Street data,
    WidgetRef ref,
  ) {
    final streetLampNotifier = ref.watch(lampListProvider.notifier);
    final streetLamp = StreetLamp.fromStreet(data);
    handleAsyncCommand(
      context: context,
      future: () => streetLampNotifier.addOrUpdate(streetLamp),
      onSuccess: () => Navigator.pop(context),
      showOverlay: true,
    );
  }
}
