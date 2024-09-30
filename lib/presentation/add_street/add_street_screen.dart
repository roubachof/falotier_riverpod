import 'package:falotier_design/falotier_design.dart';
import 'package:flutter/material.dart';

import 'street_list.dart';

class AddStreetScreen extends StatelessWidget {
  const AddStreetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: AppPadding(
                padding: const AppEdgeInsets.small(),
                child: IconButton(
                  color: theme.colors.foreground,
                  icon: const AppIcon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: AppPadding(
                padding: AppEdgeInsets.small(),
                child: AppText.subtitleLarge('Add a street'),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Divider(
                color: theme.colors.foregroundAtNight,
              ),
            ),
          ],
        ),
      ),
      body: const StreetList(),
    );
  }
}
