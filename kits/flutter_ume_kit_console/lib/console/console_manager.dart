part of '../flutter_ume_kit_console_plus.dart';

const int maxLine = 1000;

class ConsoleManager {
  static final Queue<Tuple2<DateTime, String>> _logData = Queue();

  static Queue<Tuple2<DateTime, String>> get logData => _logData;

  static StreamController get streamController {
    final logStreamController = StreamController.broadcast();
    var transformer =
        StreamTransformer<dynamic, Tuple2<DateTime, String>>.fromHandlers(
            handleData: (str, sink) {
      final now = DateTime.now();
      if (str is String) {
        sink.add(Tuple2(now, str));
      } else {
        sink.add(Tuple2(now, str.toString()));
      }
    });

    logStreamController.stream.transform(transformer).listen((value) {
      if (_logData.length < maxLine) {
        _logData.addFirst(value);
      } else {
        _logData.removeLast();
      }
    });
    return logStreamController;
  }

  static DebugPrintCallback? _originalDebugPrint;

  static void redirectDebugPrint() {
    if (_originalDebugPrint != null) return;
    _originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      ConsoleManager.streamController.sink.add(message);
      if (_originalDebugPrint != null) {
        _originalDebugPrint!(message, wrapWidth: wrapWidth);
      }
    };
  }

  static void clearLog() {
    logData.clear();
    streamController.add('UME CONSOLE == ClearLog');
  }

  static void clearRedirect() {
    debugPrint = _originalDebugPrint!;
    _originalDebugPrint = null;
  }
}
