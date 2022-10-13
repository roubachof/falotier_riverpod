import 'package:logger/logger.dart';

class SafeFuture<T> {
  static final _log = Logger();

  final Future<T> _future;

  Future<T> get future => _future;

  SafeFuture._internal(this._future);

  factory SafeFuture.create(Future<T> future) {
    final monitor = SafeFuture._internal(future);
    monitor._runSafe();
    return monitor;
  }

  factory SafeFuture.createFunc(Future<T> Function() future) {
    final monitor = SafeFuture._internal(future());
    monitor._runSafe();
    return monitor;
  }

  void _runSafe() async {
    try {
      await _future;
    } catch (e, stacktrace) {
      _log.e('Exception while running Future<$T>: $e', e, stacktrace);
    }
  }
}
