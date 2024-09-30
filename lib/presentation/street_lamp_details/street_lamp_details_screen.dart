import 'package:falotier/domain/street_lamps/providers.dart';
import 'package:falotier/domain/street_lamps/street_lamp.dart';
import 'package:falotier/presentation/common/loading_states_widgets.dart';
import 'package:falotier/presentation/common/measure_size.dart';
import 'package:falotier_design/falotier_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'lit_lamp_widget.dart';

class StreetLampDetailsScreen extends ConsumerWidget {
  const StreetLampDetailsScreen({
    required this.streetLampId,
    required this.streetName,
    super.key,
  });

  final String streetLampId;
  final String streetName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.of(context);

    final safeAreaEdges = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: theme.colors.background,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Stack(
                children: [
                  DetailsBody(
                    id: streetLampId,
                  ),
                  Padding(
                    padding: safeAreaEdges.copyWith(
                      top: safeAreaEdges.top + 32,
                    ),
                    child: Row(
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DetailsBody extends ConsumerStatefulWidget {
  const DetailsBody({
    required this.id,
    super.key,
  });

  final String id;

  @override
  ConsumerState createState() => _DetailsBodyState();
}

class _DetailsBodyState extends ConsumerState<DetailsBody> {
  Size? _bodySize;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    final lampAsyncValue = ref.watch(streetLampStateProvider(id: widget.id));

    return AsyncValueWidget<StreetLamp>(
      lampAsyncValue,
      containerHeight: 500,
      onErrorButtonTap: () =>
          ref.refresh(streetLampStateProvider(id: widget.id)),
      childBuilder: (lamp) {
        final foregroundColor = !lamp.isLit
            ? theme.colors.foregroundAtNight
            : theme.colors.foregroundAtNoon;

        return Stack(
          children: [
            Positioned.fill(
                child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                  lamp.isLit
                      ? theme.colors.enlightened
                      : theme.colors.darkOverlay,
                  lamp.isLit ? BlendMode.hardLight : BlendMode.srcOver),
              child: Assets.image(
                lamp.street.imageAsset,
                fit: BoxFit.fitHeight,
              ),
            )),
            Positioned(
                top: 100,
                right: 0,
                height: 600,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                      lamp.isLit
                          ? theme.colors.enlightened
                          : theme.colors.darkOverlay,
                      BlendMode.srcATop),
                  child: Assets.appImage(
                    Images.lamp,
                    null,
                    null,
                    fit: BoxFit.fitHeight,
                  ),
                )),
            MeasureSize(
              onChange: (size) => setState(() {
                _bodySize = size;
              }),
              child: AppContainer(
                constraints: const BoxConstraints(
                  minHeight: 600,
                ),
                padding: const AppEdgeInsets.regular(),
                decoration: BoxDecoration(
                  gradient: _buildBeneathGradient(theme, lamp.isLit),
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
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: _buildAboveGradient(theme, lamp.isLit),
                ),
              ),
            ),
            Positioned(
              top: 170,
              right: 60,
              child: LitLampWidget(id: widget.id, isLit: lamp.isLit),
            ),
          ],
        );
      },
    );
  }

  Alignment? _computeGradientAlignment() {
    // print('body size = $_bodySize');

    if (_bodySize == null) {
      return null;
    }

    const double lampMarginTop = 220;
    const double lampMarginRight = 100;

    final double halfHeight = _bodySize!.height / 2;
    final double diffHeight = halfHeight - lampMarginTop;
    final double alignmentY = diffHeight / halfHeight;

    final double halfWidth = _bodySize!.width / 2;
    final double diffWidth = halfWidth - lampMarginRight;
    final double alignmentX = diffWidth / halfWidth;

    // print('aligmentY: $alignmentY, aligmentX: $alignmentX');

    return Alignment(alignmentX, -alignmentY);
  }

  Gradient _buildBeneathGradient(AppThemeData theme, bool isLampLit) {
    final alignment = _computeGradientAlignment();

    if (alignment == null) {
      return const RadialGradient(colors: [
        Colors.black,
        Colors.black,
      ]);
    }

    if (isLampLit) {
      return RadialGradient(
        center: alignment,
        radius: 1,
        colors: [
          Colors.black.withOpacity(0),
          Colors.black.withOpacity(0.5),
          Colors.black.withOpacity(0.7),
          Colors.black.withOpacity(1),
          Colors.black.withOpacity(1),
        ],
        stops: const [
          0.1,
          0.3,
          0.7,
          0.9,
          1,
        ],
      );
    }

    return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withOpacity(0),
          Colors.black.withOpacity(0.1),
          Colors.black.withOpacity(0.2),
          Colors.black.withOpacity(0.5),
          Colors.black,
        ],
        stops: const [
          0.4,
          0.5,
          0.6,
          0.7,
          0.9
        ]);
  }

  Gradient _buildAboveGradient(AppThemeData theme, bool isLampLit) {
    final alignment = _computeGradientAlignment();

    if (alignment == null) {
      return const RadialGradient(colors: [
        Colors.black,
        Colors.black,
      ]);
    }

    if (isLampLit) {
      return RadialGradient(center: alignment, radius: 1, colors: [
        Colors.black.withOpacity(0),
        Colors.black.withOpacity(0.2),
        Colors.black.withOpacity(0.4),
        Colors.black.withOpacity(0.6),
      ], stops: const [
        0.1,
        0.3,
        0.7,
        0.9,
      ]);
    }

    return RadialGradient(
        center: const Alignment(0.0, -1.0),
        radius: 2,
        colors: [
          Colors.black.withOpacity(0.3),
          Colors.black.withOpacity(0.8),
          Colors.black.withOpacity(0.9),
          Colors.black.withOpacity(1),
        ],
        stops: const [
          0.3,
          0.5,
          0.7,
          0.9,
        ]);
  }
}
