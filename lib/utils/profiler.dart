import 'dart:developer';

import '../core/app_logger.dart';

class Profiler {
  final String taskName;
  final Stopwatch _stopwatch;
  final TimelineTask _timelineTask;

  Profiler(this.taskName)
      : _stopwatch = Stopwatch(),
        _timelineTask = TimelineTask();

  void start() {
    _timelineTask.start(taskName);
    _stopwatch.start();
    AppLogger.debug('Started: $taskName', tag: 'PROFILER');
  }

  void stop() {
    _stopwatch.stop();
    _timelineTask.finish();
    final ms = _stopwatch.elapsedMilliseconds;
    AppLogger.debug('$taskName took: ${ms}ms', tag: 'PROFILER');
  }

  /// Helper to easily profile an asynchronous operation.
  static Future<T> profileAsync<T>(String name, Future<T> Function() operation) async {
    final profiler = Profiler(name);
    profiler.start();
    try {
      return await operation();
    } finally {
      profiler.stop();
    }
  }
}
