import 'package:logger/logger.dart';

class TagPrinter extends LogPrinter {
  final LogPrinter _realPrinter;
  final String _tag;

  TagPrinter(this._realPrinter, this._tag);

  @override
  List<String> log(LogEvent event) {
    var realLogs = _realPrinter.log(event);
    return realLogs.map((s) => '$_tag $s').toList();
  }
}
