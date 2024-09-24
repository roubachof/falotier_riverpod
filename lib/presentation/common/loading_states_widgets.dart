import 'dart:io';

import 'package:falotier/infrastructure/logger_factory.dart';
import 'package:falotier_design/falotier_design.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final _log = LoggerFactory.logger('command');

handleCommandError(
  BuildContext context,
  Object error,
  StackTrace? stackTrace,
) {
  _log.e('Error while executing command', error: error, stackTrace: stackTrace);
  ScaffoldMessenger.of(context).showSnackBar(
    AppSnackBar.buildSnackBar(_errorToString(error), context),
  );
}

handleAsyncCommand({
  required BuildContext context,
  required Future Function() future,
  FutureOr Function()? onSuccess,
  bool showOverlay = false,
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

String _errorToString(Object error) {
  String errorMessage = 'Sorry, a system error occurred.';
  if (error is HttpException) {
    errorMessage += '\n$error';
  }

  return errorMessage;
}

class AsyncValueSequenceNode {
  const AsyncValueSequenceNode(
    this.asyncValue, {
    required this.onErrorButtonTap,
    this.loadingMessage,
    this.nodeName,
  });

  final AsyncValue asyncValue;
  final VoidCallback onErrorButtonTap;
  final String? loadingMessage;
  final String? nodeName;

  AsyncValueWidget toWidget(
    Widget child, {
    bool asSlivers = false,
    double containerHeight = 400,
  }) {
    return AsyncValueWidget(
      asyncValue,
      onErrorButtonTap: onErrorButtonTap,
      loadingMessage: loadingMessage,
      childBuilder: (_) => child,
      asSlivers: asSlivers,
      containerHeight: containerHeight,
      loggerName: nodeName,
    );
  }
}

class AsyncValueSequenceLeaf<T> {
  const AsyncValueSequenceLeaf(
    this.asyncValue, {
    required this.onErrorButtonTap,
    required this.loadingMessage,
    required this.childBuilder,
    this.leafName,
  });

  final AsyncValue<T> asyncValue;
  final VoidCallback onErrorButtonTap;
  final String loadingMessage;
  final Widget Function(T data) childBuilder;
  final String? leafName;

  AsyncValueWidget toWidget({
    bool asSlivers = false,
    double containerHeight = 400,
  }) {
    return AsyncValueWidget<T>(
      asyncValue,
      onErrorButtonTap: onErrorButtonTap,
      loadingMessage: loadingMessage,
      childBuilder: childBuilder,
      asSlivers: asSlivers,
      containerHeight: containerHeight,
      loggerName: leafName,
    );
  }
}

class AsyncValueSequenceWidget<T> extends StatelessWidget {
  const AsyncValueSequenceWidget({
    this.asSlivers = false,
    this.containerHeight = 300,
    required this.nodes,
    required this.leaf,
    Key? key,
  }) : super(key: key);

  final List<AsyncValueSequenceNode> nodes;
  final AsyncValueSequenceLeaf<T> leaf;
  final bool asSlivers;
  final double containerHeight;

  @override
  Widget build(BuildContext context) {
    // Building sequence backward
    var nextWidget = leaf.toWidget(
      asSlivers: asSlivers,
      containerHeight: containerHeight,
    );
    for (var node in nodes.reversed) {
      final currentWidget = node.toWidget(
        nextWidget,
        asSlivers: asSlivers,
        containerHeight: containerHeight,
      );
      nextWidget = currentWidget;
    }

    return nextWidget;
  }
}

class AsyncValueWidget<T> extends StatefulWidget {
  final AsyncValue<T> asyncValue;
  final VoidCallback onErrorButtonTap;
  final String? loadingMessage;
  final Widget Function(T data) childBuilder;
  final bool asSlivers;
  final double containerHeight;
  final String? loggerName;

  const AsyncValueWidget(
    this.asyncValue, {
    required this.onErrorButtonTap,
    required this.childBuilder,
    this.asSlivers = false,
    this.containerHeight = 300,
    this.loadingMessage,
    this.loggerName,
    Key? key,
  }) : super(key: key);

  @override
  State<AsyncValueWidget<T>> createState() => _AsyncValueWidgetState<T>();
}

class _AsyncValueWidgetState<T> extends State<AsyncValueWidget<T>> {
  late final Logger _log;

  @override
  void initState() {
    _log = LoggerFactory.logger(widget.loggerName ?? 'AsyncValueWidget');
    super.initState();
  }

  T? _currentData;

  AsyncValue<T> get asyncValue => widget.asyncValue;

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      skipError: true,
      skipLoadingOnRefresh: false,
      data: _handleSuccess,
      error: _handleError,
      loading: _handleLoading,
    );
  }

  Widget _handleSuccess(T data) {
    _log.i('_handleSuccess()');
    final result = widget.childBuilder(data);
    _currentData = data;
    return result;
  }

  Widget _handleLoading() {
    _log.i('_handleLoading()');
    final loadingWidget = SizedBox(
      height: widget.containerHeight,
      child: Center(
        child: AppLoadingWidget(
          loadingMessage: widget.loadingMessage,
        ),
      ),
    );

    final adaptedLoadingWidget = widget.asSlivers
        ? SliverToBoxAdapter(
            child: loadingWidget,
          )
        : loadingWidget;

    return _tryReturningData('loading', adaptedLoadingWidget);
  }

  Widget _handleError(Object error, StackTrace trace) {
    _log.e('Error in async loading', error: error, stackTrace: trace);

    // if (asyncValue.isLoading) {
    //   return _handleLoading();
    // }

    final errorWidget = SizedBox(
      height: widget.containerHeight,
      child: Center(
        child: AppErrorWidget(_errorToString(error), widget.onErrorButtonTap),
      ),
    );

    final adaptedErrorWidget = widget.asSlivers
        ? SliverToBoxAdapter(
            child: errorWidget,
          )
        : errorWidget;

    if (asyncValue.hasValue || _currentData != null) {
      // A SnackBar should have been displayed here
      // It should be handled by one of the handleCommand methods
      return _tryReturningData('error', adaptedErrorWidget);
    }

    _currentData = null;
    return adaptedErrorWidget;
  }

  Widget _tryReturningData(String stateName, Widget orElse) {
    if (asyncValue.hasValue) {
      _log.i('$stateName state but has a value: building success instead');
      return _handleSuccess(asyncValue.value as T);
    }

    if (_currentData != null) {
      _log.i(
          '$stateName state but has a current data: building success instead');
      return _handleSuccess(_currentData as T);
    }

    _currentData = null;
    return orElse;
  }
}
