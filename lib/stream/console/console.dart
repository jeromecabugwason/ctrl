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

  static void clear() {
    _logStreamController.add('');
  }

  static void close() {
    _logStreamController.close();
  }

  static void _log(String level, String message) {
    final String logMessage = "[$level]: $message";
    _logStreamController.add(logMessage);
  }
}
