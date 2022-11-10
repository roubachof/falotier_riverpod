import 'package:falotier/presentation/add_street/add_street_screen.dart';
import 'package:falotier/presentation/common/loading_states_widgets.dart';
import 'package:falotier/presentation/home/providers.dart';
import 'package:falotier_design/falotier_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'city_drop_down.dart';
import 'street_lamp_list.dart';

class StreetLampsScreen extends ConsumerWidget {
  const StreetLampsScreen({Key? key}) : super(key: key);

  @override
  Widget build(context, ref) {
    final theme = AppTheme.of(context);
    final safePaddingTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: theme.colors.background,
      floatingActionButton: AddStreetFloatingButton(theme: theme),
      body: AppContainer(
        child: RefreshIndicator(
          color: theme.colors.accent,
          notificationPredicate: (_) => !ref.watch(lampListProvider).isLoading,
          onRefresh: () => handleCommandFuture(
            context: context,
            future: () => ref.read(lampListProvider.notifier).refresh(),
          ),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    Padding(
                      padding: const AppEdgeInsets.regular()
                          .toEdgeInsets(theme)
                          .add(EdgeInsets.only(top: safePaddingTop)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.pageTitle(
                            'Falotier',
                            color: theme.colors.accent,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 100),
                            child: AppText.subtitleLarge(
                              'A state management PoC, with a top hat.',
                              maxLines: 2,
                            ),
                          ),
                          const AppGap(AppGapSize.semiBig),
                          const AppText.paragraphLarge(
                              'The purpose of this PoC is to implement all real life app '
                              'scenarios and see if the selected state management library '
                              'elegantly supports all the needed mutations.'),
                          const AppGap(AppGapSize.regular),
                          SizedBox(
                            height: 50,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const AppText.subtitleMedium('City'),
                                const AppGap(AppGapSize.regular),
                                const CityDropDown(),
                                const Spacer(),
                                Chip(
                                    backgroundColor: theme.colors.accent,
                                    label: AppText.paragraphLarge(
                                      'Riverpod',
                                      color: theme.colors.onAccent,
                                    ))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: safePaddingTop,
                      right: 0,
                      child: Assets.appImage(Images.moon, 100, 100),
                    ),
                    Positioned(
                      top: safePaddingTop,
                      right: 0,
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 200,
                              spreadRadius: 30,
                              offset: Offset.zero,
                              blurStyle: BlurStyle.normal,
                              color: theme.colors.foreground.withOpacity(0.7),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: theme.spacing.regular,
                ),
              ),
              const StreetLampList(),
            ],
          ),
        ),
      ),
    );
  }
}

class AddStreetFloatingButton extends ConsumerWidget {
  const AddStreetFloatingButton({
    Key? key,
    required this.theme,
  }) : super(key: key);

  final AppThemeData theme;

  @override
  Widget build(context, ref) {
    final lampListAsyncValue = ref.watch(lampListProvider);
    return lampListAsyncValue.maybeWhen(
        data: (_) => AppFloatingActionButton(
              onPressed: () => _addStreet(context),
              icon: theme.icons.icons.location,
              text: 'Add street',
            ),
        orElse: () => const SizedBox.shrink());
  }

  _addStreet(BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => const AddStreetScreen(),
    );
  }
}
