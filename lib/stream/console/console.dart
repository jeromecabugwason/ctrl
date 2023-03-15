import 'dart:async';

class Console {
  static final StreamController<String> _logStreamController =
      StreamController.broadcast();

  static Stream<String> get logStream => _logStreamController.stream;

  static void info(String message) {
    _log("INFO", message);
  }

  static void warning(String message) {
    _log("WARNING", message);
  }

  static void error(String message) {
    _log("ERROR", message);
  }

  static void log(String message) {
    _log("LOG", message);
  }

  static void _log(String level, String message) {
    final DateTime now = DateTime.now();
    final String timestamp =
        "${now.hour}:${now.minute}:${now.second}.${now.millisecond.toString().padLeft(3, '0')}";
    final String logMessage = "$timestamp [$level]: $message";
    _logStreamController.add(logMessage);
  }
}
