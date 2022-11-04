import 'dart:io';

import 'package:falotier_design/falotier_design.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

handleCommandError(
  BuildContext context,
  Object error,
  StackTrace? stackTrace,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    AppSnackBar.buildSnackBar(_errorToString(error), context),
  );
}

handleCommandFuture({
  required BuildContext context,
  required Future Function() future,
  required FutureOr Function() onSuccess,
}) async {
  try {
    context.loaderOverlay.show();
    await future();
    await onSuccess();
  } catch (e, t) {
    handleCommandError(context, e, t);
  } finally {
    context.loaderOverlay.hide();
  }
}

handleCommandAsyncValue(BuildContext context, AsyncValue asyncValue) {
  asyncValue.when(
    data: (_) {
      context.loaderOverlay.hide();
    },
    error: (error, stackTrace) {
      context.loaderOverlay.hide();
      handleCommandError(context, error, stackTrace);
    },
    loading: () {
      context.loaderOverlay.show();
    },
  );
}

String _errorToString(Object error) {
  String errorMessage = 'Sorry, a system error occurred.';
  if (error is HttpException) {
    errorMessage += '\n$error';
  }

  return errorMessage;
}

class AsyncValueConverter<T> extends StatefulWidget {
  final AsyncValue<T> asyncValue;
  final VoidCallback onErrorButtonTap;
  final Widget Function(T data) childBuilder;
  final bool asSlivers;

  const AsyncValueConverter(
    this.asyncValue, {
    required this.onErrorButtonTap,
    required this.childBuilder,
    this.asSlivers = false,
    Key? key,
  }) : super(key: key);

  @override
  State<AsyncValueConverter<T>> createState() => _AsyncValueConverterState<T>();
}

class _AsyncValueConverterState<T> extends State<AsyncValueConverter<T>> {
  Widget? _previousWidget;

  AsyncValue<T> get asyncValue => widget.asyncValue;

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: _handleSuccess,
      error: _handleError,
      loading: _handleLoading,
    );
  }

  Widget _handleSuccess(T data) {
    final result = widget.childBuilder(data);
    _previousWidget = result;
    return result;
  }

  Widget _handleLoading() {
    const loadingWidget = Center(
      child: LoadingWidget(),
    );
    final result = widget.asSlivers
        ? const SliverToBoxAdapter(
            child: loadingWidget,
          )
        : loadingWidget;
    return asyncValue.hasValue ? _previousWidget! : result;
  }

  Widget _handleError(Object error, StackTrace trace) {
    if (asyncValue.isRefreshing) {
      // Display SnackBar instead of a full loading indicator
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_errorToString(error)),
      ));
      return _previousWidget!;
    }

    final errorWidget = Center(
      child: ErrorWidget(error, widget.onErrorButtonTap),
    );
    final result = widget.asSlivers
        ? SliverToBoxAdapter(
            child: errorWidget,
          )
        : errorWidget;

    _previousWidget = result;
    return result;
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return CircularProgressIndicator(color: theme.colors.accent);
  }
}

class ErrorWidget extends StatelessWidget {
  final Object _error;
  final void Function() _onTap;
  final String buttonText;

  const ErrorWidget(
    this._error,
    this._onTap, {
    super.key,
    this.buttonText = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Assets.appImage(Images.bomb, 80, 80),
          const AppGap.regular(),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AppText.paragraphMedium(
                  _errorToString(_error),
                  maxLines: 2,
                ),
                AppButtonPrimary(buttonText, _onTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
