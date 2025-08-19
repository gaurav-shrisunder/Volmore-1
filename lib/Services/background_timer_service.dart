import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class BackgroundTimerService {
  static const String _timerTaskName = 'timerTask';
  static const String _notificationChannelId = 'timer_channel';
  static const String _notificationChannelName = 'Timer Service';
  static const String _notificationChannelDescription =
      'Shows timer progress in background';

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static Timer? _backgroundTimer;
  static bool _isBackgroundTimerRunning = false;

  // Callback to update UI in foreground
  static Function(int)? onTimerUpdate;
  static Function()? onTimerStopped;

  /// Initialize notification plugin, WorkManager, and load timer state
  static Future<void> initialize() async {
    await _initializeNotifications();
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
    await _loadBackgroundTimerState();

    // If timer is running, start local timer
    if (_isBackgroundTimerRunning) {
      _startLocalTimer();
    }
  }

  /// Initialize notifications and create Android channel
  static Future<void> _initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(settings,
        onDidReceiveNotificationResponse: _onNotificationTapped);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _notificationChannelId,
      _notificationChannelName,
      description: _notificationChannelDescription,
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap if needed, e.g., open app or specific screen
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Starts the background timer and notification updates
  static Future<void> startBackgroundTimer() async {
    if (_isBackgroundTimerRunning) return;

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString('start_time', now.toIso8601String());
    await prefs.remove('pause_time');
    await prefs.setInt('total_paused_duration', 0);
    await prefs.setBool('is_running', true);

    _isBackgroundTimerRunning = true;
    _startLocalTimer();
    await _showTimerNotification();
  }

  /// Stops the background timer and clears saved state
  static Future<void> stopBackgroundTimer() async {
    _isBackgroundTimerRunning = false;
    _backgroundTimer?.cancel();
    _backgroundTimer = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_running', false);
    await prefs.remove('start_time');
    await prefs.remove('pause_time');
    await prefs.remove('total_paused_duration');

    await _hideTimerNotification();
    await Workmanager().cancelByUniqueName(_timerTaskName);

    onTimerStopped?.call();
  }

  static Future<void> resetBackgroundTimer() async {
    _isBackgroundTimerRunning = false;
    _backgroundTimer?.cancel();
    _backgroundTimer = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_running', false);
    await prefs.remove('start_time');
    await prefs.remove('pause_time');
    await prefs.remove('total_paused_duration');

    await _hideTimerNotification();
    await Workmanager().cancelByUniqueName(_timerTaskName);

    onTimerStopped?.call();
  }

  /// Pauses the background timer (stores pause time)
  static Future<void> pauseBackgroundTimer() async {
    if (!_isBackgroundTimerRunning) return;
    _isBackgroundTimerRunning = false;
    _backgroundTimer?.cancel();
    _backgroundTimer = null;

    final prefs = await SharedPreferences.getInstance();
    final pauseTime = DateTime.now();
    await prefs.setString('pause_time', pauseTime.toIso8601String());
    await prefs.setBool('is_running', false);

    // Calculate paused duration increment
    final startTimeStr = prefs.getString('start_time');
    if (startTimeStr != null) {
      final startTime = DateTime.tryParse(startTimeStr);
      if (startTime != null) {
        final pausedDurationSoFar = prefs.getInt('total_paused_duration') ?? 0;
        final newPausedDuration =
            pauseTime.difference(startTime).inSeconds - pausedDurationSoFar;
        if (newPausedDuration > 0) {
          await prefs.setInt(
              'total_paused_duration', pausedDurationSoFar + newPausedDuration);
        }
      }
    }
  }

  /// Resumes the background timer, adjusting pause duration accordingly
  static Future<void> resumeBackgroundTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final pauseTimeStr = prefs.getString('pause_time');

    if (pauseTimeStr == null) return; // No pause time saved, cannot resume

    final pauseTime = DateTime.tryParse(pauseTimeStr);
    if (pauseTime == null) return;

    final now = DateTime.now();
    final pauseDuration = now.difference(pauseTime).inSeconds;

    final totalPausedDuration = prefs.getInt('total_paused_duration') ?? 0;
    await prefs.setInt(
        'total_paused_duration', totalPausedDuration + pauseDuration);

    await prefs.remove('pause_time');
    await prefs.setBool('is_running', true);

    _isBackgroundTimerRunning = true;
    _startLocalTimer();
    await _showTimerNotification();
  }

  /// Loads timer state from SharedPreferences
  static Future<void> _loadBackgroundTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    _isBackgroundTimerRunning = prefs.getBool('is_running') ?? false;

    if (_isBackgroundTimerRunning) {
      _startLocalTimer();
    }
  }

  /// Starts a 1-second periodic timer to update elapsed seconds and trigger callbacks
  static void _startLocalTimer() {
    _backgroundTimer?.cancel();
    _backgroundTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!_isBackgroundTimerRunning) {
        timer.cancel();
        return;
      }

      final elapsed = await _computeElapsedSeconds();
      onTimerUpdate?.call(elapsed);
      await _updateTimerNotification(elapsed);
    });
  }

  /// Computes elapsed time in seconds considering pause and total paused duration
  static Future<int> _computeElapsedSeconds() async {
    final prefs = await SharedPreferences.getInstance();

    final startTimeStr = prefs.getString('start_time');
    final pauseTimeStr = prefs.getString('pause_time');
    final totalPausedDuration = prefs.getInt('total_paused_duration') ?? 0;
    final isRunning = prefs.getBool('is_running') ?? false;

    if (startTimeStr == null) return 0;

    final startTime = DateTime.tryParse(startTimeStr);
    if (startTime == null) return 0;

    if (isRunning) {
      return DateTime.now().difference(startTime).inSeconds -
          totalPausedDuration;
    } else if (pauseTimeStr != null) {
      final pauseTime = DateTime.tryParse(pauseTimeStr);
      if (pauseTime != null) {
        return pauseTime.difference(startTime).inSeconds - totalPausedDuration;
      }
    }

    return 0;
  }

  /// Shows initial ongoing notification
  static Future<void> _showTimerNotification() async {
    await _notifications.show(
      1,
      'Volunteering Timer',
      'Timer is running in background',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _notificationChannelId,
          _notificationChannelName,
          channelDescription: _notificationChannelDescription,
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: false,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
  }

  /// Updates the timer notification with the formatted elapsed time
  static Future<void> _updateTimerNotification(int elapsedSeconds) async {
    final timeString = _formatTime(elapsedSeconds);

    await _notifications.show(
      1,
      'Volunteering Timer',
      'Time: $timeString',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _notificationChannelId,
          _notificationChannelName,
          channelDescription: _notificationChannelDescription,
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: false,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
  }

  /// Hides/cancels the timer notification
  static Future<void> _hideTimerNotification() async {
    await _notifications.cancel(1);
  }

  /// Formats seconds into HH:mm:ss string
  static String _formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }
}

/// WorkManager callback entrypoint
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'timerTask') {
      // Refresh timer notification if running
      final prefs = await SharedPreferences.getInstance();
      final isRunning = prefs.getBool('is_running') ?? false;
      if (isRunning) {
        final elapsed = await BackgroundTimerService._computeElapsedSeconds();
        await BackgroundTimerService._updateTimerNotification(elapsed);
      }
    }
    return Future.value(true);
  });
}
