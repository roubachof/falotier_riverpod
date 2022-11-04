import 'package:falotier/presentation/add_street/add_street_screen.dart';
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
    return Scaffold(
      backgroundColor: theme.colors.background,
      floatingActionButton: AddStreetFloatingButton(theme: theme),
      body: AppContainer(
        child: RefreshIndicator(
          color: theme.colors.accent,
          notificationPredicate: (_) => ref.read(lampListProvider).hasValue,
          onRefresh: () => ref.refresh(lampListProvider.future),
          child: CustomScrollView(
            slivers: [
              SliverSafeArea(
                sliver: SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      AppPadding(
                        padding: const AppEdgeInsets.regular(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText.pageTitle('Falotier'),
                            const Padding(
                              padding: EdgeInsets.only(right: 100),
                              child: AppText.subtitleLarge(
                                'A state management poc, with a high hat.',
                                maxLines: 2,
                              ),
                            ),
                            const AppGap(AppGapSize.regular),
                            const AppText.paragraphLarge(
                                'The purpose of this PoC is to implement all real life app '
                                'scenarios and see if the selected state management library '
                                'elegantly supports all the needed mutations.'),
                            const AppGap(AppGapSize.regular),
                            SizedBox(
                              height: 50,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  AppText.paragraphLarge('City'),
                                  AppGap(AppGapSize.regular),
                                  CityDropDown(),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 200,
                                spreadRadius: 30,
                                offset: Offset.zero,
                                blurStyle: BlurStyle.normal,
                                color: theme.colors.foreground,
                              ),
                            ],
                          ),
                          child: Assets.appImage(Images.moon, 100, 100),
                        ),
                      )
                    ],
                  ),
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
