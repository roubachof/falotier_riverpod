import 'dart:io';

import 'package:falotier/infrastructure/logger_factory.dart';
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
  FutureOr Function()? onSuccess,
  bool showOverlay = true,
}) async {
  try {
    if (showOverlay) {
      OverlayControllerWidget.of(context)?.setOverlayVisible(true);
    }
    await future();
    if (onSuccess != null) {
      await onSuccess();
    }
  } catch (e, t) {
    handleCommandError(context, e, t);
  } finally {
    if (showOverlay) {
      OverlayControllerWidget.of(context)?.setOverlayVisible(false);
    }
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

class AsyncValueWidget<T> extends StatefulWidget {
  final AsyncValue<T> asyncValue;
  final VoidCallback onErrorButtonTap;
  final Widget Function(T data) childBuilder;
  final bool asSlivers;
  final double containerHeight;

  const AsyncValueWidget(
    this.asyncValue, {
    required this.onErrorButtonTap,
    required this.childBuilder,
    this.asSlivers = false,
    this.containerHeight = 400,
    Key? key,
  }) : super(key: key);

  @override
  State<AsyncValueWidget<T>> createState() => _AsyncValueWidgetState<T>();
}

class _AsyncValueWidgetState<T> extends State<AsyncValueWidget<T>> {
  static final _log = LoggerFactory.logger('AsyncValueWidget');

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
    _log.i('_handleSuccess()');
    final result = widget.childBuilder(data);
    _previousWidget = result;
    return result;
  }

  Widget _handleLoading() {
    _log.i('_handleLoading()');
    final loadingWidget = SizedBox(
      height: widget.containerHeight,
      child: const Center(
        child: AppLoadingWidget(),
      ),
    );

    final result = widget.asSlivers
        ? SliverToBoxAdapter(
            child: loadingWidget,
          )
        : loadingWidget;
    return asyncValue.hasValue
        ? (_previousWidget ?? _handleSuccess(asyncValue.value!))
        : result;
  }

  Widget _handleError(Object error, StackTrace trace) {
    _log.e('Error in async loading', error, trace);
    if (asyncValue.isRefreshing) {
      // Display SnackBar instead of a full loading indicator
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_errorToString(error)),
      ));
      return (_previousWidget ?? _handleSuccess(asyncValue.value!));
    }

    final errorWidget = Center(
      child: SizedBox(
        height: widget.containerHeight,
        child: Center(
          child: AppErrorWidget(_errorToString(error), widget.onErrorButtonTap),
        ),
      ),
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
