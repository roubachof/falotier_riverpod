import 'dart:io' show Platform;

import 'package:logger/logger.dart';

import 'tag_printer.dart';

Type typeOf<T>() => T;

class LoggerFactory {
  static Logger logger(String loggerName) {
    return Logger(
        printer: TagPrinter(
            HybridPrinter(
              PrettyPrinter(colors: Platform.isAndroid, methodCount: 30),
              debug: SimplePrinter(colors: Platform.isAndroid),
              info: SimplePrinter(colors: Platform.isAndroid),
            ),
            loggerName));
  }
}
