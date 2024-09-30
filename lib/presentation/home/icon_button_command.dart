import 'package:falotier/presentation/common/loading_states_widgets.dart';
import 'package:falotier_design/falotier_design.dart';
import 'package:flutter/material.dart';

class IconButtonCommand extends StatefulWidget {
  const IconButtonCommand({
    super.key,
    required this.iconData,
    required this.onPressed,
  });

  final IconData iconData;
  final Future Function() onPressed;

  @override
  State<IconButtonCommand> createState() => _IconButtonCommandState();
}

class _IconButtonCommandState extends State<IconButtonCommand> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    if (_isLoading) {
      return AppPadding(
        padding: const AppEdgeInsets.regular(),
        child: SizedBox(
          height: theme.icons.sizes.regular,
          width: theme.icons.sizes.regular,
          child: const AppLoadingWidget(),
        ),
      );
    }

    return IconButton(
      color: theme.colors.foreground,
      icon: AppIcon.regular(widget.iconData),
      onPressed: () => _internalOnPressed(context),
    );
  }

  Future _internalOnPressed(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await widget.onPressed();
    } catch (error, stackTrace) {
      handleCommandError(context, error, stackTrace);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
