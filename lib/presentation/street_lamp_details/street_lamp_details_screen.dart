import 'package:falotier/domain/street_lamps/providers.dart';
import 'package:falotier/domain/street_lamps/street_lamp.dart';
import 'package:falotier/presentation/common/loading_states_widgets.dart';
import 'package:falotier_design/falotier_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StreetLampDetailsScreen extends ConsumerWidget {
  const StreetLampDetailsScreen({
    required this.streetLampId,
    required this.streetName,
    Key? key,
  }) : super(key: key);

  final String streetLampId;
  final String streetName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: SafeArea(
              child: SizedBox(
                height: constraints.maxHeight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppPadding(
                          padding: const AppEdgeInsets.small(),
                          child: IconButton(
                            color: theme.colors.foreground,
                            icon: const AppIcon.big(Icons.arrow_back),
                            onPressed: () => context.pop(),
                          ),
                        ),
                        Expanded(
                          child: AppPadding(
                              padding: const AppEdgeInsets.only(
                                right: AppGapSize.big,
                              ),
                              child: AppText.pageTitle(
                                streetName,
                                softWrap: true,
                              )),
                        ),
                      ],
                    ),
                    Expanded(
                      child: DetailsBody(
                        id: streetLampId,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DetailsBody extends ConsumerWidget {
  const DetailsBody({
    required this.id,
    Key? key,
  }) : super(key: key);

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);

    final lampAsyncValue = ref.watch(streetLampStateProvider(id: id));

    return AsyncValueConverter<StreetLamp>(
      lampAsyncValue,
      onErrorButtonTap: () => ref.refresh(streetLampStateProvider(id: id)),
      childBuilder: (lamp) {
        final foregroundColor = !lamp.isLit
            ? theme.colors.foregroundAtNight
            : theme.colors.foregroundAtNoon;

        return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fitHeight,
                image: Assets.image(lamp.street.imageAsset).image,
                colorFilter: ColorFilter.mode(
                    lamp.isLit
                        ? theme.colors.enlightened
                        : theme.colors.darkOverlay,
                    lamp.isLit ? BlendMode.hardLight : BlendMode.srcOver),
              ),
            ),
            child: AppContainer(
              decoration: BoxDecoration(
                gradient: _buildGradient(theme, lamp.isLit),
              ),
              padding: const AppEdgeInsets.symmetric(
                vertical: AppGapSize.small,
                horizontal: AppGapSize.small,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 300),
                  AppText.subtitleLarge(
                    lamp.street.districtDisplay,
                    color: foregroundColor,
                  ),
                  const AppGap.regular(),
                  AppText.paragraphLarge(
                    lamp.street.description,
                    softWrap: true,
                    color: foregroundColor,
                  ),
                ],
              ),
            ));
      },
    );
  }

  Gradient _buildGradient(AppThemeData theme, bool isLampLit) {
    if (isLampLit) {
      return RadialGradient(
          center: const Alignment(0.7, -0.7),
          radius: 1,
          colors: [
            Colors.black.withOpacity(0),
            Colors.black.withOpacity(0.5),
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.9),
          ],
          stops: const [
            0.1,
            0.3,
            0.7,
            0.9,
          ]);
    }

    return LinearGradient(
        begin: const Alignment(1.0, -1.0),
        end: const Alignment(-1.0, 1.0),
        colors: [
          Colors.black.withOpacity(0.4),
          Colors.black.withOpacity(0.8),
        ],
        stops: const [
          0.3,
          0.5,
        ]);
  }
}
