import 'dart:developer';

class LogUtil {
  LogUtil._(); // Private constructor to prevent instantiation

  // ANSI color codes
  static const _reset = '\x1B[0m';
  static const _red = '\x1B[31m';
  static const _green = '\x1B[32m';
  static const _yellow = '\x1B[33m';
  static const _blue = '\x1B[34m';
  static const _magenta = '\x1B[35m';
  static const _cyan = '\x1B[36m';
  static const _white = '\x1B[37m';

  /// Print in red
  static void error(String message, {String? tag}) {
    _print(message, color: _red, tag: tag ?? 'ERROR');
  }

  /// Print in green
  static void success(String message, {String? tag}) {
    _print(message, color: _green, tag: tag ?? 'SUCCESS');
  }

  /// Print in yellow
  static void warning(String message, {String? tag}) {
    _print(message, color: _yellow, tag: tag ?? 'WARNING');
  }

  /// Print in blue
  static void info(String message, {String? tag}) {
    _print(message, color: _blue, tag: tag ?? 'INFO');
  }

  /// Core print function
  static void _print(String message, {required String color, required String tag}) {
    // Include timestamp for easier tracing
    final timestamp = DateTime.now().toIso8601String();
    log('$color[$tag][$timestamp]: $message$_reset');
  }
}
