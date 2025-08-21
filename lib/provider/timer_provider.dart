import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/notification_Service.dart'; // Adjust path as needed.

class TimerController extends GetxController {
  RxBool isRunning = false.obs;
  RxInt elapsedSeconds = 0.obs;

  DateTime? startTime;
  DateTime? pauseTime;
  int totalPausedDuration = 0;
  Timer? _ticker;

  @override
  void onInit() {
    super.onInit();
    _loadStateFromPrefs();
  }

  void start() async {
    if (startTime == null) {
      startTime = DateTime.now();
    } else if (pauseTime != null) {
      totalPausedDuration += DateTime.now().difference(pauseTime!).inSeconds;
      pauseTime = null;
    }
    isRunning.value = true;
    _startTicker();
    await _saveStateToPrefs();
    _refreshNotification();
  }

  void pause() async {
    if (!isRunning.value) return;
    isRunning.value = false;
    pauseTime = DateTime.now();
    _ticker?.cancel();
    await _saveStateToPrefs();
    _refreshNotification();
  }

  void stop() async {
    isRunning.value = false;
    _ticker?.cancel();
    pauseTime = null;
    totalPausedDuration = 0;
    startTime = null;
    elapsedSeconds.value = 0;
    await _saveStateToPrefs();
    NotificationService.hideTimerNotification();
  }

  void reset() async {
    stop();
    await _saveStateToPrefs();
    NotificationService.hideTimerNotification();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedSeconds.value = _computeElapsedSeconds();
      _refreshNotification();
    });
  }

  int _computeElapsedSeconds() {
    if (startTime == null) return 0;
    if (isRunning.value) {
      return DateTime.now().difference(startTime!).inSeconds -
          totalPausedDuration;
    } else if (pauseTime != null) {
      return pauseTime!.difference(startTime!).inSeconds - totalPausedDuration;
    }
    return 0;
  }

  void _refreshNotification() {
    final seconds = _computeElapsedSeconds();
    NotificationService.updateTimerNotification(seconds, isRunning.value);
  }

  Future<void> _saveStateToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('timer_is_running', isRunning.value);
    await prefs.setInt('timer_total_paused', totalPausedDuration);
    if (startTime != null) {
      await prefs.setString('timer_start', startTime!.toIso8601String());
    } else {
      await prefs.remove('timer_start');
    }
    if (pauseTime != null) {
      await prefs.setString('timer_pause', pauseTime!.toIso8601String());
    } else {
      await prefs.remove('timer_pause');
    }
  }

  Future<void> _loadStateFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    isRunning.value = prefs.getBool('timer_is_running') ?? false;
    totalPausedDuration = prefs.getInt('timer_total_paused') ?? 0;
    startTime = prefs.getString('timer_start') != null
        ? DateTime.tryParse(prefs.getString('timer_start')!)
        : null;
    pauseTime = prefs.getString('timer_pause') != null
        ? DateTime.tryParse(prefs.getString('timer_pause')!)
        : null;

    elapsedSeconds.value = _computeElapsedSeconds();
    if (isRunning.value) _startTicker();
    _refreshNotification();
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }
}
