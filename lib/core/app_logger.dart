import 'package:flutter/foundation.dart';

/// Lightweight app logger — debug output only in debug builds.
class AppLogger {
  AppLogger._();

  static void debug(String message, {String? tag}) {
    if (!kDebugMode) return;
    debugPrint(_format(message, tag: tag));
  }

  static void error(String message, {String? tag, Object? error}) {
    if (!kDebugMode) return;
    final details = error == null ? message : '$message: $error';
    debugPrint(_format(details, tag: tag ?? 'ERROR'));
  }

  static String _format(String message, {String? tag}) {
    if (tag == null || tag.isEmpty) {
      return message;
    }
    return '[$tag] $message';
  }
}
