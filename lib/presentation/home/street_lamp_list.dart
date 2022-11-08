import 'package:diffutil_sliverlist/diffutil_sliverlist.dart';
import 'package:falotier/domain/street_lamps/street_lamp.dart';
import 'package:falotier/presentation/common/loading_states_widgets.dart';
import 'package:falotier/routes.dart';
import 'package:falotier_design/falotier_design.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'icon_button_command.dart';
import 'providers.dart';

class StreetLampList extends ConsumerWidget {
  const StreetLampList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lampListAsyncValue = ref.watch(lampListProvider);
    final lampListNotifier = ref.watch(lampListProvider.notifier);

    return AsyncValueWidget<IList<StreetLamp>>(
      lampListAsyncValue,
      asSlivers: true,
      onErrorButtonTap: () => ref.refresh(lampListProvider),
      childBuilder: (data) {
        return DiffUtilSliverList.fromKeyedWidgetList(
          children: data.map((lamp) {
            return AppPadding(
              key: Key(lamp.id),
              padding: const AppEdgeInsets.only(
                top: AppGapSize.small,
                bottom: AppGapSize.regular,
                left: AppGapSize.regular,
                right: AppGapSize.regular,
              ),
              child: StreetLampTile(
                name: lamp.street.name,
                districtName: lamp.street.districtDisplay,
                description: lamp.street.description,
                streetImageName: lamp.street.imageAsset,
                onTap: () => StreetLampDetailsRoute(
                  lamp.id,
                  $extra: lamp.street.name,
                ).push(context),
                onRemove: () => lampListNotifier.remove(lamp),
                isLampLit: lamp.isLit,
              ),
            );
          }).toList(),
          insertAnimationBuilder: (context, animation, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          removeAnimationBuilder: (context, animation, child) => FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              axisAlignment: 0,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class StreetLampTile extends StatelessWidget {
  final String name;
  final String districtName;
  final String description;
  final String streetImageName;
  final void Function() onTap;
  final Future Function() onRemove;
  final bool isLampLit;

  const StreetLampTile({
    Key? key,
    required this.name,
    required this.districtName,
    required this.description,
    required this.streetImageName,
    required this.onRemove,
    required this.isLampLit,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final foregroundColor = !isLampLit
        ? theme.colors.foregroundAtNight
        : theme.colors.foregroundAtNoon;

    return AppContainer(
      height: 115,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fitWidth,
          image: Assets.image(streetImageName).image,
          colorFilter: ColorFilter.mode(
              isLampLit ? theme.colors.enlightened : theme.colors.darkOverlay,
              isLampLit ? BlendMode.hardLight : BlendMode.srcOver),
        ),
        boxShadow: isLampLit
            ? [
                BoxShadow(
                    color: theme.colors.accent.withOpacity(0.4),
                    offset: const Offset(4, -4),
                    blurRadius: 15,
                    spreadRadius: 0)
              ]
            : [],
        borderRadius: theme.radius.asBorderRadius().regular,
      ),
      child: Stack(
        children: [
          AppContainer(
            decoration: BoxDecoration(
              borderRadius: theme.radius.asBorderRadius().regular,
              gradient: _buildGradient(),
            ),
            padding: const AppEdgeInsets.symmetric(
              vertical: AppGapSize.regular,
              horizontal: AppGapSize.regular,
            ),
            child: InkWell(
              onTap: onTap,
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.subtitleMedium(name,
                          color: isLampLit
                              ? theme.colors.accent
                              : foregroundColor),
                      AppText.paragraphLarge(districtName,
                          color: foregroundColor),
                      AppText.paragraphMedium(
                        description,
                        color: foregroundColor,
                        maxLines: 2,
                      ),
                    ],
                  ),
                  Transform.translate(
                    offset: const Offset(16, -8),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: IconButtonCommand(
                          iconData: Icons.close, onPressed: onRemove),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Gradient _buildGradient() {
    if (isLampLit) {
      return RadialGradient(
          center: const Alignment(0.7, -0.1),
          radius: 2,
          colors: [
            Colors.black.withOpacity(0),
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.8),
          ],
          stops: const [
            0.3,
            0.5,
            0.7,
            0.9,
          ]);
    }

    return LinearGradient(
        begin: const Alignment(1.0, -1.0),
        end: const Alignment(-1.0, 1.0),
        colors: [
          Colors.black.withOpacity(0),
          Colors.black.withOpacity(0.8),
        ],
        stops: const [
          0.3,
          0.5,
        ]);
  }
}
