import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'notification_Service.dart';

class BackgroundTaskHandler {
  static const String _taskName = 'volunteer_timer_task';
  static int _backgroundElapsedSeconds = 0;
  static DateTime? _backgroundStartTime;
  static bool _isBackgroundTimerRunning = false;
  static Timer? _localTimer;

  static Function(int)? onTimerUpdate;
  static Function()? onTimerStopped;

  static Future<void> initialize() async {
    await Workmanager().initialize(
      _onBackgroundTask,
      isInDebugMode: false,
    );
    await _loadBackgroundState();
  }

  static Future<void> _onBackgroundTask(
      String task, Map<String, dynamic>? inputData) async {
    if (task == _taskName) {
      final prefs = await SharedPreferences.getInstance();
      final isRunning = prefs.getBool('background_timer_running') ?? false;
      if (isRunning) {
        final startTimeStr = prefs.getString('background_start_time');
        if (startTimeStr != null) {
          final startTime = DateTime.tryParse(startTimeStr);
          if (startTime != null) {
            final elapsedSeconds =
                DateTime.now().difference(startTime).inSeconds;
            final timeString = NotificationService.formatTime(elapsedSeconds);
            await NotificationService.showTimerNotification(timeString);
            prefs.setInt('background_elapsed_seconds', elapsedSeconds);
          }
        }
      }
    }
    return Future.value(true);
  }

  static Future<void> startBackgroundTimer() async {
    _backgroundStartTime = DateTime.now();
    _backgroundElapsedSeconds = 0;
    _isBackgroundTimerRunning = true;

    await _saveBackgroundState();
    await NotificationService.showTimerNotification('00:00:00');

    // Schedule periodic background task
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(minutes: 15),
    );

    _startLocalTimer();
  }

  static void _startLocalTimer() {
    _localTimer?.cancel();
    _localTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isBackgroundTimerRunning && _backgroundStartTime != null) {
        _backgroundElapsedSeconds =
            DateTime.now().difference(_backgroundStartTime!).inSeconds;
        onTimerUpdate?.call(_backgroundElapsedSeconds);
        _updateTimerNotification();
      } else {
        timer.cancel();
      }
    });
  }

  static Future<void> _updateTimerNotification() async {
    final timeString =
        NotificationService.formatTime(_backgroundElapsedSeconds);
    await NotificationService.showTimerNotification(timeString);
  }

  static Future<void> stopBackgroundTimer() async {
    _isBackgroundTimerRunning = false;
    await _saveBackgroundState();
    await NotificationService.hideTimerNotification();
    await Workmanager().cancelByUniqueName(_taskName);
    onTimerStopped?.call();
  }

  static Future<void> pauseBackgroundTimer() async {
    _isBackgroundTimerRunning = false;
    _localTimer?.cancel();
    await _saveBackgroundState();
  }

  static Future<void> resumeBackgroundTimer() async {
    if (_backgroundStartTime == null) return;
    _isBackgroundTimerRunning = true;
    await _saveBackgroundState();
    await _updateTimerNotification();
    _startLocalTimer();
  }

  static Future<void> _saveBackgroundState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('background_timer_running', _isBackgroundTimerRunning);
    prefs.setInt('background_elapsed_seconds', _backgroundElapsedSeconds);
    if (_backgroundStartTime != null) {
      prefs.setString(
        'background_start_time',
        _backgroundStartTime!.toIso8601String(),
      );
    }
  }

  static Future<void> _loadBackgroundState() async {
    final prefs = await SharedPreferences.getInstance();
    _isBackgroundTimerRunning =
        prefs.getBool('background_timer_running') ?? false;
    _backgroundElapsedSeconds = prefs.getInt('background_elapsed_seconds') ?? 0;
    final startTimeStr = prefs.getString('background_start_time');
    if (startTimeStr != null) {
      _backgroundStartTime = DateTime.tryParse(startTimeStr);
    }
    if (_isBackgroundTimerRunning && _backgroundStartTime != null) {
      _backgroundElapsedSeconds =
          DateTime.now().difference(_backgroundStartTime!).inSeconds;
    }
  }

  static int getCurrentElapsedSeconds() => _backgroundElapsedSeconds;
  static bool getIsTimerRunning() => _isBackgroundTimerRunning;
  static DateTime? getStartTime() => _backgroundStartTime;

  static Future<void> resetBackgroundTimer() async {
    _isBackgroundTimerRunning = false;
    _backgroundElapsedSeconds = 0;
    _backgroundStartTime = null;
    _localTimer?.cancel();
    await NotificationService.hideTimerNotification();
    await _saveBackgroundState();
    await Workmanager().cancelByUniqueName(_taskName);
  }
}
