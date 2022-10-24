import 'dart:io';
import 'dart:math';

class RemoteCallEmulator {
  final int minDelay;
  final int maxDelay;
  final double exceptionProbability;
  final bool cycleExceptions;

  late int _currentExceptionIndex;
  late Random _random;

  late List<Exception> _exceptionRing;

  RemoteCallEmulator({
    this.minDelay = 2,
    this.maxDelay = 3,
    this.exceptionProbability = 0,
    this.cycleExceptions = false,
  }) {
    _exceptionRing = [
      const HttpException("Communication error"),
      const HttpException("Internal server error"),
      Exception('Unhandled exception'),
    ];
    _random = Random();
    _currentExceptionIndex = _random.nextInt(3);
  }

  Future makeRemoteCall() => makeRemoteCallWith(
        minDelay: minDelay,
        maxDelay: maxDelay,
        exceptionProbability: exceptionProbability,
        cycleExceptions: cycleExceptions,
      );

  Future makeRemoteCallWith({
    int minDelay = 2,
    int maxDelay = 3,
    double exceptionProbability = 0,
    bool cycleExceptions = false,
  }) async {
    int delayMilliseconds =
        (_random.nextInt((maxDelay - minDelay) + 1) + minDelay) * 1000;

    await Future.delayed(Duration(milliseconds: delayMilliseconds));

    double exceptionDraw = _random.nextDouble();
    if (exceptionDraw <= exceptionProbability) {
      int next;
      if (cycleExceptions) {
        next = _currentExceptionIndex++ % 3;
      } else {
        next = _random.nextInt(3);
      }

      throw _exceptionRing[next];
    }
  }
}
